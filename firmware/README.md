# firmware/

Her alt klasör, CubeMX ile üretilip STM32CubeIDE'ye aktarılan bir STM32 projesidir.

| Proje | Kart / MCU | Amaç |
|---|---|---|
| `hb_f446re_bos/` | NUCLEO-F446RE / STM32F446RE | F0: ilk boş proje — araç zincirinin uçtan uca derlediğini gösterir |

Bir projede repoya girenler: `.ioc` (CubeMX ayarı), `.project`, `.cproject`, `.mxproject`, `Core/`,
`Drivers/` (HAL + CMSIS — temiz klondan derleme için gerekli), bağlayıcı betiği `*.ld`, başlangıç dosyası
`startup_*.s`. Girmeyenler: `Debug/`, `Release/`, `.settings/language.settings.xml`, `*.launch`.
