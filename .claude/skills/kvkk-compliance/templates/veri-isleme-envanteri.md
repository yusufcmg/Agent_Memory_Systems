# Veri İşleme Envanteri (Record of Processing Activities)

> **Ne işe yarar:**
> KVKK Madde 10 ve VERBİS yükümlülüğü kapsamında, işlediğiniz kişisel verilerin
> tam listesini ve detaylarını içeren iç belgedir. VERBİS kaydı için de gereklidir.
> Gizli belge — dışarıya ifşa edilmez.
>
> **Güncelleme sıklığı:** Her yeni veri işleme faaliyetinde, en geç yılda 1 kez.

---

## Şirket Bilgileri

| Alan | Bilgi |
|------|-------|
| Şirket adı | [ŞİRKET ADI] |
| VERBİS numarası | [Varsa] |
| Veri Sorumlusu Temsilcisi | [Ad-soyad, unvan] |
| KVKK koordinatörü | [Ad-soyad, e-posta] |
| Son güncelleme | [TARİH] |

---

## Veri İşleme Faaliyetleri

### Faaliyet 1: Kullanıcı Hesabı Yönetimi

| Alan | Detay |
|------|-------|
| **Faaliyet adı** | Kullanıcı üyelik ve hesap yönetimi |
| **Amaç** | Platform hizmetlerine erişim, üyelik kaydı |
| **Hukuki sebep** | Sözleşmenin ifası (KVKK 5/2-c) |
| **Veri kategorileri** | Kimlik (ad, soyad), İletişim (e-posta, telefon) |
| **İlgili kişi kategorisi** | Üye kullanıcılar |
| **Saklama süresi** | Hesap kapatmadan sonra 1 yıl |
| **Alıcılar** | İç teknik ekip |
| **Yurt dışı aktarım** | Hosting sağlayıcısı (SCCs) |
| **Güvenlik önlemleri** | Şifreli depolama, HTTPS, erişim kontrolü |

---

### Faaliyet 2: İş Başvurusu Süreci

| Alan | Detay |
|------|-------|
| **Faaliyet adı** | İş ilanı başvurusu ve iletimi |
| **Amaç** | Adayın işverene başvurusunun iletilmesi |
| **Hukuki sebep** | Sözleşmenin ifası + Açık rıza (CV paylaşımı için) |
| **Veri kategorileri** | Kimlik, iletişim, özgeçmiş (eğitim, deneyim) |
| **İlgili kişi kategorisi** | İş başvurusu yapan kullanıcılar |
| **Saklama süresi** | Başvurudan 2 yıl sonra |
| **Alıcılar** | İlan sahibi şirket (başvuru iletimi) |
| **Yurt dışı aktarım** | Hayır (şirket TR tabanlı ise) |
| **Güvenlik önlemleri** | Erişim logları, şifreli iletim |

---

### Faaliyet 3: Pazarlama İletişimi

| Alan | Detay |
|------|-------|
| **Faaliyet adı** | Abonelik e-posta bülteni |
| **Amaç** | İlan önerileri, platform haberleri gönderimi |
| **Hukuki sebep** | Açık rıza (KVKK 5/1) |
| **Veri kategorileri** | İletişim (e-posta), tercih verileri |
| **İlgili kişi kategorisi** | Rıza veren üye kullanıcılar |
| **Saklama süresi** | Rıza geri alınana kadar |
| **Alıcılar** | E-posta servisi (SCCs ile) |
| **Yurt dışı aktarım** | E-posta sağlayıcısı ABD (SCCs) |
| **Güvenlik önlemleri** | Unsubscribe mekanizması, rıza logu |

---

### Faaliyet 4: Güvenlik ve Log Yönetimi

| Alan | Detay |
|------|-------|
| **Faaliyet adı** | Platform güvenlik logları |
| **Amaç** | Fraud tespiti, hata ayıklama, güvenlik |
| **Hukuki sebep** | Meşru menfaat (KVKK 5/2-f) |
| **Veri kategorileri** | Teknik (IP, user-agent, istek zamanı) |
| **İlgili kişi kategorisi** | Tüm site ziyaretçileri |
| **Saklama süresi** | 6 ay |
| **Alıcılar** | Teknik ekip, yasal talep halinde yetkililer |
| **Yurt dışı aktarım** | Hata takip servisi (SCCs) |
| **Güvenlik önlemleri** | Erişim kısıtlaması, log rotasyonu |

---

### Faaliyet 5: Analitik ve Kullanım Verisi

| Alan | Detay |
|------|-------|
| **Faaliyet adı** | Platform kullanım analizi |
| **Amaç** | Hizmet iyileştirme, kullanıcı deneyimi analizi |
| **Hukuki sebep** | Açık rıza (cookie rızası) |
| **Veri kategorileri** | Teknik (sayfa görüntüleme, tıklama, anonim ID) |
| **İlgili kişi kategorisi** | Rıza veren ziyaretçiler |
| **Saklama süresi** | 13 ay (GA4 varsayılanı) veya daha az |
| **Alıcılar** | Analitik servisi (Google Analytics, vb.) |
| **Yurt dışı aktarım** | ABD (SCCs + DPA) |
| **Güvenlik önlemleri** | IP anonimleştirme, rıza olmadan çalışmama |

---

## Silme/Yok Etme Takvimi

| Veri Kategorisi | Silme Zamanı | Silme Yöntemi |
|-----------------|-------------|---------------|
| Hesap verileri | Kapanmadan 1 yıl sonra | DB'den hard delete |
| Başvuru verileri | Başvurudan 2 yıl sonra | Hard delete |
| Güvenlik logları | 6 ayda bir otomatik | Log rotation |
| Pazarlama verisi | Rıza geri alındığında | Anında silme/kara liste |
| Fatura kayıtları | 10 yıl sonra | Arşivden silme |

---

## Güvenlik Önlemleri Özeti

| Önlem | Durum | Detay |
|-------|-------|-------|
| HTTPS (TLS 1.2+) | ✅ / ❌ | |
| Şifreli veritabanı | ✅ / ❌ | |
| Erişim kontrolü (RBAC) | ✅ / ❌ | |
| Zafiyet taraması | ✅ / ❌ | Son tarih: |
| Penetrasyon testi | ✅ / ❌ | Son tarih: |
| Çalışan eğitimi | ✅ / ❌ | Son tarih: |
| Veri ihlali planı | ✅ / ❌ | |
| Backup şifrelemesi | ✅ / ❌ | |

---

## Revizyon Tarihi

| Tarih | Değişiklik | Değiştiren |
|-------|-----------|-----------|
| [TARİH] | İlk versiyon | [Ad] |
