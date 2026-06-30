# Agent Memory System (Universal Edition)

## What Is This?

This repository is **not an application** — it is a **configuration and architecture kit** for [Claude Code](https://docs.anthropic.com/en/docs/claude-code), Anthropic's terminal-based AI coding assistant.

When installed into any project, it transforms a single Claude Code session into a managed, memory-persistent software development team with specialized agents, reusable skills, and persistent project memory — all stored as plain markdown files under `.claude/`.

This repository solves the two biggest problems in standard Claude Code usage:
1. **Context Loss and Bloat:** Instead of dumping everything into one massive log, the system divides work into modular memory-bank markdown files, saving tokens by pruning finalized tasks.
2. **High API Costs:** The `claude` command uses your Claude Pro subscription for quality work, while `ccr code -p` routes routine tasks to ultra-cheap models (DeepSeek, Minimax) via OpenRouter — dramatically cutting costs.

> Based on the Everything Claude Code architecture, enhanced with OpenRouter/CCR support.

---

## What's Included?

This kit gives you access to 46 agents, 143 skills, and 65 commands — all installed under `.claude/` as plain markdown files.

| Category | Count |
|----------|------:|
| Agents | ✅ 46 agents |
| Skills | ✅ 143 skills |
| Commands | ✅ 65 commands |

- **46 Expert Agents:**

  | Invoke with | Agent | Purpose |
  |-------------|-------|---------|
  | `as frontend agent` | frontend | UI components, hooks, state management, responsive design |
  | `as backend agent` | backend | API design, services, authentication, middleware |
  | `as database agent` | database | Schema design, migrations, query optimization |
  | `as devops agent` | devops | Docker, CI/CD, GitHub Actions, deployment scripts |
  | `as deployment agent` | deployment | Pre-deployment checklist, production readiness |
  | `as performance agent` | performance | Bundle analysis, profiling, caching strategy |
  | `as security agent` | security | OWASP Top 10, vulnerability audit (read-only) |
  | `as architect` | architect | System design, ADR creation, architecture decisions |
  | `as teamlead` | teamlead | Code review, merge approval, cross-domain conflicts |
  | `as planner` | planner | Feature decomposition, task breakdown |
  | `as tdd-guide` | tdd-guide | Test-Driven Development, write-tests-first enforcement |
  | `as code-reviewer` | code-reviewer | Quality, security, maintainability review |
  | `as security-reviewer` | security-reviewer | Secrets, injection, OWASP findings |
  | `as qa frontend agent` | qa-frontend | Unit, component, and E2E tests for frontend |
  | `as qa backend agent` | qa-backend | API contract, integration, and DB query tests |
  | `as docs agent` | docs | README, API docs, OpenAPI specs, diagrams |
  | `as docs-lookup` | docs-lookup | Library/framework documentation lookup |
  | `as doc-updater` | doc-updater | Codemaps, documentation updates |
  | `as data scientist` | data-scientist | EDA, feature engineering, model evaluation |
  | `as ml engineer` | ml-engineer | Model training, inference pipelines, optimization |
  | `as mlops engineer` | mlops-engineer | MLflow, experiment tracking, model registry |
  | `as data engineer agent` | data-engineer | ETL pipelines, data warehousing, Polars/Pandas |
  | `as rust engineer` | rust-engineer | Production Rust systems, async/Tokio, FFI |
  | `as trading strategist` | crypto-trading-strategist | Crypto strategy design, backtesting, risk management |
  | `as python-reviewer` | python-reviewer | PEP 8, type hints, security, Pythonic idioms |
  | `as go-reviewer` | go-reviewer | Idiomatic Go, concurrency, error handling |
  | `as rust-reviewer` | rust-reviewer | Ownership, lifetimes, unsafe usage |
  | `as java-reviewer` | java-reviewer | Spring Boot, JPA patterns, security |
  | `as kotlin-reviewer` | kotlin-reviewer | Coroutines, Compose, clean architecture |
  | `as cpp-reviewer` | cpp-reviewer | Memory safety, modern C++ idioms, concurrency |
  | `as polars-reviewer` | polars-reviewer | Lazy API, parallelism blockers, pandas anti-patterns |
  | `as database-reviewer` | database-reviewer | PostgreSQL optimization, schema, Supabase |
  | `as build-error-resolver` | build-error-resolver | TypeScript/JS build and type error fixes |
  | `as go-build-resolver` | go-build-resolver | Go build, vet, linter error fixes |
  | `as rust-build-resolver` | rust-build-resolver | Cargo build, borrow checker, linker errors |
  | `as java-build-resolver` | java-build-resolver | Maven/Gradle, Spring Boot build errors |
  | `as kotlin-build-resolver` | kotlin-build-resolver | Kotlin/Gradle build and dependency errors |
  | `as cpp-build-resolver` | cpp-build-resolver | CMake, compilation, template errors |
  | `as e2e-runner` | e2e-runner | Playwright E2E tests, test journeys |
  | `as refactor-cleaner` | refactor-cleaner | Dead code removal, knip/depcheck analysis |
  | `as onboarding` | onboarding | Project init interview, memory-bank creation |
  | `as loop-operator` | loop-operator | Autonomous agent loops, progress monitoring |
  | `as harness-optimizer` | harness-optimizer | Agent harness config analysis |
  | `as chief-of-staff` | chief-of-staff | Email/Slack triage, communication workflows |
  | `as startup launch agent` | startup-launch | Domain setup, server hardening, SSL, nginx, zero-downtime deploy |

  > Each agent has an explicit model assignment based on a 4-tier cost strategy: T1=`claude-opus-4-8` (critical), T2=`claude-sonnet-4-6` (complex), T3=`claude-sonnet-4-6` (routine), T4=`claude-haiku-4-5` (fast/cheap). See `CLAUDE.md` for the full tier table.

- **143 Custom Skills:** TDD loops, E2E test generation, Django/Laravel patterns, Architecture reviews, Deep Research, Polars/Pandas/sklearn/PyTorch/MLflow/Jupyter/Crypto-Trading patterns, and more.
  - Skills are **auto-configured during `/init`** — only skills relevant to your stack are loaded, keeping token overhead minimal.
  - A fresh install starts with **14 universal skills** active (always on: TDD, security, memory, research, etc.).
  - After `/init`, Claude enables only the skills matched to your stack keywords (~20–30 total out of 143).
  - Disabled skills cost **zero tokens** — fully excluded from the context window via `disable-model-invocation: true` in their frontmatter.
- **65 Slash Commands:** `/init`, `/tdd`, `/code-review`, `/learn`, `/new-adr`, language-specific build/test/review commands.
- **Persistent Memory (Memory-Bank):** All architecture decisions (ADR) and tasks are stored under `.claude/memory-bank/`. Ships empty — populated entirely by `/init`.
- **Self-Learning (/learn):** Extract patterns from a successful session to create a new reusable skill.

---

## Installation

### 1. Prerequisites

- **Node.js 18+** installed ([nodejs.org](https://nodejs.org)).
- A terminal application (Mac Terminal, iTerm, Windows PowerShell, or WSL).
- **Windows users:** Use [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) for full compatibility. Native PowerShell is not recommended.

### 2. Install Claude Code CLI

```bash
npm install -g @anthropic-ai/claude-code
```

### 3. Clone and Run

```bash
git clone https://github.com/yusufcmg/Agent_Memory_Systems.git
cd Agent_Memory_Systems
bash install.sh
```

Once complete, the `.claude/` directory with all expert agents will be installed on your machine. You'll still need to run `/init` and configure your OpenRouter key (see below).

> To install into an **existing project**, see [Integrating into an Existing Project](#integrating-into-an-existing-project) below.

---

## API Setup

This system uses two separate commands. Each requires its own one-time setup.

---

### 🔵 Step 1 — Claude Pro Login (for the `claude` command)

For complex, quality coding tasks, use the `claude` command. It connects directly to Anthropic and uses your Claude Pro subscription.

**1.** Go to any project folder and start Claude:
```bash
claude
```

**2.** On first use, authenticate:
```bash
> /login
```

A browser will open → Log in with your Anthropic account (claude.ai) → Authorize → Return to terminal.
*When you see "Login successful", type `/exit` to close.*

> ⚠️ You only need to do this once. Next time you run `claude`, you'll be logged in automatically.

---

### 🟢 Step 2 — OpenRouter API Key (for the `ccr code` command)

For routine tasks like writing tests, reading logs, and code review, use `ccr code`. This routes everything to ultra-cheap models (DeepSeek, Minimax) via OpenRouter.

**1.** Go to [openrouter.ai](https://openrouter.ai/), create an account and generate an API Key (starts with `sk-or-`). Add some credit ($5-10 can last a very long time).

**2.** Open the config file created during installation:
```bash
nano ~/.claude-code-router/config.json
```

**3.** Replace `BURAYA-OPENROUTER-KEY-GIRIN` with your actual key:
```json
{
  "Providers": [
    {
      "name": "openrouter",
      "api_base_url": "https://openrouter.ai/api/v1/chat/completions",
      "api_key": "sk-or-YOUR-ACTUAL-KEY-HERE",
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

> ⚠️ **Important:** Use **OpenRouter model IDs** in the `models` list (e.g. `deepseek/deepseek-chat`). Do NOT use Claude Code's internal aliases (e.g. `claude-sonnet-4-6`) here — they won't work with OpenRouter.

**4.** Press `CTRL+X` → `Y` → `Enter` to save.

**5.** After any config change, restart the CCR service:
```bash
ccr restart
```

---

### 🚀 Step 3 — Initialize the Project

Go to your project folder. **On first setup**, initialize the memory-bank using the `claude` command:

```bash
claude
> /init
```

Claude will ask a few contextual questions about your project (language, framework, database, deployment, etc.). Your answers will:
1. Fill `.claude/memory-bank/` with a permanent, project-specific constitution.
2. **Automatically enable only the skills relevant to your stack** — disabling the other 80+ to keep the context window lean.

You only need to do this **once per project**. The result is printed at the end:
```
✅ MyProject initialized! 28 skills active for your stack.
```

---

## Usage

Once the memory-bank is set up, here's how to work with the agent team:

### Quality Work → `claude`
For complex coding, architecture decisions, and critical features:

```bash
claude -p "as backend agent, create POST /api/auth endpoint"
claude -p "as architect, review the current system design"
```

### Cheap / Routine Work → `ccr code -p "..."`
For writing tests, reading logs, updating docs, small fixes.

> ⚠️ **IMPORTANT:** Always use `ccr code` with the `-p` flag for cheap models (DeepSeek, Minimax). Running it in interactive mode (just `ccr code` and hitting enter) can confuse these models and trap them in a tool loop.

```bash
# ✅ CORRECT — single-shot job
ccr code -p "as qa-backend agent, write tests for the auth endpoint"
ccr code -p "as docs agent, update the API documentation"

# ❌ WRONG — interactive mode may cause issues with cheap models
ccr code
```

*(The QA agent writes tests cheaply via OpenRouter and logs errors to `memory-bank/state/tasks.md`.)*

---

## Integrating into an Existing Project

You can add this system to any project you're already working on:

```bash
cd /path/to/your-existing-project
git clone https://github.com/yusufcmg/Agent_Memory_Systems.git /tmp/ams
cp -r /tmp/ams/{.claude,.claude-code-router,CLAUDE.md,AGENTS.md,install.sh} ./
rm -rf /tmp/ams
bash install.sh
```

Then initialize the memory-bank so the agents understand your codebase:
```bash
claude
> /init
```

> 💡 **Tip:** The agents automatically respect `.gitignore`. Directories like `node_modules/`, `venv/`, `__pycache__/`, `dist/` are never read. For additional exclusions (large data files, media assets), create a `.claudeignore` file in your project root — it works exactly like `.gitignore`.

---

## Updating the System

To pull in the latest agents, skills, and commands **without touching your memory-bank**:

```bash
bash install.sh --update
```

Update mode:
- Overwrites `.claude/agents/`, `.claude/commands/`, `.claude/skills/`, `.claude/scripts/` from source
- Preserves `.claude/memory-bank/` (your project context is never touched)
- Reads `.claude/active-skills.txt` (saved by `/init`) and **automatically re-enables your previous skill set**
- If `active-skills.txt` is missing, all skills are disabled and a prompt to run `/init` is shown

---

## Skill Configuration

Skills are managed by `.claude/scripts/configure-skills.sh`. You normally never call it directly — it runs automatically during `bash install.sh` and after `/init`. But you can run it manually:

```bash
# Re-configure skills after changing your stack
bash .claude/scripts/configure-skills.sh react typescript postgresql docker

# Reset to universal-only (disable all stack skills)
bash .claude/scripts/configure-skills.sh
```

**How it works:**
1. Disables ALL 143 skills (inserts `disable-model-invocation: true` into frontmatter)
2. Re-enables 14 universal skills (always on: TDD, security, memory, research, etc.)
3. Re-enables keyword-matched skills for your stack (57 keywords → 96 skills covered)

**Supported keywords:** `python`, `django`, `fastapi`, `flask`, `react`, `nextjs`, `vue`, `svelte`, `typescript`, `postgresql`, `mysql`, `mongodb`, `sqlite`, `golang`/`go`, `rust`, `kotlin`, `ktor`, `android`, `java`, `springboot`, `laravel`, `php`, `perl`, `swift`/`swiftui`/`ios`, `cpp`, `docker`, `node`, `express`, `vercel`, `aws`, `railway`, `bun`, `mcp`, `ai`, `llm`, `agents`, `exa`, `scraping`, `clickhouse`, `compose`, `polars`, `pandas`, `sklearn`/`scikit`, `pytorch`/`torch`, `mlflow`, `ml`, `datascience`, `jupyter`/`notebook`, `trading`, `crypto`, `quant`

---

## Slash Commands

| Command | What it does |
|---------|-------------|
| `/init` | Initialize project memory and configure stack-relevant skills (first time only per project) |
| `/tdd` | Start a Test-Driven Development loop |
| `/code-review` | Scan the entire codebase for security and performance issues |
| `/sync-memory` | Reconcile memory-bank with current code, prune stale entries |
| `/new-adr` | Create a new Architecture Decision Record |
| `/learn` | Extract patterns from a session to create a new skill |
| `/model` | Switch the active model |

---

## Security

> ⚠️ **Permissions Warning:** This kit enables broad permissions (`Read(**)`, `Write(**)`, `Bash(*)`) so agents can fully operate on your project. Review `.claude/settings.json` before use. Run in a safe environment (not on production machines), and never use it on repositories containing secrets you can't risk overwriting.

> 💡 **Tip:** Try your first run on an empty demo repo. Commit frequently with git so you can quickly rollback if needed.

- **Never commit API keys.** Your OpenRouter key lives only in `~/.claude-code-router/config.json` (your home directory, outside any repo).
- The `install.sh` script adds `.claude-code-router/config.json` to `.gitignore` automatically.
- The `.env.example` file contains only placeholder keys — never real ones.
- All agents obey the rule: *"NEVER write secrets to any file"* (enforced in `CLAUDE.md`).

---

## Troubleshooting / FAQ

| Problem | Solution |
|---------|----------|
| `claude: command not found` | Run `npm install -g @anthropic-ai/claude-code`. Ensure Node.js 18+ is installed. |
| `ccr: command not found` | Run `npm install -g @musistudio/claude-code-router`. |
| npm permission errors | Use `sudo npm install -g ...` on Linux/Mac, or fix npm permissions: [npm docs](https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally). |
| `config.json` not found | Run `bash install.sh` — it creates `~/.claude-code-router/config.json` from the example template. |
| Model errors / "model not found" | Ensure you use **OpenRouter model IDs** (e.g. `deepseek/deepseek-chat`), not Claude Code aliases (e.g. `claude-sonnet-4-6`). |
| Too many skills / high token usage | Run `/init` first — it disables 80+ irrelevant skills automatically. If still hitting limits, run `bash .claude/scripts/configure-skills.sh` with only your actual stack keywords. |
| Tool loop / agent stuck | Never use `ccr code` in interactive mode. Always use `ccr code -p "..."` with a specific task. |
| Config changes not applied | Run `ccr restart` after editing `~/.claude-code-router/config.json`. |
| Windows issues | Use WSL (Windows Subsystem for Linux). Native PowerShell has limited compatibility with Claude Code. |
| Skills reset after update | `bash install.sh --update` restores your skills from `.claude/active-skills.txt`. If missing, re-run `/init`. |

---

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License
