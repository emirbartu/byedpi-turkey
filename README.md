# byedpi-turkey

Kullanici dostu, Linux icin GoodbyeDPI-Turkey alternatifi.

> [!IMPORTANT]
> Bu uygulamanın kullanımından doğan her türlü yasal sorumluluk kullanan kişiye aittir. Uygulama yalnızca eğitim ve araştırma amaçları ile yazılmış ve düzenlenmiş olup; bu uygulamayı bu şartlar altında kullanmak ya da kullanmamak kullanıcının kendi seçimidir. Açık kaynak kodlarının paylaşıldığı bu platformdaki düzenlenmiş bu proje, bilgi paylaşımı ve kodlama eğitimi amaçları ile yazılmış ve düzenlenmiştir.

> [!NOTE]
> Ubuntu/Debian destegi 6 Eylul itibari ile yapilan testler sonucunda kaldirilmistir. dnscrypt-proxy'nin ubuntu repolarindaki apt'den indirilen versiyonu duzgun calismiyor. Otomatik olarak github'dan dnscrypt-proxy'i cekip kurulum yapan ayri bir script eklenecek. Debian 13'te yeni paket olsa da betikte 'apt kullanan dagitimlar' diye cektigim icin ayir(a)miyorum. Her turlu Pull Request'e acigim :)

Arkaplanda [dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) ve [byedpictl](https://github.com/maximilionus/byedpictl) kullanir, byedpictl dolayisi ile [byedpi](https://github.com/hufrea/byedpi) ve [hev-socks5-tunnel](https://github.com/heiher/hev-socks5-tunnel) de kullanilir.

# Kurulum

Fedora ve Arch
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

# Muhtemel Sorunlar / Sorular

- login.microsoftonline.com gibi spesifik siteler kullanilan yontem nedeniyle yuklenmeyebiliyor. Bu durumda uygulama uzerinden gecici olarak byedpi'i durdurup, login isleminizi bitirip tekrar acabilirsiniz. Yeni bir cozum bulundugunda bu satir kaldirilacaktir.

- Byedpictl grafik arayuzu uygulamalasi acilmiyorsa dagitiminizin paket yoneticisinden ``zenity`` paketini indirmelisiniz. Betik bunu otomatik olarak kuruyor fakat kurulmadigi senaryoda bu sorunu cozecektir. (Ornek: ``sudo dnf install zenity``)

- Sisteminizin interneti giderse bir defa byedpictl'den yeniden baslatmak sorunu cozecektir. Bazen tunnel calisirken server cokebiliyor. Bunu ``sudo byedpictl tun status`` yazarak kontrol edebilirsiniz.

- Tunelleme, sistem uykudan kalktiktan sonra bozulabilir. Uygulama uzerinden bir defa yeniden baslatmak sorunu cozer.

# Komut Satiri

- ``byedpictl``'in tum komutlari kullanilabilir.
```
byedpictl help
byedpictl tun start
byedpictl tun stop
byedpictl tun restart
byedpictl tun status
byedpictl tun change
byedpictl zenity # grafik arayuzunu acar
```

# Atıflar

https://www.youtube.com/watch?v=i5RUTG67aoM - Bana bu yöntemi öğreten kurulum rehberi

https://github.com/cagritaskn/GoodbyeDPI-Turkey - İlham

https://github.com/maximilionus/byedpictl - Orijinal Proje
