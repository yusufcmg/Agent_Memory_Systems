# AMS2 — Yapılacaklar Listesi (v2.0 Geliştirme Planı)

> **Son güncelleme:** 2026-05-04
> **Hedef sürüm:** AMS2 v2.0
> **Branch:** `feat/v2-incident-seo-mobile-models`
> **Genel hedef:** AMS2'yi mobil + niş alan + güvenlik gücüyle ileri taşı, model stratejisini Opus-öncelikli yap, kariyer_radari ve diğer mevcut projelere zarar vermeden senkronize et.

---

## 🎯 Yön ve Felsefe

### Model Stratejisi (Yeni)
Kullanıcı kararı: **"Tercihen Opus, bazı yerlerde Sonnet ve Opus 4.6"**

Dört katmanlı model atama (güncel):

| Tier | Model | Kullanım | Maliyet | Hangi ajanlar |
|---|---|---|---|---|
| **T1** | `claude-opus-4-8` | Kritik mimari + güvenlik + final review | En yüksek | architect, teamlead, security, security-reviewer, incident-response, crypto-trading-strategist |
| **T2** | `claude-sonnet-4-6` | Karmaşık ama rutin işler | Orta | planner, backend, database, performance, deployment, chief-of-staff |
| **T3** | `claude-sonnet-4-6` | Rutin geliştirme | Düşük | frontend, devops, rust-engineer, data-scientist, ml-engineer, mlops-engineer, data-engineer, tdd-guide, code-reviewer, e2e-runner, harness-optimizer, onboarding, loop-operator, startup-launch, dil reviewer'ları |
| **T4** | `claude-haiku-4-5-20251001` | Hızlı/ucuz işler | En düşük | qa-frontend, qa-backend, docs, doc-updater, refactor-cleaner, docs-lookup, *-build-resolver |

**Not:** Tüm 46 ajan frontmatter'da literal model ID taşıyor — session modelini miras almaz.

### Ekosistem Genişlemesi
- **Mobile:** React Native + Compose Multiplatform — iki paralel ajan
- **Niş alan:** Incident response + SEO technical
- **Türkiye spesifik:** KVKK compliance + Iyzico payment (gelecek faz)

### Sync Stratejisi (kariyer_radari Korunması)
- AMS2 değişiklikleri ASLA `bash install.sh` ile mevcut projelere uygulanmayacak (memory-bank silinir)
- Yeni script: `scripts/sync-to-project.sh` — sadece `agents/`, `skills/`, `commands/`, `rules/` günceller; `memory-bank/`'a dokunmaz
- Idempotent (defalarca çalıştırılabilir)

---

## 📦 GÖREVLER

### T-001 — Sync Script: `sync-to-project.sh` ✅ TAMAMLANDI
**Önem:** P0 (diğer her şeyin temeli)
**Süre:** 30 dk
**Atanan:** harness-optimizer agent

**Amaç:** AMS2 güncellemelerini mevcut projelere selektif olarak aktar.

**Davranış:**
- Argüman: hedef proje yolu (default: cwd)
- Kopyalanacak: `agents/*`, `skills/*`, `commands/*`, `hooks/*`, `rules/*`, `scripts/*`
- Korunacak (KOPYALANMAYACAK): `memory-bank/*`, `settings.local.json`, `active-skills.txt`
- Mode: `--dry-run` (default), `--apply`, `--diff` (sadece farkları göster)
- Yedekleme: değişiklikten önce `.claude/.backup-{timestamp}/` oluştur
- Onay: --apply'da kullanıcı "y/N" sorulur

**Test:**
- `~/scratch/ams2-test/` proje yarat → install.sh çalıştır → sync-to-project test et
- kariyer_radari'de `--dry-run` çalıştır → hiçbir kritik dosya değişmeyeceğini doğrula

**DoD:** Script çalışır, memory-bank dokunulmaz, yedek alır, idempotent.

---

### T-002 — Model Stratejisi Güncelleme ✅ TAMAMLANDI
**Önem:** P0
**Süre:** 20 dk
**Atanan:** harness-optimizer agent

**Amaç:** Ajan frontmatter'larında model atamalarını yeni stratejiye göre değiştir.

**Yapılacak değişiklikler:**

| Ajan | Eski | Yeni | Sebep |
|---|---|---|---|
| `architect` | opus | `claude-opus-4-7` | Mimari karar = en yüksek kalite |
| `teamlead` | opus | `claude-opus-4-7` | Final review'da Opus 4.7 değer |
| `security` | **haiku** ⚠️ | `claude-opus-4-7` | Güvenlik için Haiku tehlikeli |
| `security-reviewer` | sonnet | `claude-opus-4-7` | OWASP derinliği için |
| `chief-of-staff` | opus | `claude-opus-4-6` | Triage işi Opus 4.6 yeterli, hız önemli |
| `planner` | sonnet | `claude-opus-4-6` | Feature parçalama Opus 4.6 ile daha iyi |
| `backend` | sonnet | `claude-opus-4-6` | Karmaşık API tasarımı için |
| `database` | sonnet | `claude-opus-4-6` | Schema/migration kararları |
| `performance` | sonnet | `claude-opus-4-6` | Profiling derin reasoning ister |
| `deployment` | sonnet | `claude-opus-4-6` | Production checklist kritik |
| `frontend` | sonnet | sonnet (kalır) | UI rutin |
| `devops` | sonnet | sonnet (kalır) | CI/CD rutin |
| `e2e-runner` | sonnet | sonnet (kalır) | Test yazımı rutin |
| Dil reviewer'lar | sonnet | sonnet (kalır) | Statik analiz Sonnet'le yeterli |
| `tdd-guide` | sonnet | sonnet (kalır) | Pattern-driven |
| `qa-*` | haiku | haiku (kalır) | Test yazımı, hızlı |
| `docs`, `doc-updater` | haiku | haiku (kalır) | Markdown yazımı |
| `refactor-cleaner` | sonnet | haiku | Mekanik dead code temizliği |
| `*-build-resolver` | sonnet | haiku | Compile error fix mekanik |

**Toplam değişen ajan:** 11 (3 yükseltme T1'e, 6 yükseltme T2'ye, 1 düşürme T4'e — refactor-cleaner)

**Risk uyarısı:** Security'yi Haiku'dan Opus 4.7'ye çekmek **maliyeti 60x artırır** o ajan için ama **kullanım sıklığı düşük** (haftada 1-2 kez). Net etki: aylık ~$15-25 artış, ama kalite katlama.

**DoD:** Tüm agent.md'lerde frontmatter güncel, model ID literal yazılmış, README.tr.md'deki Agent Roster tablosu güncel.

---

### T-003 — `incident-response` Ajanı + Skill ✅ TAMAMLANDI
**Önem:** P1
**Süre:** 90 dk
**Atanan:** architect agent (T1 — tasarım) + backend agent (T2 — implementasyon)

**Amaç:** Production incident'larında runbook + post-mortem üreten dedicated agent.

**Eklenecek dosyalar:**
1. `.claude/agents/incident-response.md`
   - Model: `claude-opus-4-7` (kriz anında en iyi reasoning)
   - Trigger: `as incident agent`, `/incident`
   - Tools: Read, Write, Edit, Bash, Grep, Glob
2. `.claude/skills/incident-response/SKILL.md`
3. `.claude/commands/incident.md` — `/incident <severity>` komutu
4. `.claude/skills/incident-response/templates/`:
   - `runbook-template.md`
   - `post-mortem-template.md`
   - `5-why-analysis.md`
   - `severity-matrix.md`

**Skill içeriği — kapsam:**
- **Triage:** P0/P1/P2/P3/P4 severity matrix
- **Containment:** rollback prosedürü (git, docker, k8s, vercel)
- **Communication:** status page update template, stakeholder bildirim template
- **Investigation:** log toplama (Sentry, journalctl, docker logs), correlation ID izleme
- **Root cause:** 5-Why iteratif analiz
- **Post-mortem:** blameless template, action items, ADR otomatik oluşturma
- **Runbook:** sık karşılaşılan incident'lar için step-by-step

**Agent görev kapsamı:**
- Aktif incident → triage + containment yönlendir
- Mitigation sonrası → post-mortem yaz
- Tekrar eden pattern'i ADR'ye dönüştür (`/new-adr` çağırır)
- Memory-bank'e kaydet: `domains/operations/incidents/incident-{date}.md`

**Entegrasyon:**
- Sentry/Datadog/Grafana referans linkleri (config'e env değişkeni ile)
- Slack/Discord webhook template (sadece referans, otomatik gönderim YOK)

**DoD:** Scratch projede `as incident agent` çağrılabiliyor, skill template'leri eksiksiz, 1 örnek post-mortem üretildi.

---

### T-004 — `seo-technical-optimization` Skill ✅ TAMAMLANDI
**Önem:** P1
**Süre:** 60 dk
**Atanan:** docs-lookup agent (Context7 ile güncel SEO standartları çek) + frontend agent

**Amaç:** Teknik SEO denetimi + uygulama desteği.

**Eklenecek dosyalar:**
1. `.claude/skills/seo-technical-optimization/SKILL.md`
2. `.claude/skills/seo-technical-optimization/checklists/`:
   - `core-web-vitals.md`
   - `structured-data-checklist.md`
   - `meta-tags-checklist.md`
3. `.claude/skills/seo-technical-optimization/templates/`:
   - `json-ld-jobposting.json` (Türkiye iş ilanları için — JobPosting schema)
   - `json-ld-organization.json`
   - `json-ld-faq.json`
   - `sitemap-template.xml`
   - `robots-template.txt`

**Skill kapsamı:**
- **Core Web Vitals:** LCP < 2.5s, INP < 200ms, CLS < 0.1 — ölçüm + optimize
- **Structured Data (JSON-LD):**
  - JobPosting (kariyer_radari için kritik)
  - Organization, Person, FAQ, BreadcrumbList
  - Google Rich Results Test entegrasyon adımları
- **Meta tags:** title (60 char), description (155 char), Open Graph, Twitter Cards
- **Canonical + hreflang:** TR/EN i18n
- **Image optimization:** WebP/AVIF, srcset, lazy loading, fetchpriority
- **Sitemap.xml:** dinamik üretim (FastAPI endpoint örneği)
- **robots.txt:** AI scraper engelleme (GPTBot, CCBot, Claude-Web — etik karar) opsiyonel
- **Lighthouse CI:** GitHub Actions entegrasyon yaml örneği
- **Schema.org validator:** otomatik test örneği

**Türkiye'ye özel:**
- Yandex Webmaster + Google Search Console kurulum
- Türkçe karakter URL slug normalizasyonu
- Türk dil flag'i (`hreflang="tr-TR"`)

**DoD:** Skill aktive edildiğinde frontend ajan SEO denetimi yapabiliyor, JSON-LD JobPosting örneği kullanılabilir durumda.

---

### T-005 — `react-native` Ajanı + Skill
**Önem:** P1
**Süre:** 75 dk
**Atanan:** frontend agent (deneyim transferi) + architect agent (mimari karar)

**Amaç:** Mobil uygulama geliştirme — Expo + bare RN seçimi, navigation, build pipeline.

**Eklenecek dosyalar:**
1. `.claude/agents/react-native.md`
   - Model: `claude-sonnet-4-6` (frontend ile aynı tier)
   - Trigger: `as react-native agent`, `as mobile agent`
2. `.claude/skills/react-native-patterns/SKILL.md`
3. `.claude/skills/react-native-patterns/decision-trees/`:
   - `expo-vs-bare.md`
   - `state-management.md` (Redux Toolkit / Zustand / Jotai / TanStack Query)
   - `styling-options.md` (StyleSheet / NativeWind / Tamagui / Restyle)

**Skill kapsamı:**
- **Setup:** Expo SDK, EAS Build, dev client
- **Navigation:** React Navigation 7, deep linking, universal links
- **State + Data:** TanStack Query + AsyncStorage (offline-first)
- **Auth:** SecureStore, biometric (expo-local-authentication), OAuth (expo-auth-session)
- **Push notifications:** Expo Notifications + FCM/APNs
- **PWA → RN migration:** komponent paylaşımı (react-native-web), kod tabanı tek monorepo
- **Performance:** Hermes engine, Reanimated, Skia, FlashList
- **Build & Release:** EAS Build profiles (dev/preview/prod), code signing, OTA updates
- **Test:** Jest + React Native Testing Library, Detox (E2E)
- **App Store/Play Store:** screenshot otomasyonu, metadata, fastlane

**Türkiye'ye özel notlar:**
- App Store Türkiye region payı (yerel kart entegrasyonu için)
- Google Play Türkiye fatura zorunlulukları

**DoD:** Scratch'te `as react-native agent` çağrılabiliyor, Expo setup template'i kullanılabilir.

---

### T-006 — `compose-multiplatform` Ajanı (mevcut skill üzerine)
**Önem:** P2
**Süre:** 45 dk (skill var, sadece agent wrapper)
**Atanan:** architect agent

**Amaç:** Var olan `compose-multiplatform-patterns` skill'ini ajan olarak da çağrılır hale getir.

**Eklenecek dosyalar:**
1. `.claude/agents/compose-multiplatform.md`
   - Model: `claude-sonnet-4-6`
   - Trigger: `as compose agent`, `as kmp agent`, `as multiplatform agent`
   - Mevcut skill'i (`compose-multiplatform-patterns`) zorla aktive eder

**Notlar:**
- Skill zaten kapsamlı (Compose Multiplatform 1.7+, expect/actual, gradle setup)
- Diğer Kotlin skill'leri ile birlikte çalışır: `kotlin-coroutines-flows`, `kotlin-ktor-patterns`
- Android + iOS + Desktop + Web tek codebase

**DoD:** Agent çağrılabiliyor, ilgili Kotlin skill'leri otomatik aktive oluyor.

---

### T-007 — Yeni Skill: `kvkk-compliance` (Türkiye'ye özel) ✅ TAMAMLANDI
**Önem:** P2
**Süre:** 60 dk
**Atanan:** docs-lookup + security-reviewer agent

**Amaç:** Türkiye veri koruma kanunu (KVKK) uyumluluğu — GDPR'den farklı yönler.

**Eklenecek dosyalar:**
1. `.claude/skills/kvkk-compliance/SKILL.md`
2. `.claude/skills/kvkk-compliance/templates/`:
   - `aydinlatma-metni.md` (kullanıcı bilgilendirme — zorunlu)
   - `acik-riza-template.md`
   - `veri-isleme-envanteri.md`
   - `vbf-basvuru-formu.md` (Veri Sorumluları Sicili)

**Kapsam:**
- KVKK 6698 sayılı kanun maddeleri
- VERBİS kayıt zorunluluğu (250+ çalışan veya yıllık 25M TL ciro)
- Açık rıza vs meşru menfaat ayrımı
- Veri ihlali bildirimi (72 saat — KVKK'ya bildirim)
- Yurtdışına veri aktarımı (Cloudflare, Vercel, Supabase için kritik)
- Çocuk verisi (18 yaş altı — Kariyer Radarı'nda öğrenciler dikkat)
- Cookie consent: KVKK + ePrivacy uyumlu banner
- Right to be forgotten — DELETE request akışı
- DPO (Veri Sorumlusu Temsilcisi) gerekleri

**DoD:** Aydınlatma metni ve açık rıza template'leri Türkiye yasalarıyla uyumlu, gözden geçirilmiş.

---

### T-008 — Yeni Skill: `payment-iyzico-patterns` (Türkiye'ye özel)
**Önem:** P3 (gelecek faz, Kariyer Radarı için ileride)
**Süre:** 90 dk
**Atanan:** backend agent

**Amaç:** Türkiye fintech entegrasyonu — Iyzico, PayTR, Param.

**Eklenecek dosyalar:**
1. `.claude/skills/payment-iyzico-patterns/SKILL.md`
2. `.claude/skills/payment-iyzico-patterns/integrations/`:
   - `iyzico-checkout-form.md`
   - `iyzico-3ds.md`
   - `paytr-callback.md`
   - `param-link-payment.md`

**Kapsam:**
- Iyzico Checkout Form vs Iframe vs API
- 3D Secure akışı (zorunlu Türkiye'de)
- Webhook callback signature verify
- Refund / iptal akışı
- B2B fatura entegrasyonu (e-Fatura zorunluluğu)
- BKM Express, Masterpass, Garanti Pay (alternatif ödeme)
- Recurring (subscription) — kart saklama (PCI DSS notları)

**DoD:** Iyzico için minimal FastAPI entegrasyon örneği çalışır halde.

---

### T-009 — Yeni Skill: `observability-stack` ✅ TAMAMLANDI
**Önem:** P2
**Süre:** 50 dk
**Atanan:** devops + backend agent

**Amaç:** Production gözlemlenebilirlik — log, metric, trace üçlüsü.

**Eklenecek dosyalar:**
1. `.claude/skills/observability-stack/SKILL.md`

**Kapsam:**
- **Logging:** structured JSON, correlation ID, log aggregation (Loki, OpenSearch, CloudWatch)
- **Metrics:** Prometheus + Grafana, RED method (Rate, Error, Duration), USE method
- **Tracing:** OpenTelemetry, distributed trace propagation
- **APM:** Sentry (frontend + backend), Datadog APM
- **Alerting:** Grafana Alerts, PagerDuty, Slack webhook
- **Dashboards:** RED dashboard template, business KPI dashboard
- **Self-hosted vs SaaS:** karar matrisi
- **Cost optimization:** sampling stratejileri, log retention

**Türkiye'ye özel:**
- KVKK uyumlu log retention (kişisel veri içeren loglar 6 ay max)
- Sentry self-hosted Türkiye sunucusu kurulumu (yurtdışı veri aktarımı azaltma)

**DoD:** Skill aktif olduğunda devops agent observability setup çıktısı verebiliyor.

---

### T-010 — Yeni Komut: `/sync-from-template` ✅ TAMAMLANDI
**Önem:** P2
**Süre:** 25 dk
**Atanan:** harness-optimizer

**Amaç:** Mevcut bir projeden AMS2'ye değişiklik yansıtma (T-001'in tersi yönü — ters yönlü değişikliklerin de takibi için).

Mevcut projede manuel düzenlediğin bir agent/skill iyileşmesini AMS2 template'ine geri push etmek için.

**Davranış:**
- Proje `.claude/` ile AMS2 template'i karşılaştır
- Sadece **template'te de olan** ama **proje'de modifiye edilmiş** dosyaları göster
- Kullanıcıya: "Bu değişiklikleri AMS2'ye almak ister misin?" sor
- Memory-bank içeriğini yansıtmaz (proje-spesifik)

**DoD:** kariyer_radari'de bir agent değişikliği yapılır, `/sync-from-template` ile AMS2'ye geri yansıtılabilir.

---

### T-011 — README.tr.md ve CLAUDE.md Güncelleme ✅ TAMAMLANDI
**Önem:** P0 (T-002 ve T-003-006 sonrası zorunlu)
**Süre:** 20 dk
**Atanan:** docs agent (haiku)

**Yapılacak:**
- Agent Roster tablosuna 3 yeni satır: incident-response, react-native, compose-multiplatform
- Model tier açıklaması (T1/T2/T3/T4 dağılımı)
- "Ne zaman hangi ajan" karar ağacı bölümü
- Yeni skill listesi: incident-response, seo-technical-optimization, kvkk-compliance, observability-stack
- Yeni komutlar: `/incident`, `/sync-from-template`
- Sync workflow bölümü: AMS2 → kariyer_radari (T-001 ile)
- Türkiye-spesifik özellikler vurgusu (KVKK, Iyzico, Yandex)

**DoD:** README.tr.md tutarlı, CLAUDE.md kısa kalıyor (lean by design), tüm yeni özellikler doğru yerde dökümante.

---

### T-012 — Versiyon Bump + Changelog + Release ✅ TAMAMLANDI
**Önem:** P0 (her şeyin sonunda)
**Süre:** 15 dk

**Yapılacak:**
- `version` 1.x → 2.0 (varsa package.json benzeri yer) ✅
- `CHANGELOG.md` oluştur veya güncelle ✅
- Git tag: `v2.0.0` ✅ (commit: 0e485ad)
- GitHub release notu ⏭️ (opsiyonel — kullanıcı isterse gh release create v2.0.0)
- README badge güncelle ⏭️ (opsiyonel)

**Migration notu:**
v1 → v2 geçiş için kullanıcıya: "Mevcut projelerinde `bash sync-to-project.sh` çalıştır, install.sh DEĞİL."

---

### T-014 — Tam Sistem Denetimi (Sıfırdan Tarama) ✅ TAMAMLANDI
**Önem:** P0
**Süre:** 30 dk
**Commit:** `237a65d`

**Yapılan:**
- 8 ajanın eksik `model:` alanı eklendi (tier sistemi kırıktı, hepsi session modelini miras alıyordu)
  - T1: crypto-trading-strategist → claude-opus-4-8
  - T3: frontend, devops, data-scientist, ml-engineer, mlops-engineer, data-engineer, rust-engineer → claude-sonnet-4-6
- README.md (EN) sayımları düzeltildi: 45→46 ajan, 121→143 skill, 62→65 komut
- README.tr.md sayımları düzeltildi: 125→143 skill, 64→65 komut

---

### T-015 — Kalan 16 Ajanın `model:` Alanı Eklendi ✅ TAMAMLANDI
**Önem:** P0
**Süre:** 15 dk
**Commit:** `6678ddb`

**Yapılan:**
- CLAUDE.md'deki tier tablosunda adı geçmeyen 16 destek ajanının tamamına explicit `model:` alanı eklendi
- T3 (claude-sonnet-4-6): code-reviewer, cpp-reviewer, database-reviewer, e2e-runner, go-reviewer, harness-optimizer, java-reviewer, kotlin-reviewer, loop-operator, onboarding, polars-reviewer, python-reviewer, rust-reviewer, startup-launch, tdd-guide
- T4 (claude-haiku-4-5-20251001): docs-lookup
- Sonuç: **46/46 ajan explicit model alanına sahip** — tier maliyet optimizasyon sistemi tamamen çalışır durumda

---

### T-013 — Post-Release Bütünlük Denetimi ✅ TAMAMLANDI
**Önem:** P0 (yanlış sayımlar kullanıcıya yanlış bilgi verir)
**Süre:** 30 dk
**Commit:** `8830505`

**Yapılan:**
- `sast-cors/SKILL.md` oluşturuldu (CHANGELOG'da vardı ama dosya eksikti)
- `sast-scan/SKILL.md`: duplicate `sast-idor` satırı kaldırıldı, `sast-cors` eklendi; 16→15
- `sast-report/SKILL.md`: `cors-results.md` discovery listesine + coverage tablosuna eklendi
- `commands/sast.md`: 16→15, CORS listede yok → eklendi
- `agents/security.md`: 16→15, CORS coverage satırına eklendi
- `CHANGELOG.md`: `sast-csrf` (var olmayan skill) silindi; 16→15; T2 model "opus-fast" → `claude-sonnet-4-6`
- `CLAUDE.md`: T2 model etiketi "opus-fast" → "sonnet/claude-sonnet-4-6"
- `README.tr.md`: `121 toplam` → `125 toplam` (×2), `16 paralel` → `15 paralel` (×2)

---

## 🗂️ Sıralama ve Bağımlılıklar

```
T-001 (sync script) ─────┐
                         ├──→ T-002 (model güncelleme)
                         │
                         ├──→ T-003 (incident agent)
                         ├──→ T-004 (seo skill)
                         ├──→ T-005 (react-native agent)
                         ├──→ T-006 (compose agent)
                         │
                         ├──→ T-007 (kvkk skill) [opsiyonel]
                         ├──→ T-008 (iyzico skill) [opsiyonel — P3]
                         ├──→ T-009 (observability) [opsiyonel]
                         │
                         ├──→ T-010 (sync-from-template komutu)
                         │
                         └──→ T-011 (docs) → T-012 (release)
```

**Paralel çalıştırılabilir:** T-003, T-004, T-005, T-006 (ayrı dosyalar, çakışma yok)
**Sıralı zorunlu:** T-001 → T-002 → diğerleri → T-011 → T-012

---

## ✅ Doğrulama Checklist (her görev sonrası)

- [ ] Scratch projede `~/scratch/ams2-test/` ile test edildi
- [ ] kariyer_radari'de `--dry-run` ile sync test edildi (memory-bank dokunulmadı mı?)
- [ ] CHANGELOG'a not eklendi
- [ ] Git commit mesajı semantic (feat/fix/docs/chore)
- [ ] Branch'te tutuldu, master'a sadece T-012'de merge

---

## 🚫 Yapılmayacaklar (Kapsam Dışı)

- AMS2'yi modüler plugin sistemine çevirmek (wshobson tarzı) — gelecek v3
- Conductor benzeri free-form memory layer — memory-bank disiplinini bozar
- Generic plugin marketplace — kişisel sistem, marketplace gereksiz
- Multi-language i18n agent (skill yeterli)
- Generic mobile agent (RN ve Compose ayrı tutuldu — daha net)

---

## 📊 Tahmini Toplam İş

| Faz | Görevler | Süre | Maliyet (API) |
|---|---|---|---|
| **Foundation** | T-001, T-002 | 50 dk | ~$2 |
| **Core agents** | T-003, T-004, T-005, T-006 | 4.5 saat | ~$15 (Opus 4.7 kullanım) |
| **Türkiye-spesifik** | T-007, T-008 | 2.5 saat | ~$5 |
| **Operations** | T-009, T-010 | 1.5 saat | ~$3 |
| **Release** | T-011, T-012 | 35 dk | ~$1 |
| **TOPLAM** | 12 görev | ~10 saat | **~$26** |

---

## 🔄 kariyer_radari ile Etkileşim

**Garanti:**
- AMS2 üzerinde çalışırken kariyer_radari'de hiçbir dosya değişmez
- T-001 sonrası kariyer_radari'ye sync etmek istersen `--dry-run` ile önce kontrol et
- memory-bank ASLA dokunulmaz
- settings.local.json korunur (proje-spesifik)

**Tavsiye:**
- AMS2 v2.0 release'ten sonra kariyer_radari'ye sync et
- Sync sonrası kariyer_radari'de `/quality-gate` çalıştır → her şey çalışıyor mu?
- Sorun çıkarsa `.backup-{timestamp}/` dizininden geri al

---

## 📝 İletişim & Hazırlık Notu

**Kullanıcı kararları kayıt:**
1. ✅ Opus tercihi: tier'lı yaklaşım onaylandı (T1 Opus 4.7 + T2 Opus 4.6 + T3 Sonnet)
2. ✅ Compose Multiplatform: skill → agent dönüşüm onaylandı (T-006)
3. ✅ kariyer_radari değişmez kuralı kabul edildi
4. 🟡 KVKK ve Iyzico opsiyonel — kullanıcı onayı bekleniyor
5. 🟡 Observability ve sync-from-template opsiyonel — kullanıcı onayı bekleniyor

**Sonraki adım:** Kullanıcı T-007/T-008/T-009/T-010 ekstra görevlerini onaylasın, sonra T-001'den başlanır.
