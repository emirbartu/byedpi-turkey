#!/bin/bash
set -e

NAME="byedpictl"
BIN_DIR="/usr/local/bin"
CONF_DIR="/etc/$NAME"
LOG_DIR="/var/log/$NAME"
PID_DIR="/var/run/$NAME"

CLI_LOG="$LOG_DIR/cli.log"

cmd_help() {
  cat <<EOF
$0

COMMANDS:
    tun <start|stop|restart|status|change [profile-name]>
        Control and monitor the background routing to tunnel all traffic
        through the byedpi proxy.
        For the "change" command, you can specify a profile name directly.
        If no profile is specified, you will be prompted interactively.
    zenity
        Start in GUI mode.
    help
        Show this message and exit.
EOF
}

cmd_tun() {
  case $1 in
  start)
    start_tunneling
    ;;
  stop)
    stop_tunneling
    ;;
  restart)
    stop_tunneling
    start_tunneling
    ;;
  status)
    show_tunneling_status
    ;;
  change)
    change_profile $2
    ;;
  *)
    echo "Invalid argument!"
    ;;
  esac
}

cmd_zenity() {
  cmd=$(
    zenity --list --title="$NAME" --hide-header --column="0" \
      "ByeDPI'i Baslat" "ByeDPI'i Durdur" "ByeDPI'i Yeniden Baslat" "Profili Degistir"
  )

  reply=""
  case $cmd in
  "ByeDPI'i Baslat")
    reply=$(pkexec "$0" tun start) || true
    ;;
  "ByeDPI'i Durdur")
    reply=$(pkexec "$0" tun stop) || true
    ;;
  "ByeDPI'i Yeniden Baslat")
    reply=$(pkexec "$0" tun restart) || true
    ;;
  esac

  zenity --notification --title "$NAME" \
    --text="$NAME\n$reply"
}

prepare_dirs() {
  mkdir -p "$LOG_DIR"
  mkdir -p "$PID_DIR"
}

load_conf() {
  source "$CONF_DIR/server.conf"
  source "$CONF_DIR/desync.conf"
}

start_tunneling() {
  if [[ -f $PID_DIR/tunnel.pid ]]; then
    echo "Tunnel is already running"
    exit 1
  fi

  prepare_dirs
  load_conf

  ciadpi_args="--ip $CIADPI_IP --port $CIADPI_PORT ${CIADPI_DESYNC[@]}"

  nohup su - byedpi -s /bin/bash -c "$BIN_DIR/ciadpi $ciadpi_args" \
    >$LOG_DIR/server.log 2>&1 &
  echo $! >$PID_DIR/server.pid
  nohup $BIN_DIR/hev-socks5-tunnel $CONF_DIR/hev-socks5-tunnel.yaml \
    >$LOG_DIR/tunnel.log 2>&1 &
  echo $! >$PID_DIR/tunnel.pid

  while true; do
    sleep 0.2
    if ip tuntap list | grep -q byedpi-tun; then
      break
    fi

    echo "Waiting for tunnel interface..."
  done

  user_id=$(id -u byedpi)
  nic_name=$(ip route show to default | awk '$5 != "byedpi-tun" {print $5; exit}')
  gateway_addr=$(ip route show to default | awk '$5 != "byedpi-tun" {print $3; exit}')

  ip rule add uidrange $user_id-$user_id lookup 110 pref 28000
  ip route add default via $gateway_addr dev $nic_name metric 50 table 110
  ip route add default via 172.20.0.1 dev byedpi-tun metric 1

  echo "Successfully started the full traffic tunneling"
}

stop_tunneling() {
  if [[ ! -f $PID_DIR/tunnel.pid ]]; then
    echo "Tunnel is not running"
    exit 1
  fi

  user_id=$(id -u byedpi)
  nic_name=$(ip route show to default | awk '$5 != "byedpi-tun" {print $5; exit}')
  gateway_addr=$(ip route show to default | awk '$5 != "byedpi-tun" {print $3; exit}')

  ip rule del uidrange $user_id-$user_id lookup 110 pref 28000 2>$CLI_LOG || true
  ip route del default via "$gateway_addr" dev "$nic_name" metric 50 table 110 2>$CLI_LOG || true
  ip route del default via 172.20.0.1 dev byedpi-tun metric 1 2>$CLI_LOG || true

  kill $(cat $PID_DIR/tunnel.pid) 2>$CLI_LOG || true
  kill $(cat $PID_DIR/server.pid) 2>$CLI_LOG || true

  rm -rf "$PID_DIR" || true

  echo "Successfully stopped the tunneling"
}

show_tunneling_status() {
  server_status="offline"
  tun_status="offline"

  if [ -f "$PID_DIR/server.pid" ]; then
    if ps -p $(cat "$PID_DIR/server.pid") >/dev/null 2>&1; then
      server_status="running"
    else
      server_status="crashed"
    fi
  fi

  if [ -f "$PID_DIR/tunnel.pid" ]; then
    if ps -p $(cat "$PID_DIR/tunnel.pid") >/dev/null 2>&1; then
      tun_status="running"
    else
      tun_status="crashed"
    fi
  fi

  cat <<EOF
$NAME background tunneling services

server: $server_status
tunnel: $tun_status
EOF
}

change_profile() {
  # Check if tunnel is running and stop it temporarily
  local was_running=false
  if [[ -f $PID_DIR/tunnel.pid ]]; then
    was_running=true
  fi

  # Stop tunneling if running
  if [[ "$was_running" == true ]]; then
    stop_tunneling
  fi

  local profile=""
  
  # If profile provided as argument, use it directly
  if [[ -n "$1" ]]; then
    # Convert argument to match file naming (replace spaces with dashes, lowercase)
    profile=$(echo "$1" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
    local profile_file="/etc/byedpictl/profiles/${profile}.conf"
    
    if [[ -f "$profile_file" ]]; then
      echo "$profile profili seçildi."
    else
      echo "Geçersiz profil: $1"
      echo "Geçerli profiller için 'byedpictl tun change' komutunu argümansız çalıştırın."
      if [[ "$was_running" == true ]]; then
        start_tunneling
      fi
      exit 1
    fi
  else
    # Prompt user to select profile dynamically
    echo
    echo "Mevcut profiller:"
    echo
    
    # List profiles dynamically
    local profiles_dir="/etc/byedpictl/profiles"
    local profile_files=()
    local profile_names=()
    local counter=1
    
    if [[ -d "$profiles_dir" ]]; then
      for profile_file in "$profiles_dir"/*.conf; do
        if [[ -f "$profile_file" ]]; then
          profile_files+=("$profile_file")
          profile_name=$(basename "$profile_file" .conf)
          profile_names+=("$profile_name")
          echo "$counter - $profile_name"
          
          # Show profile info
          name=$(grep -E "^# Profile Name:" "$profile_file" | sed 's/^# Profile Name: *//' | sed 's/^#* *//' | xargs)
          description=$(grep -E "^# Description:" "$profile_file" | sed 's/^# Description: *//' | sed 's/^#* *//' | xargs)
          
          if [[ -n "$name" ]]; then
            echo "    İsim: $name"
          fi
          if [[ -n "$description" ]]; then
            echo "    Açıklama: $description"
          fi
          echo
          ((counter++))
        fi
      done
    else
      echo "Profil dizini bulunamadı: $profiles_dir"
      if [[ "$was_running" == true ]]; then
        start_tunneling
      fi
      exit 1
    fi
    
    read -p "Profil seçiminiz (1-$(( ${#profile_files[@]} ))): " profile_secim

    while [[ ! "$profile_secim" =~ ^[0-9]+$ ]] || [[ "$profile_secim" -lt 1 ]] || [[ "$profile_secim" -gt "${#profile_files[@]}" ]]; do
      echo "Lütfen geçerli bir seçim yapın (1-$(( ${#profile_files[@]} )))."
      read -p "Profil seçiminiz (1-$(( ${#profile_files[@]} ))): " profile_secim
    done
    
    profile="${profile_names[$((profile_secim-1))]}"
    echo "${profile_names[$((profile_secim-1))]} profili seçildi."
  fi

  # Apply the selected profile
  local profile_file="/etc/byedpictl/profiles/${profile}.conf"
  local target_file="$CONF_DIR/desync.conf"

  if [[ -f "$profile_file" ]]; then
    echo "Profil uygulanıyor: $profile"
    sudo cp "$profile_file" "$target_file"
    echo "Profil başarıyla uygulandı."
  else
    echo "UYARI: $profile_file bulunamadı. Varsayılan ayarlar kullanılacak."
    echo "Lütfen /etc/byedpictl/desync.conf dosyasını manuel olarak düzenleyin."
  fi

  # Restart tunneling if it was running
  if [[ "$was_running" == true ]]; then
    start_tunneling
  fi
}


case $1 in
help)
  cmd_help
  ;;
tun)
  cmd_tun $2
  ;;
zenity)
  cmd_zenity
  ;;
*)
  echo "Invalid argument $1"
  echo "Use \"help\" command."
  exit 1
  ;;
esac
