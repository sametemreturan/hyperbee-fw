# libs/

Birden fazla firmware projesinin paylaşacağı kod buraya gelecek. Şu an boş (Faz F0).

Planlanan içerik (sonraki fazlar):
- Sensör sürücüleri (ör. IMU, sıcaklık, basınç, konum/hız)
- RS-485 paketleyici (çerçeveleme, CRC, adresleme)
- Ortak yardımcılar (zaman damgası, halka tampon, hata kodları)

Kural: Buradaki kod belirli bir projeye bağlı olmamalı; HAL'e yalnızca ince bir arayüz katmanından erişmeli,
böylece başka STM32 kartına taşınabilir.
