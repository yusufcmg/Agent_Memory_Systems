# Agent Memory System (Evrensel Sürüm)

## Bu Repo Tam Olarak Ne?

Bu repo **bir uygulama değildir** — [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (Anthropic'in terminal tabanlı yapay zeka kodlama asistanı) için bir **konfigürasyon ve mimari kitidir**.

Herhangi bir projeye kurulduğunda, tek bir Claude Code oturumunu yönetilebilir, hafızası olan ve uzman ajanlardan oluşan bir yazılım geliştirme ekibine dönüştürür. Tüm veriler `.claude/` altında düz markdown dosyaları olarak saklanır.

Bu repo, standart Claude Code kullanımındaki en büyük iki problemi çözer:
1. **Unutkanlık ve Context Şişmesi:** Sistem, yaptığınız işleri devasa bir log dosyasına yazmak yerine parçalı memory-bank (hafıza bankası) markdown dosyalarına böler ve işi biten logları temizleyerek token tasarrufu sağlar.
2. **Yüksek API Maliyetleri:** `claude` komutu Claude Pro hesabınızı kullanırken, `ccr code -p` komutu rutin işleri OpenRouter üzerinden DeepSeek/Minimax gibi çok ucuz modellere yönlendirerek büyük maliyet tasarrufu sağlar.

> Bu proje, Everything Claude Code mimarisini temel alır ve içerisine OpenRouter/CCR desteği eklenerek tak-çalıştır evrensel bir şablona dönüştürülmüştür.

---

## Neler Var?

- **37 Uzman Ajan:** Frontend, Backend, Database, Security, DevOps, Java/Go/Rust/Python Reviewer, TDD Guide, Architect...
- **114 Özel Yetenek (Skill):** TDD Döngüleri, E2E Test Yazımı, Django/Laravel Kalıpları, Mimari İnceleme, Deep Research ve daha fazlası.
  - Yetenekler **`/init` sırasında otomatik yapılandırılır** — yalnızca projenizin stack'ine uygun olanlar aktif edilir, token yükü minimumda tutulur.
  - Taze kurulumda **14 evrensel skill** aktiftir (her zaman açık: TDD, güvenlik, hafıza, araştırma vb.).
  - `/init` sonrasında stack keyword'lerinize göre sadece ilgili skill'ler aktive edilir (~20–30 arası / 114 toplam).
  - Devre dışı skill'ler **sıfır token** tüketir — frontmatter'daki `disable-model-invocation: true` sayesinde context window'a hiç girmezler.
- **62 Slash Komutu:** `/init`, `/tdd`, `/code-review`, `/learn`, `/new-adr`, dil bazlı build/test/review komutları.
- **Kalıcı Hafıza (Memory-Bank):** Tüm mimari kararlarınız (ADR) ve görevleriniz `.claude/memory-bank/` klasöründe tutulur. Boş gelir — `/init` tarafından doldurulur.
- **Kendi Kendine Öğrenme (/learn):** Başarılı bir kodlama seansını sisteme yeni bir "yetenek" olarak öğretebilirsiniz.

---

## Kurulum

### 1. Ön Gereksinimler

- **Node.js 18+** yüklü olmalıdır ([nodejs.org](https://nodejs.org)).
- Terminal uygulamanız olmalıdır (Mac Terminal, iTerm, Windows PowerShell veya WSL).
- **Windows kullanıcıları:** Tam uyumluluk için [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) kullanmanız önerilir. Doğrudan PowerShell tavsiye edilmez.

### 2. Claude Code CLI Kurulumu

Anthropic'in resmi Claude Code aracını bilgisayarınıza global olarak kurun:

```bash
npm install -g @anthropic-ai/claude-code
```

### 3. Bu Repoyu Klonlayın ve Çalıştırın

```bash
git clone https://github.com/yusufcmg/Agent_Memory_Systems.git
cd Agent_Memory_Systems
bash install.sh
```

Kurulum tamamlandığında `.claude/` klasörü ve tüm uzman ajanlar bilgisayarınıza yüklenmiş olacaktır. Kullanmaya başlamak için `/init` çalıştırmanız ve OpenRouter anahtarınızı eklemeniz gerekir (aşağıya bakın).

> Sistemi **mevcut bir projeye** kurmak için aşağıdaki [Mevcut Projeye Entegrasyon](#mevcut-projeye-entegrasyon) bölümüne bakın.

---

## API Anahtarı ve Giriş Ayarı

Bu sistem iki farklı komutla çalışır. Her ikisinin de ayrı bir kurulumu vardır.

---

### 🔵 Adım 1 — Claude Pro Girişi (`claude` komutu için)

Karmaşık, kaliteli kod işleri için `claude` komutunu kullanırsınız. Bu komut doğrudan Anthropic'e bağlanır ve Claude Pro aboneliğinizi kullanır.

**1.** Herhangi bir proje klasörüne gidin ve Claude'u başlatın:
```bash
claude
```

**2.** İlk kullanımda giriş yapın:
```bash
> /login
```

Tarayıcı açılacak → Anthropic hesabınızla (claude.ai) giriş yapın → "Authorize" → terminale dönün.
*"Login successful" mesajını görünce `/exit` ile çıkın.*

> ⚠️ Bu kurulumu bir kez yapmanız yeterlidir. Sonraki seferinde `claude` komutunu çalıştırdığınızda otomatik olarak giriş yapılmış olacaksınız.

---

### 🟢 Adım 2 — OpenRouter Anahtarı (`ccr code` komutu için)

Test yazma, log okuma, kod inceleme gibi rutin ve ucuz işler için `ccr code` komutunu kullanırsınız. Bu komut DeepSeek/Minimax gibi çok ucuz modelleri OpenRouter üzerinden kullanır.

**1.** [openrouter.ai](https://openrouter.ai/) adresine gidin, hesap açın ve bir API Key oluşturun (`sk-or-` ile başlar). OpenRouter'a kredi yükleyin (5-10$ yıllarca yetebilir).

**2.** Kurulum sırasında oluşturulan config dosyasını açın:
```bash
nano ~/.claude-code-router/config.json
```

**3.** `BURAYA-OPENROUTER-KEY-GIRIN` yazan yeri kendi anahtarınızla değiştirin:
```json
{
  "Providers": [
    {
      "name": "openrouter",
      "api_base_url": "https://openrouter.ai/api/v1/chat/completions",
      "api_key": "sk-or-GERCEK-ANAHTARINIZ",
      "models": [
        "deepseek/deepseek-chat",
        "minimax/minimax-m2.5",
        "minimax/minimax-m2.1"
      ],
      "transformer": {
        "use": ["openrouter"],
        "deepseek/deepseek-chat": {
          "use": ["openrouter", "tooluse", "enhancetool"]
        },
        "minimax/minimax-m2.5": {
          "use": ["openrouter"]
        }
      }
    }
  ],
  "Router": {
    "default":    "openrouter,deepseek/deepseek-chat",
    "background": "openrouter,minimax/minimax-m2.1",
    "think":      "openrouter,minimax/minimax-m2.5",
    "longContext": "openrouter,minimax/minimax-m2.5"
  }
}
```

> ⚠️ **Önemli:** `models` listesinde **OpenRouter model ID'lerini** kullanın (`deepseek/deepseek-chat` gibi). Claude Code'un kendi alias'larını (`claude-sonnet-4-6` gibi) buraya yazmayın.

**4.** `CTRL+X` → `Y` → `Enter` ile kaydedin.

**5.** Config değişikliği yaptıktan sonra servisi yeniden başlatın:
```bash
ccr restart
```

---

### 🚀 Adım 3 — Projeyi Başlat

Proje klasörünüze gidin. **İlk kurulumda** `claude` komutuyla memory-bank'ı başlatın:

```bash
claude
> /init
```

Claude, projeniz hakkında birkaç bağlamsal soru soracak (dil, framework, veritabanı, deployment vb.). Cevaplarınız şunları yapacak:
1. `.claude/memory-bank/` içini projenize özel dolduracak — kalıcı proje anayasası oluşturur.
2. **Yalnızca stack'inize uygun skill'leri otomatik aktive edecek** — diğer 80+ skill devre dışı bırakılır, context window lean kalır.

Bunu **yalnızca bir kez** yapmanız gerekir. Sonunda şunu görürsünüz:
```
✅ MyProject initialized! 28 skills active for your stack.
```

---

## Nasıl Kullanılır?

Memory-bank kurulduktan sonra sistemi şöyle kullanırsınız:

### Kaliteli İşler → `claude`
Karmaşık kod yazmak, mimari kararlar, kritik özellikler için:

```bash
claude -p "as backend agent, create POST /api/auth endpoint"
claude -p "as architect, review the current system design"
```

### Ucuz/Rutin İşler → `ccr code -p "..."`

Test yazmak, dosya okumak, log incelemek, küçük düzeltmeler için.

> ⚠️ **ÖNEMLİ:** Ucuz modeller (DeepSeek, Minimax) ile `ccr code`'u **her zaman `-p` flag'iyle** kullanın. İnteraktif modda (sadece `ccr code` yazıp enter'a basarak) açarsanız model kafası karışabilir ve araç döngüsüne (tool loop) girebilir.

```bash
# ✅ DOĞRU — tek seferlik iş komutu
ccr code -p "as qa-backend agent, write tests for the auth endpoint"
ccr code -p "as docs agent, update the API documentation"

# ❌ YANLIŞ — interaktif mod ucuz modelde sorun çıkarabilir
ccr code
```

*(QA ajanı, OpenRouter üzerinden test yazar ve hataları `memory-bank/state/tasks.md` dosyasına kaydeder.)*

---

## Mevcut Projeye Entegrasyon

Sistemi, daha önce geliştirdiğiniz herhangi bir projeye ekleyebilirsiniz:

```bash
cd /path/to/mevcut-projeniz
git clone https://github.com/yusufcmg/Agent_Memory_Systems.git /tmp/ams
cp -r /tmp/ams/{.claude,.claude-code-router,CLAUDE.md,AGENTS.md,install.sh} ./
rm -rf /tmp/ams
bash install.sh
```

Ardından ajanların kod tabanınızı anlaması için memory-bank'ı başlatın:
```bash
claude
> /init
```

> 💡 **İpucu:** Ajanlar otomatik olarak `.gitignore` dosyanıza saygı gösterir. `node_modules/`, `venv/`, `__pycache__/`, `dist/` gibi klasörler hiçbir zaman okunmaz. Ek dışlamalar yapmak istiyorsanız (büyük veri dosyaları, medya dosyaları) proje kök dizininize bir `.claudeignore` dosyası oluşturun — tıpkı `.gitignore` gibi çalışır.

---

## Sistemi Güncelleme

Agents, skill'ler ve komutları **memory-bank'a dokunmadan** güncellemek için:

```bash
bash install.sh --update
```

Güncelleme modu:
- `.claude/agents/`, `.claude/commands/`, `.claude/skills/`, `.claude/scripts/` klasörlerini kaynaktan günceller
- `.claude/memory-bank/` klasörüne **hiç dokunmaz** (proje bağlamınız korunur)
- `.claude/active-skills.txt` dosyasını okuyarak önceki skill setinizi **otomatik geri yükler**
- `active-skills.txt` yoksa tüm skill'ler devre dışı bırakılır ve `/init` çalıştırmanız istenir

---

## Skill Yapılandırması

Skill'ler `.claude/scripts/configure-skills.sh` tarafından yönetilir. Normalde doğrudan çalıştırmanıza gerek yoktur — `bash install.sh` ve `/init` sonrasında otomatik çalışır. Ama manuel de çalıştırabilirsiniz:

```bash
# Stack değiştikten sonra skill'leri yeniden yapılandır
bash .claude/scripts/configure-skills.sh react typescript postgresql docker

# Sadece evrensel skill'lere sıfırla (stack skill'lerini devre dışı bırak)
bash .claude/scripts/configure-skills.sh
```

**Nasıl çalışır:**
1. Tüm 114 skill'i devre dışı bırakır (frontmatter'a `disable-model-invocation: true` ekler)
2. 14 evrensel skill'i yeniden etkinleştirir (her zaman açık: TDD, güvenlik, hafıza, araştırma vb.)
3. Stack'iniz için keyword'e uyan skill'leri etkinleştirir (45 keyword → 84 skill kapsanır)

**Desteklenen keyword'ler:** `python`, `django`, `fastapi`, `flask`, `react`, `nextjs`, `vue`, `svelte`, `typescript`, `postgresql`, `mysql`, `mongodb`, `sqlite`, `golang`/`go`, `rust`, `kotlin`, `ktor`, `android`, `java`, `springboot`, `laravel`, `php`, `perl`, `swift`/`swiftui`/`ios`, `cpp`, `docker`, `node`, `express`, `vercel`, `aws`, `railway`, `bun`, `mcp`, `ai`, `llm`, `agents`, `exa`, `scraping`, `clickhouse`, `compose`

---

## Kullanışlı Komutlar

Claude/CCR sohbetindeyken kullanabileceğiniz komutlar:

| Komut | Ne Yapar? |
|-------|-----------|
| `/init` | Proje hafızasını başlatır ve stack'e uygun skill'leri yapılandırır (yalnızca ilk kurulumda) |
| `/tdd` | Test-Driven Development döngüsü başlatır |
| `/code-review` | Tüm mimariyi güvenlik ve performansa göre tarar |
| `/sync-memory` | Memory-bank'ı güncel kodla uzlaştırır, eski kayıtları temizler |
| `/new-adr` | Yeni bir Mimari Karar Raporu (ADR) oluşturur |
| `/learn` | Başarılı bir seansı yeni bir yetenek olarak sisteme ekler |
| `/model` | Aktif modeli değiştirir |

---

## Güvenlik

> ⚠️ **İzin Uyarısı:** Bu kit, agent'ların projede tam çalışabilmesi için geniş izinler açar (`Read(**)`, `Write(**)`, `Bash(*)`). Kullanmadan önce `.claude/settings.json` dosyasını mutlaka inceleyin. Prod ortamda çalıştırmayın; kritik secret'ı olan repolarda dikkatli kullanın.

> 💡 **Öneri:** İlk denemeyi boş bir demo repo'da yapın. Git ile sık commit alın, gerekirse hızlı rollback yapın.

- **API anahtarlarını asla commit etmeyin.** OpenRouter anahtarınız yalnızca `~/.claude-code-router/config.json` dosyasında (home dizininizde, herhangi bir repo dışında) bulunur.
- `install.sh` betiği `.claude-code-router/config.json` satırını `.gitignore`'a otomatik olarak ekler.
- `.env.example` dosyası yalnızca yer tutucu (placeholder) anahtarları içerir — asla gerçek anahtarlar değil.
- Tüm ajanlar şu kurala uyar: *"Hiçbir dosyaya sır (secret) yazılmayacak"* (`CLAUDE.md` tarafından zorunlu kılınır).

---

## Sorun Giderme / SSS

| Problem | Çözüm |
|---------|-------|
| `claude: command not found` | `npm install -g @anthropic-ai/claude-code` çalıştırın. Node.js 18+ yüklü olmalı. |
| `ccr: command not found` | `npm install -g @musistudio/claude-code-router` çalıştırın. |
| npm izin (permission) hataları | Linux/Mac'te `sudo npm install -g ...` kullanın veya npm izinlerini düzeltin: [npm docs](https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally). |
| `config.json` bulunamadı | `bash install.sh` çalıştırın — örnek şablondan `~/.claude-code-router/config.json` dosyasını oluşturur. |
| Model hatası / "model not found" | **OpenRouter model ID'lerini** kullandığınızdan emin olun (ör. `deepseek/deepseek-chat`). Claude Code alias'ları (ör. `claude-sonnet-4-6`) çalışmaz. |
| Çok fazla skill / yüksek token kullanımı | Önce `/init` çalıştırın — 80+ alakasız skill otomatik devre dışı bırakılır. Hâlâ sorun varsa `bash .claude/scripts/configure-skills.sh` komutunu yalnızca gerçek stack keyword'lerinizle çalıştırın. |
| Tool loop / ajan sıkıştı | `ccr code`'u asla interaktif modda kullanmayın. Her zaman `ccr code -p "..."` ile kullanın. |
| Config değişiklikleri uygulanmıyor | `~/.claude-code-router/config.json` düzenledikten sonra `ccr restart` çalıştırın. |
| Windows sorunları | WSL (Windows Subsystem for Linux) kullanın. Native PowerShell, Claude Code ile sınırlı uyumluluğa sahiptir. |
| Güncelleme sonrası skill'ler sıfırlandı | `bash install.sh --update` skill'leri `.claude/active-skills.txt` dosyasından geri yükler. Dosya yoksa `/init`'i yeniden çalıştırın. |

---

## Katkıda Bulunma

Katkılarınızı bekliyoruz! Detaylar için [CONTRIBUTING.md](CONTRIBUTING.md) dosyasına bakın.

## Lisans

MIT License
