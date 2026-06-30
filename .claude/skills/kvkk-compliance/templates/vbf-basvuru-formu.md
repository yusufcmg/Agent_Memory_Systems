# VERBİS Başvuru Notları

> **VERBİS nedir?**
> Veri Sorumluları Sicili — KVKK Madde 16 uyarınca zorunlu kayıt sistemi.
> URL: https://verbis.kvkk.gov.tr
>
> **Bu dosya bir başvuru formu değildir.** VERBİS'e tarayıcı üzerinden giriş yapılır.
> Bu dosya, başvuruda doldurmanız gereken bilgileri önceden hazırlamanızı sağlar.

---

## Zorunluluk Kontrolü

Önce zorunlu olup olmadığınızı belirleyin:

| Kriter | Evet | Hayır |
|--------|------|-------|
| Çalışan sayısı ≥ 50 | VERBİS zorunlu | — |
| Yıllık net ciro ≥ 25 Milyon TL | VERBİS zorunlu | — |
| Özel nitelikli kişisel veri işleniyor¹ | VERBİS zorunlu | — |
| Diğer tüm durumlar | — | VERBİS isteğe bağlı |

¹ Özel nitelikli: sağlık, biyometrik, genetik, din/mezhep, siyasi görüş, dernek/vakıf üyeliği, cezai mahkumiyet, cinsel yönelim, engellilik

---

## VERBİS'e Giriş

1. https://verbis.kvkk.gov.tr → "Veri Sorumlusu Girişi"
2. MERSİS numaranızla giriş yapın (şirket yetkilileri için)
3. E-Devlet şifresi veya KEP adresiyle kimlik doğrulama

---

## Beyan Edilmesi Gereken Bilgiler

### 1. Veri Sorumlusu Bilgileri

| Bilgi | Değer |
|-------|-------|
| Unvan | [Şirket tam ticari ünvanı] |
| MERSİS No | [10 haneli MERSİS numarası] |
| Vergi No | [Vergi numarası] |
| Adres | [Şirket merkez adresi] |
| Telefon | [Şirket telefonu] |
| E-posta | [kvkk@domain.com] |
| Web sitesi | [https://domain.com] |

### 2. Veri Sorumlusu Temsilcisi (Varsa)

> Türkiye'de yerleşik olmayan yabancı şirketler için zorunlu.
> Yerli şirketler için isteğe bağlı ama tavsiye edilir.

| Bilgi | Değer |
|-------|-------|
| Ad-Soyad | [Temsilci adı] |
| Unvan | [Örn: KVKK Koordinatörü] |
| E-posta | [kvkk@domain.com] |
| Telefon | [Direkt hat] |

---

## Veri İşleme Faaliyetleri (Her Biri Ayrı Kaydedilir)

VERBİS'e her veri işleme faaliyeti için aşağıdaki bilgileri girmeniz gerekir.
`templates/veri-isleme-envanteri.md` dosyanızdaki faaliyetleri buraya aktarın.

### Faaliyet Başvuru Formu

```
Faaliyet Adı: _______________
Amaç: _______________
Kişisel Veri Kategorisi: _______________
İşlenen Kişisel Veriler (tek tek): _______________
İlgili Kişi Grubu: _______________
Yurt İçi Aktarım (Alıcı Grubu): _______________
Yurt Dışı Aktarım:
  - Ülke: _______________
  - Alıcı Grubu: _______________
  - Aktarım Aracı: _______________  (SCC / BCR / Açık Rıza)
Hukuki Sebep: _______________
Saklama Süresi: _______________
Güvenlik Önlemleri: _______________
```

---

## Sık Karşılaşılan Sorunlar

| Sorun | Çözüm |
|-------|-------|
| MERSİS numarası bulunamıyor | Ticaret sicil müdürlüğünden alın |
| E-Devlet şifresi yok | PTT'den veya e-devlet.gov.tr'den alın |
| KEP adresi yok | Kayıtlı e-posta: PTT veya Türk Telekom KEP hizmetinden edinin |
| "Yetkisiz erişim" hatası | Yetki verilmiş kişiyle giriş yapın |
| Faaliyet kategorisi eşleşmiyor | KVKK'nın yayınladığı kategori listesini kullanın |

---

## Güncelleme Yükümlülüğü

VERBİS kaydınızı aşağıdaki durumlarda **30 gün içinde** güncelleyin:

- [ ] Yeni veri işleme faaliyeti başladığında
- [ ] Mevcut faaliyet değiştiğinde (amaç, veri kategorisi, alıcı)
- [ ] Faaliyet sona erdiğinde (faaliyet kapatılır)
- [ ] Şirket adresi, unvanı veya yetkilisi değiştiğinde
- [ ] Veri Sorumlusu Temsilcisi değiştiğinde

---

## Önemli Tarihler ve Cezalar

| Konu | Detay |
|------|-------|
| Kayıt yaptırmama cezası | 20.000 TL – 1.000.000 TL (2024 yılı bandı) |
| Güncelleme yapmama cezası | 20.000 TL – 1.000.000 TL |
| Kayıt son gün | Eşiği aştığınız tarihten 30 gün sonra |

> Ceza bantları her yıl yeniden değerleme katsayısıyla güncellenir.
> Güncel tutarlar için: https://www.kvkk.gov.tr/Icerik/6749/Para-Cezalari

---

## VERBİS Kaydı Sonrası Kontrol Listesi

- [ ] VERBİS onay belgesi indirildi ve dosyalandı
- [ ] Onay belgesi numarası aydınlatma metnine eklendi
- [ ] Tüm veri işleme faaliyetleri sisteme girildi
- [ ] Yurt dışı aktarımlar için SCC belgesi dosyalandı
- [ ] Yıllık kontrol takvimi oluşturuldu
- [ ] Veri Sorumlusu Temsilcisi atandı (gerekiyorsa)

---

## İlgili Kaynaklar

- VERBİS portalı: https://verbis.kvkk.gov.tr
- KVKK rehberleri: https://www.kvkk.gov.tr/Icerik/1011/Yayinlar
- Soru & Cevap: https://www.kvkk.gov.tr/Icerik/4232/Sikca-Sorulan-Sorular
- İletişim: 0312 216 50 50 / iletisim@kvkk.gov.tr
