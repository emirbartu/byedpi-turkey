#!/bin/bash

set -e

iss=""
DNS_NONE="/etc/NetworkManager/conf.d/90-dns-none.conf"

paket-yonetici-tanimla() {
  if [[ -f /bin/pacman ]]; then
    paketyonetici="pacman -S"
    distro="arch tabanli"
  fi

  if [[ -f /bin/dnf ]]; then
    paketyonetici="dnf install"
    distro="fedora tabanli"
  fi

  if [[ -f /bin/apt ]]; then
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

acikla() {
  echo "Bu kurulum sihirbazi once Dnscrypt proxy kurulumu yapacak,"
  echo "Ardindan ise byedpictl kurulumu yapip internet servis saglayiciniza gore duzenleyecektir."
  echo
}

iss-check() {
  read -p "Internet servis saglayiciniz superonline mi? (evet/hayir): " cevap
  cevap=$(echo "$cevap" | tr '[:upper:]' '[:lower:]')

  while [[ "$cevap" != "evet" && "$cevap" != "e" && "$cevap" != "hayir" && "$cevap" != "h" && "$cevap" != "hayır" ]]; do
    echo "Lutfen evet ya da hayir olarak cevaplayin (ya da e/h)."
    read -p "Internet servis saglayiciniz superonline mi? (evet/hayir): " cevap
    cevap=$(echo "$cevap" | tr '[:upper:]' '[:lower:]')
  done

  if [[ "$cevap" =~ ^(evet|e)$ ]]; then
    iss="superonline"
    echo "LOG: Kullanici superonline kullaniyor"
  elif [[ "$cevap" =~ ^(hayir|hayır|h)$ ]]; then
    iss="diger"
    echo "LOG: Kullanici superonline kullanmiyor"
  fi
}

dnscrypt-check() {
  while [[ ! -f /bin/dnscrypt-proxy ]]; do
    echo "Sistemde dnscrypt-proxy tespit edilemedi. Paket yoneticinizle kurulum yapiliyor."
    echo "Lutfen sudo sifresi istenirse girin."
    echo ""
    sudo ${paketyonetici} dnscrypt-proxy
    sleep 2
    echo "dnscrypt-proxy tekrar kontrol ediliyor..."
    if [[ -f /bin/dnscrypt-proxy ]]; then
      echo "Kontrol basarili. Devam ediliyor."
    else
      echo "Kontrol basarisiz. Tekrar deneniyor..."
    fi
  done

  if [[ -f /bin/dnscrypt-proxy ]]; then
    echo "dnscrypt-proxy tespit edildi. Devam ediliyor."
  else
    echo "dnscrypt kurulumunda bir sorun var gibi gorunuyor..."
    exit 1
  fi
}

zenity-check() {
  while [[ ! -f /bin/zenity ]]; do
    echo "Sistemde zenity tespit edilemedi. Paket yoneticinizle kurulum yapiliyor."
    echo "Lutfen sudo sifresi istenirse girin."
    echo ""
    sudo ${paketyonetici} zenity
    if [[ -f /bin/zenity ]]; then
      echo "Kontrol basarili. Devam ediliyor."
    else
      echo "Kontrol basarisiz. Tekrar deneniyor..."
    fi
  done

  if [[ -f /bin/zenity ]]; then
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

acikla
paket-yonetici-tanimla
iss-check
dnscrypt-check
zenity-check
dns-none
resolv-conf
dnscrypt-config
byedpi-setup

echo "ByeDPI kuruldu. Sisteminizden byedpictl uygulamasini acarak aktiflestirebilirsiniz."

