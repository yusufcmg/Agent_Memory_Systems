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

- **37 Expert Agents:** Frontend, Backend, Database, Security, DevOps, Java/Go/Rust/Python reviewers, TDD Guide, Architect...
- **114 Custom Skills:** TDD loops, E2E test generation, Django/Laravel patterns, Architecture reviews, Deep Research, and more.
- **62 Slash Commands:** `/init`, `/tdd`, `/code-review`, `/learn`, `/new-adr`, language-specific build/test/review commands.
- **Persistent Memory (Memory-Bank):** All architecture decisions (ADR) and tasks are stored under `.claude/memory-bank/`.
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
git clone https://github.com/yusufcmg/Agent_Memory_System.git
cd Agent_Memory_System
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

Go to any project folder. **On first setup**, initialize the memory-bank using the `claude` command:

```bash
claude
> /init
```

The onboarding agent will ask questions about your project (language, framework, database, etc.). Your answers will fill `.claude/memory-bank/` with a permanent, project-specific constitution. You only need to do this **once per project**.

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
git clone https://github.com/yusufcmg/Agent_Memory_System.git /tmp/ams
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

## Slash Commands

| Command | What it does |
|---------|-------------|
| `/init` | Initialize project memory (first time only per project) |
| `/tdd` | Start a Test-Driven Development loop |
| `/code-review` | Scan the entire codebase for security and performance issues |
| `/sync-memory` | Prune agent log directories to save tokens |
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
| 64K token context error | Switch to a model with a larger context window (e.g. DeepSeek Chat has 128K). Check your `Router` config. |
| Tool loop / agent stuck | Never use `ccr code` in interactive mode. Always use `ccr code -p "..."` with a specific task. |
| Config changes not applied | Run `ccr restart` after editing `~/.claude-code-router/config.json`. |
| Windows issues | Use WSL (Windows Subsystem for Linux). Native PowerShell has limited compatibility with Claude Code. |

---

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License
