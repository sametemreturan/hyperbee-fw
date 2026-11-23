# F0 Teslim Notu — GOMULU-FW

| | |
|---|---|
| Görev | GitHub repo yapısı kuruldu, CubeIDE bilgisayara kuruldu ve ilk boş proje derlendi |
| Koltuk | GOMULU-FW — STM32 Gömülü Yazılım Mühendisi (Samet Emre Turan) |
| Faz / son tarih | F0 · 2026-11-22 |
| Hazırlanma tarihi | 2026-11-20 (metin düzeltmesi: 2026-11-23) |
| Repo | https://github.com/sametemreturan/hyperbee-fw (private; takım organizasyonu paylaşılınca oraya aktarılabilir) |

## 1. GitHub repo yapısı kuruldu ✔
- Repo: `sametemreturan/hyperbee-fw`, **PRIVATE**, varsayılan dal `main`.
- Yapı: `README.md`, `.gitignore`, `.gitattributes`, `docs/` (kurulum, teslim, delil), `firmware/` (projeler),
  `libs/` (ileride ortak kod), `tools/build.ps1` (komut satırından derleme). Ayrıntı: [README](../README.md).
- Derleme çıktıları ve kişisel IDE ayarları repoda **yok** (`.gitignore`; temiz klonda kontrol edildi).
- Commit kimliği GitHub noreply adresi (kişisel e-posta görünmez).

## 2. STM32CubeIDE kuruldu ✔
| Araç | Sürüm | Delil |
|---|---|---|
| STM32CubeIDE | 2.3.0, build 29909_20261112_1330 | [about_cubeide.png](delil/about_cubeide.png) |
| STM32CubeMX (2.x'ten beri ayrı) | 6.19.0 | `.ioc`: `MxCube.Version=6.19.0` |
| GCC (CubeIDE içinde) | GNU Tools for STM32 14.3.1 | [kurulum.md §5](kurulum.md) |
| STM32Cube FW_F4 | V1.28.3 | `.ioc`: `ProjectManager.FirmwarePackage` |

- Yükleyiciler st.com'dan indirildi; çalıştırılmadan önce **dijital imzaları doğrulandı**
  (`Status = Valid`, imzalayan STMicroelectronics International N.V., CA DigiCert). Ayrıntı ve SHA256: [kurulum.md §3](kurulum.md).
- Kurulum başkası tarafından tekrarlanabilir: [docs/kurulum.md](kurulum.md).

## 3. İlk boş proje derlendi ✔
Proje: `firmware/hb_f446re_bos` — NUCLEO-F446RE (STM32F446RETx), CubeMX'te kartın varsayılan ayarlarıyla
üretildi; elle kod eklenmedi. `main.c` tamamen boş değildir: CubeMX'in kart (BSP) örnek kodunu içerir
(LD2 yanar, B1 düğmesine basılınca durumu değişir). Sistem saati 84 MHz. USART2 pinleri (PA2/PA3) ayarlıdır,
USART2 çevre birimi başlatılmaz.

İki **bağımsız** yoldan derlendi, üçüncü olarak GitHub'dan temiz klonla tekrarlandı:

| Yol | Sonuç | `arm-none-eabi-size` (text / data / bss) | Delil |
|---|---|---|---|
| (a) CubeIDE arayüzü, Project → Build | `0 errors, 0 warnings` | 7320 / 20 / 1572 | [build_ide.png](delil/build_ide.png), [derleme_ide.txt](delil/derleme_ide.txt) |
| (b) Komut satırı, `tools/build.ps1` (headless, temiz derleme) | `0 errors, 0 warnings`, çıkış kodu 0 | 7320 / 20 / 1572 | [derleme_cli.log](delil/derleme_cli.log) |
| (c) GitHub'dan temiz klon + `tools/build.ps1` | `0 errors, 0 warnings`, çıkış kodu 0 | 7320 / 20 / 1572 | [temiz_klon.txt](delil/temiz_klon.txt) |

- (a) ve (b)'nin `.elf` dosyaları **bit bit aynı** (SHA256 `0134557…2023`).
- (c)'nin `.elf`'i yalnızca hata ayıklama bilgisindeki klasör yolu yüzünden farklı; karta yüklenecek görüntü
  (`objcopy -O binary`, 7340 B) **aynı** (SHA256 `D785B27…A74C`).
- Program 512 KB flash'ın ~7,2 KB'ını, 128 KB RAM'in ~1,6 KB'ını kullanıyor.
- ELF başlığı: ELF32, ARM, hard-float ABI, giriş adresi `0x0800081D` (STM32 flash bölgesi).
- **Bağımsız denetim (2026-11-20):** GitHub'dan alınan yeni bir klon, `tools/build.ps1` kullanılmadan doğrudan
  `stm32cubeidec.exe … headlessbuild -build hb_f446re_bos/Debug` komutuyla derlendi: `0 errors, 0 warnings`,
  size 7320 / 20 / 1572; `.isr_vector` `0x08000000`'da, `main` ve `SystemClock_Config` ELF'te var.

## Kapsam dışı / yapılmayanlar
- Karta yükleme (flash) ve hata ayıklama — görev "derlendi" diyor; kart takılınca yapılabilir.
- CI / birim test (T2), DMA / kesme / watchdog (T3), sürücü kodu.
- Takımın sürüm ve adlandırma kuralı henüz paylaşılmadı; varsayılan (`main` + açıklayıcı commit) kullanıldı.

## Nasıl tekrar edilir
```powershell
git clone https://github.com/sametemreturan/hyperbee-fw.git
cd hyperbee-fw
powershell -ExecutionPolicy Bypass -File tools\build.ps1
```
(Önkoşul: [kurulum.md](kurulum.md) — STM32CubeIDE 2.3.0 `C:\ST` altında.)
