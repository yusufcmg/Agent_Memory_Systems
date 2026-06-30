---
name: observability-stack
description: >
  Production gözlemlenebilirlik: log, metric, trace üçlüsü. Structured logging,
  Prometheus+Grafana RED/USE, OpenTelemetry, Sentry, alerting, KVKK-uyumlu log retention.
  Trigger: "observability setup", "logging strategy", "metrics", "tracing", "APM".
---

# Observability Stack Skill

Production sistemlerini izlemek için üç sütun: **Logs + Metrics + Traces**.
Birini eksik bırakmak blind spot yaratır — üçü birlikte tam gözlem sağlar.

---

## Hangi Araç Ne Zaman

| İhtiyaç | Önerilen | Alternatif |
|---------|---------|-----------|
| Küçük ekip / hızlı başlangıç | Sentry + Grafana Cloud free tier | - |
| Self-hosted / veri egemenliği | Loki + Prometheus + Grafana + Tempo | ELK Stack |
| Enterprise / PaaS tercih | Datadog veya New Relic | Dynatrace |
| Yalnızca frontend | Sentry + Vercel Analytics | LogRocket |
| Yalnızca backend Python | Sentry + structlog + Prometheus | - |

---

## 1. Structured Logging

Her log satırı JSON olmalı. Free-text loglar grep'e bağımlı kılar — sorgu yapılamaz.

### Zorunlu Alanlar

```json
{
  "timestamp": "2026-06-30T10:00:00.123Z",
  "level": "INFO",
  "message": "User applied to job",
  "service": "api",
  "correlation_id": "req-abc-123",
  "user_id": "usr-456",
  "duration_ms": 45
}
```

### Python (structlog)

```python
import structlog

log = structlog.get_logger()

# Her request'te correlation ID bağla
def get_logger(request_id: str):
    return log.bind(correlation_id=request_id)

# Kullanım
logger = get_logger(request.headers.get("X-Request-Id", str(uuid4())))
logger.info("job_application_created", job_id=job.id, user_id=user.id)
```

### FastAPI Middleware (correlation ID otomatik ekleme)

```python
import uuid
from starlette.middleware.base import BaseHTTPMiddleware

class CorrelationIdMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        correlation_id = request.headers.get("X-Request-Id") or str(uuid.uuid4())
        request.state.correlation_id = correlation_id
        response = await call_next(request)
        response.headers["X-Request-Id"] = correlation_id
        return response
```

### Log Seviyeleri

| Seviye | Ne zaman |
|--------|---------|
| DEBUG | Geliştirme ortamında detay — production'da kapalı |
| INFO | Normal iş akışı olayları |
| WARNING | Beklenmedik ama kurtarılabilen durum |
| ERROR | İşlem başarısız — müdahale gerekebilir |
| CRITICAL | Sistem çöküşü — hemen aksiyon gerekli |

---

## 2. Metrics (RED + USE Metodu)

### RED Method (Request-oriented — API ve servisler için)

| Metrik | Açıklama | Alarm eşiği |
|--------|---------|------------|
| **R**ate | İstek/saniye | Trafik anormalliği |
| **E**rror | Hata oranı (%) | > %1 |
| **D**uration | p99 gecikme | > 500ms |

### USE Method (Resource-oriented — altyapı için)

| Metrik | Açıklama | Alarm eşiği |
|--------|---------|------------|
| **U**tilization | CPU/RAM/Disk kullanım % | > %80 |
| **S**aturation | Kuyruk derinliği, bekleme | > 0 (disk fill) |
| **E**rror | Hata sayısı | > 0 kritik hata |

### Prometheus Python

```python
from prometheus_client import Counter, Histogram, start_http_server

REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status_code"]
)

REQUEST_DURATION = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration",
    ["method", "endpoint"],
    buckets=[0.01, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0]
)

# FastAPI ile
@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
    start = time.time()
    response = await call_next(request)
    REQUEST_COUNT.labels(request.method, request.url.path, response.status_code).inc()
    REQUEST_DURATION.labels(request.method, request.url.path).observe(time.time() - start)
    return response

# /metrics endpoint (Prometheus scrape eder)
start_http_server(9090)
```

### Business KPI Metrics

Teknik metriklerle birlikte iş metriklerini de ekleyin:

```python
JOB_APPLICATIONS = Counter("job_applications_total", "Job applications submitted")
ACTIVE_USERS = Gauge("active_users", "Currently active users")
SIGNUP_DURATION = Histogram("user_signup_duration_seconds", "Signup flow duration")
```

---

## 3. Distributed Tracing (OpenTelemetry)

Mikroservis veya birden fazla bağımlılık olan sistemler için zorunludur.

### Setup (Python + FastAPI)

```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

# Provider ve exporter
provider = TracerProvider()
exporter = OTLPSpanExporter(endpoint="http://tempo:4317")  # veya Grafana Cloud
provider.add_span_processor(BatchSpanProcessor(exporter))
trace.set_tracer_provider(provider)

# FastAPI otomatik instrümantas
FastAPIInstrumentor.instrument_app(app)

# Manuel span
tracer = trace.get_tracer(__name__)

async def process_application(job_id: str, user_id: str):
    with tracer.start_as_current_span("process_application") as span:
        span.set_attribute("job.id", job_id)
        span.set_attribute("user.id", user_id)
        # ... iş mantığı
```

### Trace Propagation

HTTP header `traceparent` ile servisler arası iz aktarımı:
```
traceparent: 00-{trace-id}-{span-id}-01
```

Axios veya httpx ile otomatik inject edilir (OTel instrumentation ile).

---

## 4. APM: Sentry

Frontend + backend için birleşik hata takibi.

### Backend (Python)

```python
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration
from sentry_sdk.integrations.sqlalchemy import SqlalchemyIntegration

sentry_sdk.init(
    dsn=os.environ["SENTRY_DSN"],
    integrations=[FastApiIntegration(), SqlalchemyIntegration()],
    traces_sample_rate=0.1,     # %10 trace sampling (maliyet kontrolü)
    profiles_sample_rate=0.05,  # %5 profiling
    environment=os.environ["ENV"],
    send_default_pii=False,     # KVKK: kişisel veri gönderme
)
```

### Frontend (Next.js)

```typescript
// sentry.client.config.ts
import * as Sentry from "@sentry/nextjs";

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  tracesSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0,
  replaysSessionSampleRate: 0.01,  // düşük tut — pahalı
  // KVKK: PII maskeleme
  beforeSend(event) {
    if (event.user) {
      delete event.user.email;
      delete event.user.ip_address;
    }
    return event;
  },
});
```

---

## 5. Alerting

### Grafana Alert Örnekleri

```yaml
# High error rate alert
- name: HighErrorRate
  expr: rate(http_requests_total{status_code=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.01
  for: 2m
  labels:
    severity: critical
  annotations:
    summary: "Error rate > 1% for 2 minutes"

# High latency alert
- name: HighLatency
  expr: histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m])) > 0.5
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "p99 latency > 500ms"
```

### Slack Webhook Alert (Grafana contact point)

Grafana → Alerting → Contact Points → Slack webhook URL ekle.
Mesaj template:
```
🚨 *{{ .GroupLabels.alertname }}* ({{ .CommonLabels.severity }})
{{ range .Alerts }}
- {{ .Annotations.summary }}
{{ end }}
```

---

## 6. Self-Hosted vs SaaS Karar Matrisi

| Kriter | Self-Hosted (Loki+Prometheus+Grafana+Tempo) | SaaS (Datadog/Grafana Cloud) |
|--------|-------------------------------------------|------------------------------|
| Başlangıç maliyeti | Sunucu + DevOps zamanı | Kullanım bazlı ücret |
| Aylık maliyet (orta ölçek) | ~$50-100 (sunucu) | ~$200-500 |
| Veri egemenliği | Tam kontrol | SCC gerekli |
| Kurulum süresi | 2-4 saat | 15 dakika |
| Ölçeklenebilirlik | Manuel (Thanos/Cortex) | Otomatik |
| KVKK uyumu | Kolay (yerli sunucu) | SCCs imzalanmalı |

**Tavsiye:** Küçük takım → Grafana Cloud free tier başlat. >10k req/gün veya veri egemenliği → self-hosted.

---

## 7. KVKK-Uyumlu Log Retention

KVKK kapsamında kişisel veri içeren loglar için:

| Log Türü | İçerik | Maks. Saklama |
|----------|--------|---------------|
| Güvenlik logları (IP, user-agent) | Kişisel veri | **6 ay** |
| İş akışı logları (user_id) | Pseudonym | 1 yıl (imha takvimi) |
| Hata logları (e-posta vs) | Kişisel veri | Hash veya çıkar |
| Teknik loglar (CPU, latency) | Kişisel veri yok | 2 yıl |
| Audit logları (kim ne yaptı) | Kişisel veri | 3 yıl (hukuki) |

**Uygulama:**
```python
# Loglara e-posta asla yazılmaz
logger.info("password_reset_requested", user_id=user.id)  # ✅
logger.info("password_reset_requested", email=user.email)  # ❌ KVKK

# IP: hash'le veya son iki oktet sil
import hashlib
ip_hash = hashlib.sha256(ip.encode()).hexdigest()[:16]
logger.info("login_attempt", ip_hash=ip_hash)
```

**Loki retention config:**
```yaml
# loki-config.yaml
limits_config:
  retention_period: 180d  # 6 ay — kişisel veri barındıran loglar için
```

---

## 8. Hızlı Başlangıç: Docker Compose Stack

```yaml
# docker-compose.observability.yml
services:
  loki:
    image: grafana/loki:2.9.0
    ports: ["3100:3100"]
    volumes: ["./loki-config.yaml:/etc/loki/config.yaml"]

  prometheus:
    image: prom/prometheus:v2.47.0
    ports: ["9090:9090"]
    volumes: ["./prometheus.yml:/etc/prometheus/prometheus.yml"]

  grafana:
    image: grafana/grafana:10.1.0
    ports: ["3000:3000"]
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes: ["grafana-data:/var/lib/grafana"]

  tempo:
    image: grafana/tempo:2.2.0
    ports: ["4317:4317", "3200:3200"]  # OTLP + query

volumes:
  grafana-data:
```

Grafana'da data source olarak Loki + Prometheus + Tempo ekle → unified view.

---

## Checklist: Observability Hazır mı?

- [ ] Tüm loglar structured JSON
- [ ] Her request'e correlation ID ekleniyor
- [ ] Loglarda e-posta / IP / TC kimlik yok (ya hash ya çıkarılmış)
- [ ] RED metrikleri tanımlanmış (rate, error, duration)
- [ ] Hata oranı > %1 için alarm var
- [ ] p99 latency > 500ms için alarm var
- [ ] Sentry DSN backend ve frontend'e eklendi
- [ ] Sentry'de PII maskeleme aktif
- [ ] Log retention 6 ay (KVKK uyumu)
- [ ] Dashboard: RED overview paneli mevcut
- [ ] Alarm bildirimleri test edildi (Slack/PagerDuty)
