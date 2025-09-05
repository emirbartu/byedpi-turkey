# byedpi-turkey

Kullanici dostu, Linux icin GoodbyeDPI-Turkey alternatifi.

> [!WARNING]
> Projeyi kullanmak tamamen sizin sorumlulugunuzdadir.

> [!WARNING]
> Tamamen egitim amacli yapilmis bir projedir.

Arkaplanda [dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) ve [byedpictl](https://github.com/maximilionus/byedpictl) kullanir, byedpictl dolayisi ile [byedpi](https://github.com/hufrea/byedpi) ve [hev-socks5-tunnel](https://github.com/heiher/hev-socks5-tunnel) de kullanilir.

# Kurulum

Tum dagitimlar icin
```
curl https://raw.githubusercontent.com/elrondforwin/byedpi-turkey/refs/heads/master/curl.sh | bash
```

# Nasil Kaldirilir?
```
bash ~/.local/share/byedpi-turkey/kaldir.sh
```
Eger kaldirma scripti duzgun calismazsa ``~/.local/share/byedpi-turkey`` yoluna gidip ``sudo ./make.sh remove`` calistirarak byedpictl'i kaldirabilirsiniz.

isterseniz dnscrypt proxy'i de dagitimizin paket yoneticisinden kaldirabilirsiniz.

# Muhtemel Sorunlar / Sorular

- Sisteminizin interneti giderse bir defa byedpictl'den yeniden baslatmak sorunu cozecektir. Bazen tunnel calisirken server cokebiliyor. Bunu ``sudo byedpictl tun status`` yazarak kontrol edebilirsiniz.

- Tunelleme, sistem uykudan kalktiktan sonra bozulabilir. Uygulama uzerinden bir defa yeniden baslatmak sorunu cozer.

- Sistem her acildiginda uygulama veya komut satiri uzerinden yeniden acmalisiniz. Herkes icin uygun bir cozum bulundugunda eklenecektir.

# Komut Satiri

- ``byedpictl``'in tum komutlari kullanilabilir.
```
byedpictl help
byedpictl tun start
byedpictl tun stop
byedpictl tun restart
byedpictl tun status

byedpictl zenity # grafik arayuzunu acar
```
