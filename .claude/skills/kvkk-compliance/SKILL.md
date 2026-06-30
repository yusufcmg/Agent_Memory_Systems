---
name: kvkk-compliance
description: >
  Türkiye KVKK (6698 sayılı Kişisel Verilerin Korunması Kanunu) uyumluluk rehberi.
  Aydınlatma metni, açık rıza, VERBİS, veri ihlali bildirimi, yurtdışı aktarım.
  Trigger: "KVKK uyumluluk", "veri koruma", "aydınlatma metni", privacy compliance Turkey.
---

# KVKK Uyumluluk Skill'i

Türkiye Kişisel Verilerin Korunması Kanunu (KVKK - Kanun No. 6698) uyumluluk rehberi.
**Not:** Bu bir hukuki tavsiye değildir. Kritik kararlar için KVKK uzmanı avukata danışın.

## KVKK vs GDPR: Temel Farklar

| Konu | KVKK | GDPR |
|------|------|------|
| Denetim kurumu | Kişisel Verileri Koruma Kurumu (KVKK) | Her ülkenin DPA'sı |
| VERBİS kaydı | Zorunlu (belirli eşikler) | Yok |
| Veri ihlali bildirimi | 72 saat | 72 saat |
| Ceza | %2 net gelir veya TL bazlı | %4 küresel ciro veya €20M |
| Açık rıza | Önceden, bilgilendirilmiş, özgür irade | Aynı |
| Silme hakkı | Var | Var |

## Hangi Veri İşleme Hukuki Sebebi?

```
Kişisel veri işleme için mutlaka bir hukuki sebep gerekir:

1. Açık Rıza           → Pazarlama, profilleme, isteğe bağlı özellikler
2. Kanuni Yükümlülük   → Fatura saklama, vergi, bordro
3. Sözleşme İfası      → Kullanıcının talep ettiği hizmet
4. Meşru Menfaat       → Güvenlik logları, fraud tespiti
5. Hayati Menfaat      → Acil durum (nadiren uygulanır)
6. Kamu Görevi         → Devlet kurumları için

⚠️ Meşru menfaat için LIA (Legitimate Interest Assessment) yapılmalı
```

## Gerekli Belgeler

### Zorunlu (Her Site)
- [ ] **Aydınlatma Metni** — `templates/aydinlatma-metni.md`
- [ ] **Cookie Politikası** — çerez kategorileri ve saklama süreleri
- [ ] **Gizlilik Politikası** — veri kategorileri, aktarımlar, haklar

### Koşullu
- [ ] **Açık Rıza Formu** — `templates/acik-riza-template.md` (pazarlama + profileme için)
- [ ] **VERBİS Beyannamesi** — `templates/vbf-basvuru-formu.md` (zorunlu ise)
- [ ] **Veri İşleme Envanteri** — `templates/veri-isleme-envanteri.md`
- [ ] **Veri İşleme Sözleşmesi** — Üçüncü taraf entegrasyonları için

## VERBİS Kaydı Zorunlu mu?

**Zorunlu değil** eğer:
- Çalışan sayısı < 50 VE yıllık net ciro < 25M TL
- Yalnızca kamu kayıt sistemleri

**Zorunlu** eğer:
- Çalışan sayısı ≥ 50 VEYA yıllık net ciro ≥ 25M TL
- Özel nitelikli kişisel veri işleniyor (sağlık, genetik, biyometrik, cezai kayıt)

→ Kayıt: https://verbis.kvkk.gov.tr

## Üçüncü Taraf Veri Aktarımı (Yurtdışı)

Her yabancı servis için:
```
✅ Gerekli: Yeterli koruma kararı OLAN ülke (Türkiye KVKK'dan onay)
✅ VEYA: Standart Sözleşme Maddeleri (SCCs) imzalı
✅ VEYA: Bağlayıcı Şirket Kuralları (BCRs) onaylı
✅ VEYA: Açık rıza (son çare, rıza geri alınabilir)

Dikkat edilmesi gereken yaygın servisler:
- Vercel (ABD) → SCCs gerekli
- Supabase (ABD) → SCCs gerekli
- Cloudflare (ABD) → SCCs mevcut, imzalayın
- Google Analytics → IP anonimleştirme + DPA imzalayın
- Sentry (ABD) → SCCs + self-hosted alternatif
- Mailchimp/SendGrid → SCCs gerekli
```

## Çocuk Verisi (18 Yaş Altı)

Kariyer sitelerinde öğrenci kullanıcılar olabilir:
- 18 yaş altı için **veli/vasi rızası** gerekir
- Kayıt formunda yaş doğrulama eklenmeli
- 18 yaş altı verileri segment olarak işaretlenmeli

## Cookie Consent Gereksinimleri

```javascript
// Minimum cookie kategorileri
const categories = {
  necessary: true,        // Her zaman aktif, rıza gerekmez
  analytics: false,       // Rıza gerekir (GA, Mixpanel)
  marketing: false,       // Rıza gerekir (Meta Pixel, Google Ads)
  preferences: false,     // Rıza gerekir (tema, dil tercihleri localStorage'da bile)
};

// Banner gereklilikleri
// ✅ Banner yüklemeden önce analitik/pazarlama çerezleri YÜKLENMEZ
// ✅ "Tümünü Kabul Et" ve "Tümünü Reddet" eşit görünürlükte
// ✅ Tercihler değiştirilebilir (footer'da link)
// ✅ Rıza logu tutulur (kim, ne zaman, ne için rıza verdi)
```

## İlgili Kişi Hakları ve Başvuru Akışı

Kullanıcılar şu hakları kullanabilir (KVKK Madde 11):
- Veri işlenip işlenmediğini öğrenme
- Hangi verilerin işlendiğini öğrenme
- İşleme amacını ve amaca uygun kullanımı öğrenme
- Aktarılan üçüncü tarafları öğrenme
- **Düzeltme** hakkı
- **Silme/Yok Etme** hakkı
- İtiraz hakkı (profilleme dahil)
- Zararın giderilmesini talep etme

**Yanıt süresi:** 30 gün (karmaşık durumlarda 60 gün)

## Veri İhlali Protokolü

```
İhlal tespit edildi:
├─ 72 saat içinde → KVKK'ya bildirim (kvkk.gov.tr)
├─ Etkilenen kişilere → makul sürede bildirim
└─ İç kayıt → ihlalin kapsamı, etkisi, alınan önlemler

Bildirime GEREK YOK eğer:
- Veri şifrelenmiş/anonim ve anahtar ele geçirilmemişse
- Risk ihmal edilebilir seviyedeyse (KVKK değerlendirmesi)
```

## Teknik Güvenlik Gereksinimleri

KVKK Madde 12 uyarınca teknik önlemler:

```
Zorunlu:
- [ ] HTTPS (TLS 1.2+)
- [ ] Güçlü parola politikası
- [ ] Erişim kontrolü (least privilege)
- [ ] Veri minimizasyonu (sadece gerekli veri toplanır)
- [ ] Saklama süresi limiti (belirle ve uygula)
- [ ] Pseudonymization / anonymization (mümkünse)
- [ ] Penetrasyon testi (yılda en az 1)
- [ ] Log kayıtları (erişim, değişiklik)
```

## Templates

- `templates/aydinlatma-metni.md` — Kullanıcıya gösterilecek aydınlatma metni
- `templates/acik-riza-template.md` — Pazarlama rıza formu
- `templates/veri-isleme-envanteri.md` — İç veri envanteri
- `templates/vbf-basvuru-formu.md` — VERBİS başvuru notları
