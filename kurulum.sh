#!/bin/bash

set -e

iss="diger"
DNS_NONE="/etc/NetworkManager/conf.d/90-dns-none.conf"

paket-yonetici-tanimla() {
if command -v pacman &> /dev/null; then
    paketyonetici="pacman -S"
    distro="arch tabanli"
  fi

if command -v dnf &> /dev/null; then
    paketyonetici="dnf install"
    distro="fedora tabanli"
  fi

if command -v apt &> /dev/null; then
    paketyonetici="apt install"
    distro="debian/ubuntu tabanli"
  fi

  echo "Tespit edilen distro tabani ${distro}"
  read -p "Bu dogru mu? (evet/hayir): " distrocevap

  distrocevap=$(echo "$distrocevap" | tr '[:upper:]' '[:lower:]')

  while [[ "$distrocevap" != "evet" && "$distrocevap" != "e" && "$distrocevap" != "hayir" && "$distrocevap" != "h" && "$distrocevap" != "hayır" ]]; do
    echo "Lutfen evet ya da hayir olarak cevaplayin (ya da e/h)."
    echo "Tespit edilen distro tabani ${distro}"
    read -p "Bu dogru mu? (evet/hayir): " distrocevap
    cevap=$(echo "$distrocevap" | tr '[:upper:]' '[:lower:]')
  done

  if [[ "$distrocevap" =~ ^(hayir|hayır|h)$ ]]; then
    echo
    echo
    echo "Lütfen manuel olarak dağıtım tabanınızı seçiniz."
    echo
    echo "1 - Arch Tabanlı (Arch, CachyOS, EndeavourOS, Manjaro vs.)"
    echo "2 - Fedora Tabanlı (Fedora, Nobara vs.)"
    echo "3 - Debian/Ubuntu Tabanlı (Ubuntu, Debian, Mint, Zorin vs.)"
    echo

    read -p "Dağıtımınızın hangi taban olduğunu seçiniz (1/2/3): " manuelcevap

    while [[ ! "$manuelcevap" =~ ^(1|2|3)$ ]]; do
      echo "Lütfen geçerli bir cevap giriniz (1, 2 veya 3)."
      read -p "Dağıtımınızın hangi taban olduğunu seçiniz (1/2/3): " manuelcevap
    done

    if [[ "$manuelcevap" == "1" ]]; then
      paketyonetici="pacman -S"
      distro="arch tabanlı"
    elif [[ "$manuelcevap" == "2" ]]; then
      paketyonetici="dnf install"
      distro="fedora tabanlı"
    elif [[ "$manuelcevap" == "3" ]]; then
      paketyonetici="apt install"
      distro="debian/ubuntu tabanlı"
    fi

    echo "${distro} seçildi. Paket yükleme komutu: '${paketyonetici}' kullanılacak."
  else
    echo "Dağıtımınız ${distro} olarak belirlendi. Paket yükleme komutu: '${paketyonetici}' kullanılacak."
  fi  
}

ubuntu-check() {
    if [[ "$paketyonetici" == "apt install" ]]; then
        echo "Ubuntu destegi yapilan testler sonucunda kaldirilmistir. Ubuntu icin yeni bir script eklenecektir."
        exit 1
    fi
}

acikla() {
  echo "Bu kurulum sihirbazi dnscrypt-proxy ile beraber byedpictl kuracaktir. Betigi kullanmak tamamen sizin sorumlulugunuzdadir."
  echo
}

# ISS profili seçimi
iss-check() {
  echo
  echo "Lütfen internet servis sağlayıcınızı seçin:"
  echo
  echo "1 - Superonline"
  echo "2 - Turkcell"
  echo "3 - Vodafone"
  echo "4 - TTNet"
  echo "5 - Diğer/Genel Ayarlar"
  echo
  read -p "ISS seçiminiz (1-5): " iss_secim
  
  while [[ ! "$iss_secim" =~ ^[1-5]$ ]]; do
    echo "Lütfen geçerli bir seçim yapın (1-5)."
    read -p "ISS seçiminiz (1-5): " iss_secim
  done
  
  case "$iss_secim" in
    1)
      iss="superonline"
      echo "Superonline profili seçildi."
      ;;
    2)
      iss="turknet"
      echo "TurkNet profili seçildi."
      ;;
    3)
      iss="vodafone"
      echo "Vodafone profili seçildi."
      ;;
    4)
      iss="turktelekom"
      echo "Turk Telekom profili seçildi."
      ;;
    5)
      iss="diger"
      echo "Genel ayarlar seçildi."
      ;;
  esac
  
  echo "Seçiminizi değiştirmek isterseniz kurulum sonrasında /etc/byedpictl/desync.conf dosyasını düzenleyebilirsiniz."
  echo
}

# ISS profiline göre desync.conf kopyalama fonksiyonu
iss-profil-uygula() {
  local profil_dosyasi="isp_profiles/$iss/desync.conf"
  local hedef_dosya="src/conf/desync.conf"
  
  if [[ -f "$profil_dosyasi" ]]; then
    echo "ISS profili uygulanıyor: $iss"
    cp "$profil_dosyasi" "$hedef_dosya"
    echo "Profil başarıyla uygulandı."
  else
    echo "UYARI: $profil_dosyasi bulunamadı. Varsayılan ayarlar kullanılacak."
    echo "Lütfen kurulum sonrasında /etc/byedpictl/desync.conf dosyasını manuel olarak düzenleyin."
  fi
}

dnscrypt-check() {
  while ! command -v dnscrypt-proxy &> /dev/null; do
    echo "Sistemde dnscrypt-proxy tespit edilemedi. Paket yoneticinizle kurulum yapiliyor."
    echo "Lutfen sudo sifresi istenirse girin."
    echo ""
    sudo ${paketyonetici} dnscrypt-proxy
    sleep 2
    echo "dnscrypt-proxy tekrar kontrol ediliyor..."
    if command -v dnscrypt-proxy &> /dev/null; then
      echo "Kontrol basarili. Devam ediliyor."
    else
      echo "Kontrol basarisiz. Tekrar deneniyor..."
    fi
  done

  if command -v dnscrypt-proxy &> /dev/null; then
    echo "dnscrypt-proxy tespit edildi. Devam ediliyor."
  else
    echo "dnscrypt kurulumunda bir sorun var gibi gorunuyor..."
    exit 1
  fi
}

zenity-check() {
  while ! command -v zenity &> /dev/null; do
    echo "Sistemde zenity tespit edilemedi. Paket yoneticinizle kurulum yapiliyor."
    echo "Lutfen sudo sifresi istenirse girin."
    echo ""
    sudo ${paketyonetici} zenity
    if command -v zenity &> /dev/null; then
      echo "Kontrol basarili. Devam ediliyor."
    else
      echo "Kontrol basarisiz. Tekrar deneniyor..."
    fi
  done

  if command -v zenity &> /dev/null; then
    echo "zenity tespit edildi. Devam ediliyor."
  else
    echo "zenity kurulumunda bir sorun var gibi gorunuyor..."
    exit 1
  fi
}

dns-none() {
  echo "networkmanager dns-none ayarlaniyor..."
  echo "Lutfen sudo sifresi istenirse girin."

  echo "Dosya yaziliyor: $DNS_NONE"
  sudo tee "$DNS_NONE" >/dev/null <<'EOF'
[main]
dns=none
EOF
}

resolv-conf() {
  echo "resolv.conf dosyasi guncelleniyor..."
  echo "UYARI: mevcut resolv.conf dosyasinin uzerine yazilacaktir. Orijinal resolv.conf yedekleniyor..."

  sudo cp /etc/resolv.conf /etc/resolv.conf.bak
  sudo cp configs/resolv.conf /etc/resolv.conf
}

dnscrypt-config() {
  echo "dnscrypt-proxy configi kuruluyor..."

  sudo cp configs/dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml

  echo "dnscrypt-proxy'i dogru sekilde kullanmak icin masaustu ortaminizin ayarlarindan dns'i 127.0.0.1 olarak ayarlamalisiniz."
  echo "nasil yapilacagini bilmiyorsaniz rehber videosuna bakabilirsiniz."

  echo "Servisler baslatiliyor."
  sudo systemctl enable dnscrypt-proxy.service
  sudo systemctl start dnscrypt-proxy.service
}

systemd-service() {
  if [[ $(ps -p 1 -o comm=) == "systemd" ]]; then
      echo "systemd kullaniliyor."
      echo "systemd servisi kuruluyor..."
      sudo cp configs/byedpi-start.service /etc/systemd/system/byedpi-start.service
      sleep 1
      sudo systemctl daemon-reload
      sleep 2
      sudo systemctl enable byedpi-start.service
      sudo systemctl start byedpi-start.service
      echo
      echo "sistemin basinda acilmasini saglayan systemd servisini 'sudo systemctl enable/disable byedpi-start' yazarak kontrol edebilirsiniz"
  else
      echo "systemd kullanilmiyor. servis es geciliyor."
  fi
}

dns-degis() {
  if command -v nmcli &> /dev/null; then
    aktif_ag=$(nmcli -t -f NAME connection show --active | head -n1)
    if [ -z "$aktif_ag" ]; then
        echo "aktif ag bulunamadi..."
    else
      nmcli connection modify "$aktif_ag" ipv4.dns "127.0.0.1"
      nmcli connection modify "$aktif_ag" ipv4.ignore-auto-dns yes
      echo "${aktif_ag} aginin dns'i 127.0.0.1 olarak ayarlandi."
      echo "network yeniden baslatiliyor..."
      nmcli connection down "$aktif_ag" 2>/dev/null
      sleep 1
      nmcli connection up "$aktif_ag"
    fi
  else
    echo "networkmanager bulunamadi. dns ayari otomatik olarak yapilamiyor. lutfen manuel bir sekilde dns'inizi 127.0.0.1 olarak ayarlayin."
  fi
}

byedpi-setup() {
  echo "byedpi kurulumuna geciliyor..."

  if [ "$iss" = "superonline" ]; then
    echo "byedpictl superonline kurulum scripti calistiriliyor..."
    sudo bash make-superonline.sh install
  elif [ "$iss" = "diger" ]; then
    echo "byedpictl kurulum scripti calistiriliyor..."
    sudo bash make.sh install
  fi
}

byedpi-aktiflestir() {
  if command -v byedpictl &> /dev/null; then
    echo "byedpictl otomatik olarak baslatiliyor..."
    sudo byedpictl tun start
  else
    echo "byedpictl bulunamadi..."
  fi
}

acikla
paket-yonetici-tanimla
ubuntu-check
iss-check
iss-profil-uygula
dnscrypt-check
zenity-check
dns-none
resolv-conf
dnscrypt-config
byedpi-setup
dns-degis
systemd-service
byedpi-aktiflestir

echo "ByeDPI kuruldu. Sisteminizden byedpictl uygulamasini acarak ilk seferde aktiflestirebilirsiniz."
if [[ -f /etc/systemd/system/byedpi-start.service ]]; then
  echo "ONEMLI: Sisteminiz yeniden basladiginda byedpictl otomatik olarak aktiflestirilecektir. Bunu devre disi birakmak istiyorsaniz 'sudo systemctl disable byedpi-start' yazin."
fi
