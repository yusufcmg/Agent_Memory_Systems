# Açık Rıza Formu Şablonu

> **Ne zaman kullanılır:**
> Açık rıza, KVKK kapsamında kişisel veri işlemenin hukuki sebebi olarak yalnızca
> diğer sebepler (sözleşme, kanuni yükümlülük, meşru menfaat) uygun değilse kullanılır.
> Pazarlama iletişimi, profilleme, ve hassas veri işleme için zorunludur.
>
> **Geçerli rıza için gereklilikler (KVKK Madde 3 ve 5):**
> - Belirli konuya özgü (genel rıza geçersiz)
> - Bilgilendirilmiş (kişi ne için rıza verdiğini bilmeli)
> - Özgür irade (reddedilmesi hizmet engeline yol açmamalı)
> - Açık beyan (varsayılan onay/önceden işaretli kutular geçersiz)
> - Geri alınabilir (her zaman, kolayca)

---

## Rıza Formu 1: Pazarlama İletişimi

**Form Başlığı:** Pazarlama İletişimi İzni

**Form Metni:**
```
[ŞİRKET ADI], tarafımla aşağıdaki konularda iletişim kurabilmesi için kişisel 
verilerimin (e-posta adresi, ad-soyad, ilan tercihleri) işlenmesine ve kullanılmasına 
rıza gösteriyorum:

☐ E-posta ile yeni iş ilanı önerileri
☐ Platform güncellemeleri ve özellik duyuruları
☐ Kariyer rehberleri ve içerik bültenleri

Bu rızamı, iletişimlerdeki "Aboneliği İptal Et" bağlantısını kullanarak 
veya hesap ayarlarımdan her zaman geri çekebileceğimi anlıyorum.
Rızamı geri çekmem hizmet almama engel teşkil etmeyecektir.

Aydınlatma Metni'ni okudum ve anladım: [link]
```

**Uygulama Notları:**
- Her seçenek ayrı checkbox (toplu "hepsini kabul et" geçersiz)
- Hiçbiri seçilmeden kayıt tamamlanabilmeli (zorunlu değil)
- Seçimler veritabanında timestamp ile loglanmalı

---

## Rıza Formu 2: Hassas Veri (Varsa)

> Kariyer siteleri için geçerli olabilecek hassas veri: engellilik durumu (EIT kotası için)

**Form Metni:**
```
[ŞİRKET ADI]'nın, işverenlere engelli çalışan kotası uyumluluğu doğrultusunda 
önerilerde bulunabilmesi amacıyla engellilik durumuma ilişkin bilgilerin 
işlenmesine açık rıza veriyorum.

Bu bilgiler yalnızca ilgili amaç için kullanılacak, üçüncü taraflarla 
(başvurduğum şirketler dışında) paylaşılmayacaktır.

Bu rızamı profilim üzerinden her zaman geri çekebilirim.

☐ Engelli birey olduğumu ve bu bilgimin kullanılmasına rıza veriyorum
```

**Uygulama Notları:**
- Hassas veri rızası ayrı ve açık olmalı
- Şifrelenerek saklanmalı
- Erişim logu tutulmalı

---

## Rıza Formu 3: Üçüncü Taraf Paylaşımı

> Başvuru sürecinde CV/özgeçmiş paylaşımı için

**Form Metni:**
```
"[İLAN BAŞLIĞI]" ilanına başvururken, başvuruyu değerlendirmesi amacıyla 
aşağıdaki kişisel verilerimin [ŞIRKET ADI] ile paylaşılmasına rıza veriyorum:

• Ad-soyad, e-posta, telefon
• Yüklediğim CV dosyası
• Platforma girdiğim deneyim ve eğitim bilgileri

Bu bilgilerin yalnızca başvuru sürecinde kullanılacağını, 
başka amaçlarla işlenmeyeceğini anlıyorum.

☐ Bilgilerimin ilgili şirketle paylaşılmasını onaylıyorum
```

---

## Rıza Geri Çekme Akışı (Teknik Uygulama)

```python
# Örnek: Rıza logu veri modeli
class ConsentLog(BaseModel):
    user_id: UUID
    consent_type: str       # "marketing_email", "disability_data", etc.
    action: str             # "granted" | "revoked"
    timestamp: datetime
    ip_address: str         # Hash edilmiş, plain IP saklanmaz
    user_agent: str
    form_version: str       # Hangi rıza formunun hangi versiyonu

# Rıza geri çekme endpoint
@router.post("/kvkk/revoke-consent")
async def revoke_consent(consent_type: str, user: User = Depends(get_current_user)):
    await db.update_consent(user.id, consent_type, "revoked")
    await log_consent(user.id, consent_type, "revoked")
    # Pazarlama listesinden kaldır
    if consent_type == "marketing_email":
        await email_service.unsubscribe(user.email)
    return {"status": "revoked"}
```

---

## Çerez Rızası (Cookie Banner)

Minimum gereksinimleri karşılayan cookie banner implementasyonu:

```html
<!-- Cookie banner örneği - her proje kendi banner'ını uyarlamalı -->
<div id="cookie-banner" class="cookie-banner" role="dialog" aria-label="Çerez Tercihleri">
  <p>
    Hizmetlerimizi sunmak için zorunlu çerezler kullanıyoruz. 
    Analitik ve pazarlama çerezleri için onayınız gereklidir.
    <a href="/cerez-politikasi">Detaylı bilgi</a>
  </p>
  <div class="cookie-actions">
    <button onclick="acceptAll()">Tümünü Kabul Et</button>
    <button onclick="rejectAll()">Tümünü Reddet</button>
    <button onclick="openPreferences()">Tercihleri Ayarla</button>
  </div>
</div>
```

**Cookie banner gereklilikleri:**
- [ ] "Tümünü Kabul Et" ve "Tümünü Reddet" eşit görünürlükte
- [ ] Banner görünmeden analitik/pazarlama çerezleri yüklenmez
- [ ] Tercihler en az 6 ay saklanır
- [ ] Tercihler değiştirilebilir (örn. footer'da "Çerez Tercihleri" linki)
- [ ] Rıza zamanı ve tipi loglanır

---

## Rıza Log Saklama Gereksinimleri

KVKK uyarınca ispat yükümlülüğü veri sorumlusundadır:

```sql
CREATE TABLE consent_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  consent_type VARCHAR(100) NOT NULL,  -- 'marketing_email', 'analytics_cookie', etc.
  action VARCHAR(10) NOT NULL,          -- 'granted', 'revoked'
  granted_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,
  ip_hash VARCHAR(64),                  -- SHA-256 hash, plain IP saklanmaz
  form_version VARCHAR(20) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Rıza logu 5 yıl saklanmalı (ispat için)
-- Yalnızca yetkili personel erişebilmeli
```
