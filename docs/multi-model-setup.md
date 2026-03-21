# Multi-Model Setup Guide

Route cheap tasks to cheaper models, keep expensive tasks on Claude.

## Why Bother

| Task | Sonnet cost | Haiku cost | DeepSeek cost |
|------|-------------|------------|---------------|
| Write 100 unit tests | ~$0.15 | ~$0.03 | ~$0.01 |
| Security scan (grep + analyze) | ~$0.08 | ~$0.02 | ~$0.005 |
| Generate API docs | ~$0.12 | ~$0.02 | ~$0.008 |
| Build a React component | ~$0.20 | ❌ weaker | ❌ weaker |

Rule of thumb: **Claude for code that requires judgment. Haiku/DeepSeek for everything mechanical.**

---

## Setup

### Step 1 — Install Claude Code Router

```bash
npm install -g @musistudio/claude-code-router
ccr --version   # verify
```

### Step 2 — Configure providers

Edit `~/.claude-code-router/config.json`:

```json
{
  "LOG": true,
  "API_TIMEOUT_MS": 600000,
  "Providers": [
    {
      "name": "anthropic",
      "api_base_url": "https://api.anthropic.com/v1/messages",
      "api_key": "${ANTHROPIC_API_KEY}",
      "models": [
        "claude-sonnet-4-6",
        "claude-opus-4-6",
        "claude-haiku-4-5-20251001"
      ]
    },
    {
      "name": "deepseek",
      "api_base_url": "https://api.deepseek.com/chat/completions",
      "api_key": "${DEEPSEEK_API_KEY}",
      "models": ["deepseek-chat", "deepseek-reasoner"],
      "transformer": {
        "use": ["deepseek"],
        "deepseek-chat": { "use": ["tooluse"] }
      }
    },
    {
      "name": "openrouter",
      "api_base_url": "https://openrouter.ai/api/v1/chat/completions",
      "api_key": "${OPENROUTER_API_KEY}",
      "models": [
        "qwen/qwen3-coder",
        "qwen/qwen-2.5-coder-32b-instruct",
        "qwen/qwen3-coder:free"
      ],
      "transformer": { "use": ["openrouter", "tooluse"] }
    }
  ],
  "Router": {
    "default":    "anthropic,claude-sonnet-4-6",
    "background": "deepseek,deepseek-chat",
    "think":      "anthropic,claude-opus-4-6",
    "longContext": "anthropic,claude-sonnet-4-6"
  }
}
```

The `${VAR}` syntax reads from your environment — no hardcoded keys.

> **Note on model names:** Agent frontmatter (`.claude/agents/*.md`) uses Claude Code
> aliases (`sonnet`, `opus`, `haiku`) which always resolve to the latest model in that
> family. CCR config uses full model IDs (`claude-sonnet-4-6`, `claude-opus-4-6`) because
> CCR routes to specific provider endpoints. When a new model version is released, update
> the CCR config's model IDs accordingly — agent aliases will auto-resolve.

### Step 3 — Use CCR instead of claude

```bash
ccr code    # replaces: claude
```

Everything else works identically. Same agents, same commands, same slash commands.

---

## Routing Logic

| Router key | When it triggers | Default model |
|------------|-----------------|---------------|
| `default` | All normal requests | `claude-sonnet-4-6` |
| `background` | File searches, simple reads, internal tasks | `deepseek-chat` |
| `think` | When agent uses extended thinking | `claude-opus-4-6` |
| `longContext` | Context >60K tokens | `claude-sonnet-4-6` |

You can switch models mid-session:
```bash
/model deepseek,deepseek-chat          # switch to DeepSeek
/model openrouter,qwen/qwen3-coder     # switch to Qwen
/model anthropic,claude-sonnet-4-6    # switch back to Claude
```

---

## Which Models Support Tool Calling

Tool calling is required for file read/write/bash. Verified working:

| Model | Tool Calling | Notes |
|-------|:-----------:|-------|
| `claude-*` (any) | ✅ | Best tool use, most reliable |
| `deepseek-chat` | ✅ | Needs `tooluse` transformer |
| `qwen/qwen3-coder` | ✅ | Needs `tooluse` transformer via OpenRouter |
| `qwen/qwen-2.5-coder-32b-instruct` | ✅ | Stable, well-tested |
| `deepseek-reasoner` | ⚠️ | Use for analysis only, not file writes |
| `minimax/*` | ❌ | Text only, avoid for agents |

**When in doubt:** if an agent writes files or runs bash, use Claude or a verified tool-capable model.

---

## Free Tier Options

OpenRouter offers free models with daily limits:

```json
"models": ["qwen/qwen3-coder:free", "qwen/qwen3-14b:free"]
```

Useful for: testing the system, light documentation tasks, development environments.  
Not recommended for: production work, complex code generation.

---

## Troubleshooting

**"No endpoints found that support tool_use"**  
→ The model doesn't support tool calling. Switch to `deepseek-chat` or a Claude model.

**Agent seems confused or ignores instructions**  
→ Smaller models are less instruction-following than Claude. Try adding more explicit structure to the task description.

**CCR not routing to the right model**  
→ Check `LOG: true` in config and inspect `~/.claude-code-router/logs/`. Look for which router key triggered.

**API key not found**  
→ CCR reads `${VAR}` from environment. Make sure keys are exported: `export DEEPSEEK_API_KEY=sk-...`
