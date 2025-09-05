# byedpi-turkey

Kullanici dostu, Linux icin GoodbyeDPI-Turkey alternatifi.

> [!IMPORTANT]
> Bu uygulamanın kullanımından doğan her türlü yasal sorumluluk kullanan kişiye aittir. Uygulama yalnızca eğitim ve araştırma amaçları ile yazılmış ve düzenlenmiş olup; bu uygulamayı bu şartlar altında kullanmak ya da kullanmamak kullanıcının kendi seçimidir. Açık kaynak kodlarının paylaşıldığı bu platformdaki düzenlenmiş bu proje, bilgi paylaşımı ve kodlama eğitimi amaçları ile yazılmış ve düzenlenmiştir.

Arkaplanda [dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) ve [byedpictl](https://github.com/maximilionus/byedpictl) kullanir, byedpictl dolayisi ile [byedpi](https://github.com/hufrea/byedpi) ve [hev-socks5-tunnel](https://github.com/heiher/hev-socks5-tunnel) de kullanilir.

# Kurulum

Tum dagitimlar icin
```
curl -fsSL https://raw.githubusercontent.com/elrondforwin/byedpi-turkey/refs/heads/master/curl.sh | bash
```
```
cd ~/.local/share/byedpi-turkey && ./kurulum.sh
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

# Atıflar

https://www.youtube.com/watch?v=i5RUTG67aoM - Bana bu yöntemi öğreten kurulum rehberi
https://github.com/cagritaskn/GoodbyeDPI-Turkey - İlham
https://github.com/maximilionus/byedpictl - Orijinal Proje
