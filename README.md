# byedpi-turkey

Kullanici dostu, Linux icin GoodbyeDPI-Turkey alternatifi.

> [!WARNING]
> Projeyi kullanmak tamamen sizin sorumlulugunuzdadir.

> [!WARNING]
> Tamamen egitim amacli yapilmis bir projedir.

> [!NOTE]
> Simdilik sadece Arch Linux icin gecerlidir.
> Fedora destegi zamanla eklenecektir.
> Ubuntu / Debian destegi planlanmamaktadir.

Arkaplanda [dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) ve [byedpictl](https://github.com/maximilionus/byedpictl) kullanir, byedpictl dolayisi ile [byedpi](https://github.com/hufrea/byedpi) ve [hev-socks5-tunnel](https://github.com/heiher/hev-socks5-tunnel) de kullanilir.

# Kurulum

eklenecek

# Muhtemel Sorunlar / Sorular

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