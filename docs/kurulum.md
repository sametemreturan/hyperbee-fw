# Geliştirme ortamı kurulumu (Windows)

Bu belge, `hyperbee-fw` deposunu derleyebilmek için gereken araçların **sıfırdan** nasıl kurulduğunu
anlatır. Takımdan biri aynı adımlarla aynı ortamı kurabilmelidir.
İlk kurulum: 2026-11-20, Windows 11, Samet Emre Turan.

## 1. Gerekenler
| Araç | Sürüm | Ne işe yarar |
|---|---|---|
| STM32CubeIDE | **2.3.0** | Kod düzenleme, derleme, hata ayıklama (Eclipse tabanlı). İçinde GCC ve make gelir |
| STM32CubeMX | **6.19.0** | Çip/pin/saat ayarı ve başlangıç kodu üretimi |
| Git | 2.x | Sürüm kontrolü |

Notlar:
- CubeIDE **2.0.0'dan beri CubeMX içermez** → ikisi ayrı indirilip kurulur. ST'nin önerdiği akış:
  CubeMX'te yapılandır → kod üret (Toolchain: STM32CubeIDE) → CubeIDE'de içe aktar.
- CubeMX sayfasında bir de **STM32CubeMX2** var; o yalnızca STM32C5/G5/H7P serileri içindir.
  F4 için **STM32CubeMX (6.x)** indirilir.
- İkisi de ücretsizdir (ST SSS: "free to download and to use"). Lisans: SLA0048.

## 2. İndirme
1. https://www.st.com/en/development-tools/stm32cubeide.html → **Get Software** →
   `STM32CubeIDE-Win` (Windows Installer) → **Get latest**.
2. Lisansı kabul et. **my.st.com** hesabıyla giriş yap (ücretsiz; yoksa aç). Girişsiz yol da var:
   ad + e-posta yazılır, ST 24 saat geçerli bir indirme bağlantısı e-postalar.
3. Aynısını https://www.st.com/en/development-tools/stm32cubemx.html → `STM32CubeMX-Win` için yap.
4. İnen dosyalar: `stm32cubeide_2.3.0-Win-x86_64.exe.zip` (~874 MB),
   `SetupSTM32CubeMX-6.19.0-Win-x86_64.zip` (~621 MB). Her zip'te tek bir `.exe` var.

## 3. Yükleyiciyi doğrula (çalıştırmadan önce)
ST sayfada SHA256 yayımlamıyor; güven **dijital imzayla** sağlanır. Zip'i ayrı bir klasöre aç, sonra:
```powershell
Get-AuthenticodeSignature -LiteralPath "<yol>\stm32cubeide_2.3.0_29909_20261112_1330-Win-x86_64.exe" | Format-List Status, StatusMessage, SignerCertificate
```
Beklenen: `Status = Valid`, imzalayan `CN=STMicroelectronics International N.V.` (CA: DigiCert).
2026-11-20'de görülen değerler:

| Dosya | Status | SHA256 |
|---|---|---|
| `stm32cubeide_2.3.0_29909_20261112_1330-Win-x86_64.exe` | Valid | `412924ED52D8F021F26A6F4A503E88D3DF4EA691A30DA0013677A302B4229256` |
| `SetupSTM32CubeMX-6.19.0.exe` | Valid | `404BC681D7C3252FD5C7C26D5F584AD6DA55A653B9C881307105BEDC47CAE731` |

Sertifika parmak izi (ikisi de): `6548518160EDFA793C1085757CA6046E32EC7571`.
`Valid` değilse **çalıştırma**.

## 4. Kurulum
**CubeIDE**
- Yönetici izni penceresinde yayımcı "STMicroelectronics" olmalı.
- Kurulum yolu varsayılan: `C:\ST\STM32CubeIDE_2.3.0` (boşluksuz — değiştirme).
- Bileşenlerde **ST-LINK drivers** işaretli kalsın (Nucleo kartıyla USB bağlantısı için).
  SEGGER J-Link sürücüsü yalnızca J-Link programlayıcı varsa gerekir.

**CubeMX**
- Varsayılan yol (yönetici gerektirmeyen kurulum): `%LOCALAPPDATA%\Programs\STM32CubeMX`.
- İsteğe bağlı veri toplama onaylarını işaretlemek gerekmez.

**İlk açılış**
- CubeIDE'yi bir kez aç; çalışma alanı varsayılanı `%USERPROFILE%\STM32CubeIDE\workspace_2.3.0`.
  Çalışma alanını **repo klasörünün içine koyma** (kişisel `.metadata/` oluşur).
- `Help → About STM32CubeIDE` → `Version: 2.3.0, Build: 29909_20261112_1330`.
- CubeMX'i bir kez aç ve kapat.

## 5. Kurulumu doğrula (komut satırı)
```powershell
$ide = "C:\ST\STM32CubeIDE_2.3.0\STM32CubeIDE"
Get-ChildItem "$ide\plugins" -Recurse -Depth 4 -Filter arm-none-eabi-gcc.exe | ForEach-Object { & $_.FullName --version | Select-Object -First 1 }
Get-ChildItem "$ide\plugins" -Recurse -Depth 4 -Filter make.exe | ForEach-Object { & $_.FullName --version | Select-Object -First 1 }
```
2026-11-20 çıktısı:
```
arm-none-eabi-gcc.exe (GNU Tools for STM32 14.3.rel1.20251027-0700) 14.3.1 20250623
GNU Make 4.4.1_st_20260330-0700
```
Komut satırı derleyicisinin (headless) çalıştığını görmek için:
```powershell
& "$ide\stm32cubeidec.exe" --launcher.suppressErrors -nosplash -application org.eclipse.cdt.managedbuilder.core.headlessbuild -data "$env:TEMP\ws_test" -help
```
Seçenek listesi yazdırıp 0 koduyla çıkmalı (ilk açılış ~1 dk sürebilir).

## 6. Karşılaşılan durumlar
| Durum | Açıklama / çözüm |
|---|---|
| CubeIDE sürüm notu (RN0114) hâlâ 2.2.0 gösteriyor | 2.3.0 yeni çıkmış (build 2026-11-12); sürüm notu sonra yayımlanıyor. Sorun çıkarsa aynı sayfadan "Select version" ile 2.2.0 kurulabilir |
| CubeMX günlüğünde `Failed to refresh advertisement data` | ST'nin reklam/haber içeriği indirilemedi; işlevi etkilemez. Aynı açılışta `Integrity check success = true` |
| CubeIDE 2.x'te "STM32 Project" sihirbazı yok | Beklenen davranış (CubeMX ayrıldı). Proje CubeMX'te oluşturulup içe aktarılır |
