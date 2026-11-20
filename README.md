# hyperbee-fw

İTÜ HYPERBEE (Hyperloop) takımının **STM32 gömülü yazılım** deposu.
Sensör sürücüleri, kontrol döngüleri ve RS-485 paketleyici gibi işler bu temelin üzerine kurulacak.

> Durum: **Faz F0** — geliştirme ortamı kuruldu, ilk boş proje derlendi.
> Teslim notu ve delil: [`docs/F0-teslim.md`](docs/F0-teslim.md)

## Hedef donanım
| | |
|---|---|
| MCU | STM32F446RE (Arm Cortex-M4F, 180 MHz, 512 KB Flash, 128 KB RAM) |
| Kart | NUCLEO-F446RE |

## Klasörler
```
hyperbee-fw/
├─ README.md          bu dosya
├─ .gitignore         derleme çıktıları ve kişisel ayarlar repoya girmez
├─ .gitattributes     satır sonu kuralları (Windows/Linux karışmasın)
├─ docs/
│   ├─ kurulum.md     araçların kurulumu, sürümler, karşılaşılan sorunlar
│   ├─ F0-teslim.md   F0 teslim notu
│   └─ delil/         derleme günlükleri, ekran görüntüleri
├─ firmware/
│   └─ hb_f446re_bos/ NUCLEO-F446RE ilk (boş) proje — CubeMX + CubeIDE
├─ libs/              ileride: ortak sürücüler ve kütüphaneler
└─ tools/
    └─ build.ps1      komut satırından (headless) derleme
```

## Araçlar ve sürümler
| Araç | Sürüm | Kaynak |
|---|---|---|
| STM32CubeIDE | 2.3.0 (build 29909_20261112_1330) | https://www.st.com/en/development-tools/stm32cubeide.html |
| STM32CubeMX | 6.19.0 | https://www.st.com/en/development-tools/stm32cubemx.html |
| GNU Tools for STM32 (GCC) | 14.3.1 (14.3.rel1) — CubeIDE ile gelir | — |
| GNU Make | 4.4.1 — CubeIDE ile gelir | — |

Hepsi ücretsiz ve resmî ST araçlarıdır. Kurulum adımları: [`docs/kurulum.md`](docs/kurulum.md).
CubeIDE 2.0'dan beri CubeMX IDE'nin içinde değildir; ikisi ayrı kurulur.

## Nasıl derlenir
**1. Arayüzden (CubeIDE):** `File → Import → General → Existing Projects into Workspace` →
`firmware/hb_f446re_bos` → projeyi seç → `Project → Build Project`. Konsolda `0 errors` görülmeli.

**2. Komut satırından (headless):** depo kökünde
```powershell
powershell -ExecutionPolicy Bypass -File tools\build.ps1
```
Betik CubeIDE'yi `C:\ST\STM32CubeIDE_<sürüm>` altında bulur (başka yerdeyse `-CubeIdeDir` ya da
`CUBEIDE_DIR`), projeyi geçici bir çalışma alanında temizleyip derler, `.elf` boyutunu yazdırır ve
günlüğü `build/` altına kaydeder. Başarısızsa çıkış kodu 1'dir.

## Kurallar
- Yollar **boşluksuz ve ASCII** olmalı (ör. `C:\Users\<ad>\dev\hyperbee-fw`). GNU make boşluklu ya da
  Türkçe karakterli yolda bozulabilir.
- Derleme çıktıları (`Debug/`, `Release/`, `*.elf`, `*.o` …) ve kişisel IDE ayarları repoya girmez.
- CubeMX'in ürettiği dosyalarda kendi kodunu yalnızca `/* USER CODE BEGIN */ … /* USER CODE END */`
  arasına yaz; yeniden üretimde diğer kısımlar silinir.
- Takımın sürüm ve adlandırma kuralı henüz paylaşılmadı; şimdilik `main` dalı ve açıklayıcı commit
  mesajları kullanılıyor. Kural gelince bu bölüm güncellenecek.

## Lisans notu
Kendi kodumuz takıma aittir. Projeye CubeMX'in kopyaladığı ST kodları kendi lisanslarıyla gelir:
STM32F4 HAL **BSD-3-Clause**, CMSIS **Apache-2.0** (dosyalardaki telif başlıkları silinmez).
Araçlar (CubeIDE, CubeMX) ST'nin SLA0048 sözleşmesine tabidir: ST yazılımı yalnızca ST çipleriyle kullanılır.
