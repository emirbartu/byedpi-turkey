#!/bin/bash

set -e

iss=""

echo "Bu kurulum dosyasi once Dnscrypt proxy kurulumu yapacak,"
echo "Ardindan ise byedpictl kurulumu yapip internet servis saglayiciniza gore duzenleyecektir."
echo
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

while [[ ! -f /bin/dnscrypt-proxy ]]; do
    echo "Sistemde dnscrypt-proxy tespit edilemedi. Pacman ile kurulum yapiliyor."
    echo "Lutfen sudo sifresi istenirse girin."
    echo ""
    sudo pacman -S dnscrypt-proxy
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

while [[ ! -f /bin/zenity ]]; do
    echo "Sistemde zenity tespit edilemedi. Pacman ile kurulum yapiliyor."
    echo "Lutfen sudo sifresi istenirse girin."
    echo ""
    sudo pacman -S zenity
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


echo "networkmanager dns-none ayarlaniyor..."
echo "Lutfen sudo sifresi istenirse girin."

sudo cp configs/90-dns-none.conf /etc/NetworkManager/conf.d/90-dns-none.conf

echo "resolv.conf dosyasi guncelleniyor..."
echo "UYARI: mevcut resolv.conf dosyasinin uzerine yazilacaktir. Orijinal resolv.conf yedekleniyor..."

sudo cp /etc/resolv.conf /etc/resolv.conf.bak
sudo cp configs/resolv.conf /etc/resolv.conf

echo "dnscrypt-proxy configi kuruluyor..."

sudo cp configs/dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml

echo "dnscrypt-proxy'i dogru sekilde kullanmak icin masaustu ortaminizin ayarlarindan dns'i 127.0.0.1 olarak ayarlamalisiniz."
echo "nasil yapilacagini bilmiyorsaniz rehber videosuna bakabilirsiniz."

echo "dnscrypt-proxy konfigure edildi. Servisler baslatiliyor."
sudo systemctl enable dnscrypt-proxy.service
sudo systemctl start dnscrypt-proxy.service

echo "dnscrypt-proxdy kurulumu ve konfigrasyonu tamamen tamamlandi. byedpi kurulumuna geciliyor..."

if [ "$iss" = "superonline" ]; then
    echo "byedpictl superonline kurulum scripti calistiriliyor..."
    sudo bash make-superonline.sh install
elif [ "$iss" = "diger" ]; then
    echo "byedpictl kurulum scripti calistiriliyor..."
    sudo bash make.sh install
fi

echo "ByeDPI kuruldu. Sisteminizden byedpictl uygulamasini acarak aktiflestirebilirsiniz."