# Changelog

## [2.0.0] — 2026-06-30

### Added

#### Yeni Ajanlar
- **incident-response** (T1 / claude-opus-4-8): Production incident triajı, runbook üretimi, 5-Why RCA, blameless post-mortem. Trigger: `as incident agent`, `/incident P0|P1|P2|post-mortem`

#### Yeni Skill'ler
- **observability-stack**: Structured JSON logging, Prometheus RED/USE metrics, OpenTelemetry distributed tracing, Sentry APM (frontend + backend), Grafana alerting, KVKK-uyumlu 6 aylık log retention
- **seo-technical-optimization**: Core Web Vitals (LCP/INP/CLS), JSON-LD structured data (JobPosting/Organization/FAQ), sitemap + robots.txt, Yandex Webmaster, Türkçe slug normalizasyonu, hreflang tr-TR, Lighthouse CI
- **kvkk-compliance**: KVKK 6698 uyumluluğu, aydınlatma metni, açık rıza, VERBİS başvuru notları, veri işleme envanteri, 72h ihlal bildirimi, KVKK vs GDPR karşılaştırması
- **incident-response** (skill + 4 template): severity-matrix, runbook-template, 5-why-analysis, post-mortem-template

#### Yeni Komutlar
- `/incident <severity>`: Production kriz yönetimi (P0/P1/P2/post-mortem)
- `/sync-from-template`: Projede değiştirilen agent/skill'i AMS2 şablonuna geri yansıt

#### SAST Entegrasyonu (utkusen/sast-skills)
- 16 SAST skill entegre edildi: `sast-sqli`, `sast-xss`, `sast-ssrf`, `sast-rce`, `sast-idor`, `sast-missingauth`, `sast-hardcodedsecrets`, `sast-pathtraversal`, `sast-fileupload`, `sast-ssti`, `sast-xxe`, `sast-jwt`, `sast-businesslogic`, `sast-graphql`, `sast-cors`, `sast-csrf`
- `sast-analysis`: Faz 0 mimari haritalama (sast/architecture.md üretir)
- `sast-report`: Faz 2 paralel bulgu birleştirme → sast/final-report.md
- `sast-scan`: Tam orkestrasyon (Faz 0 → 16 paralel → Faz 2)
- security.md ve security-reviewer.md SAST entegrasyonu ile güncellendi

#### Altyapı
- `scripts/sync-to-project.sh`: AMS2 → Proje güvenli tek yönlü senkronizasyon. memory-bank, settings.local.json, active-skills.txt korunur. Modlar: --dry-run, --apply, --diff. Yedekleme: .backup-{timestamp}/

### Changed

#### Model Stratejisi Güncellemesi (T-002)
Model atamaları 4 kademeye çekildi:
- **T1** (claude-opus-4-8): architect, teamlead, security, security-reviewer, incident-response, crypto-trading-strategist
- **T2** (claude-opus-4-8 fast): backend, database, performance, deployment, planner
- **T3** (claude-sonnet-4-6): frontend, devops, ml-engineer, mlops-engineer, data-engineer, rust-engineer, data-scientist
- **T4** (claude-haiku-4-5): qa-frontend, qa-backend, docs, doc-updater, refactor-cleaner, *-build-resolver

Önemli değişiklik: `security` haiku → T1 opus (güvenlik kararları için Haiku tehlikeliydi)

### Migration (v1 → v2)

⚠️ **Mevcut projelerde `bash install.sh` kullanmayın** — memory-bank silinir.

Bunun yerine:
```bash
bash scripts/sync-to-project.sh <proje-yolu> --apply
```

---

## [1.x.x] — Önceki Sürümler

v1 sürümü için git log geçmişine bakın.
