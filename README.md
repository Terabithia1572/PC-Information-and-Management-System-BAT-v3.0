# PC Bilgi ve Yönetim Sistemi (BAT) v3.0

**YUNUS İNAN tarafından geliştirilmiştir.**  
Windows ağında uzak bilgisayarlardan (IP/PC adı) bilgi toplama, analiz ve bazı aksiyon işlemlerini tek bir `.bat` menü üzerinden yapar.

> 📌 Not: Script; Ping/ARP/GETMAC/WMIC/SC/Tasklist/Net View/Shutdown/MSG/PowerShell gibi yerleşik Windows araçlarını kullanır.

---
![Dashboard](screenshots/dashboard1.png)

## Özellikler

### Bilgi Toplama (İzleme)
- **[1] IP + MAC** (Ping + ARP + GETMAC)
- **[2] BIOS Seri Numarası**
- **[3] Disk Bilgileri** (Size / Free)
- **[4] OS Bilgisi** (Version / Build / InstallDate / Arch)
- **[5] Uptime** (Son açılış zamanı)
- **[6] Aktif Kullanıcı + PC Özeti** (Model / Manufacturer / RAM)
- **[7] Son 20 Hotfix** (Güncellemeler)
- **[8] Servis Durumu Sorgula** (Spooler, WinRM vb.)
- **[9] Hızlı Ekran Raporu** (1–7 toplu)
- **[10] Port Kontrol** (TCP port test – PowerShell)

### Müdahale ve Analiz (Aksiyon)
- **[11] Paylaşım Klasörleri** (SMB paylaşım listesi – `net view`)
- **[12] Event Log** (Son 20 hata/uyarı – System log)
- **[13] CPU ve RAM Kullanımı** (LoadPercentage + Memory)
- **[14] Process Listesi** (Tasklist uzak)
- **[15] Servis Yönetimi** (Start/Stop)
- **[16] Otomatik Rapor** (Tarih-saat isimli txt olarak kaydeder)
- **[17] Yüklü Yazılımlar (Envanter)**
- **[18] Yerel Kullanıcıları Listele**
- **[19] Personele Mesaj Gönder** (Popup – `msg`)
- **[20] Güç Yönetimi** (Restart / Shutdown)

---

## Gereksinimler

- Windows 10/11 veya Windows Server
- Aynı ağ / erişilebilir IP
- Uzak makinada aşağıdakiler gerekebilir:
  - **Firewall / ağ izinleri** (WMI, RPC, SMB)
  - **Yönetici yetkisi** (özellikle WMIC, servis yönetimi, yazılım listesi vb.)
  - “File and Printer Sharing” ve “Remote Service Management” kuralları gerekebilir
- Script bazı kontrollerde **kimlik bilgisi** isteyebilir:
  - Menüden **[C] Kimlik Ayarla** ile `DOMAIN\Kullanıcı` / parola tanımlanabilir.

> ⚠️ Not: Bridge / NAT konusu: VM Bridge’de IP alıyor ama DNS/Network politikasına göre internet çıkışı kapalı olabilir. Script çalışması için internet şart değil; hedef IP’ye ulaşmak yeterli.

---

## Kurulum

1. Bu repo’yu indir veya klonla
2. `*.bat` dosyasını **Yönetici olarak çalıştır** (önerilir)
3. Menüden:
   - **[P]** ile hedef PC seç (IP veya PC adı)
   - Gerekirse **[C]** ile kullanıcı/parola gir
   - İstediğin işlemi seç

---

## Kullanım

### Hedef seçme
- Menüde **[P]** → `PC Adı veya IP girin`
- DNS çözümleme yoksa **en garanti yöntem: IP ile** çalışmaktır.

### Kimlik (User/Pass)
- Menüde **[C]**
- Format örnekleri:
  - `DOMAIN\Yunus`
  - `PCADI\Administrator`

---

## Otomatik Rapor

**[16] OTOMATİK RAPOR** seçildiğinde:
- `RAPORLAR\Rapor_<IP>_<YYYY-MM-DD>_<HH-MM>.txt` formatında kayıt oluşturur.
- Yazılım listesi (WMIC product) **uzun sürebilir**.

---

## Güvenlik Notları

- Bu araç **yetki gerektiren** komutlar çalıştırır.
- Parola düz metin tutulur (bat dosyası doğası).  
  ✅ Öneri: Parolayı her seferinde gir, paylaşacağın repoda gerçek parola bırakma.

---

## Sorun Giderme

### “Type the password for …” / “Erişim engellendi”
- Uzak makinede:
  - Yönetici yetkisi yoktur
  - WMI/RPC/SMB firewall engelliyordur
  - LocalAccountTokenFilterPolicy / UAC uzaktan kısıtlaması olabilir
- Çözüm:
  - **[C] Kimlik** girip tekrar dene
  - Uzak makinada WMI/Remote Admin izinlerini kontrol et
  - `Winmgmt` ve `WinRM` servislerinin durumunu kontrol et

### PC adı ile bulunamıyor (DNS/NetBIOS yok)
- IP ile dene
- Alternatif:
  - `hosts` kaydı ekle
  - NetBIOS açık ise ağdan isim çözümleme çalışabilir

### Port test çalışmıyor
- PowerShell engellenmiş olabilir
- Politika kısıtı varsa port testini başka yöntemle yapmak gerekebilir

---

## Lisans
Kurumsal/kapalı kullanım için hazırlanmıştır.

---

## Ekran Görüntüleri
- (Buraya screenshot ekleyebilirsin)
