# Settings & Configuration Guide

This document explains all settings in `.claude/settings.json`, why each value was chosen, their tradeoffs, and how to manage MCP (Model Context Protocol) servers.

---

## Environment Variables (env)

### `MAX_THINKING_TOKENS` — Thinking Token Limit

```json
"MAX_THINKING_TOKENS": "8000"
```

| | |
|---|---|
| **What it does** | Sets the maximum number of tokens Claude can spend on internal "thinking" (reasoning) before generating a response. |
| **Why 8000?** | Default is ~10,000. We reduced it to 8,000 because most agent tasks (read files, write tests, create ADRs) don't require deep reasoning. This saves ~20% per request. |
| **When to increase** | If you're using `architect` or `planner` agents for complex architectural design, increase to `16000` or `32000`. More thinking = better multi-step reasoning. |
| **When to decrease** | For simple tasks like writing tests or reading logs, you can go as low as `4000`. Cheaper, but the model may give shallow answers on complex problems. |

### `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` — Auto-Compaction Threshold

```json
"CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "50"
```

| | |
|---|---|
| **What it does** | When the context window reaches this percentage of capacity, the system automatically summarizes (compacts) older messages to free space. |
| **Why 50%?** | Default is ~80%. We lowered it to 50% because cheap models (DeepSeek, Minimax) have narrower context windows and error out when full. Early compaction prevents 64K token overflow errors. |
| **Tradeoff** | Too aggressive (e.g. 30%) = older conversation details may be lost. Too late (e.g. 90%) = context overflow errors with cheap models. **50% is the safe middle ground.** |
| **With Claude Pro** | If you only use `claude` (Pro), you can increase this to 70-80% — Claude's context window is large, and later compaction preserves more context. |

### `DISABLE_NON_ESSENTIAL_MODEL_CALLS` — Disable Background Calls

```json
"DISABLE_NON_ESSENTIAL_MODEL_CALLS": "1"
```

| | |
|---|---|
| **What it does** | Disables background model calls that Claude Code makes silently (e.g. auto-suggestions, embedding computations). |
| **Why `1` (enabled)?** | Each of these calls consumes tokens and inflates your OpenRouter bill. Keeping them off ensures only your explicit commands use tokens — full cost control. |
| **When to set `0`** | If you want Claude's rich autocomplete and suggestion features, set to `0`. But only do this with `claude` (Pro) — on cheap models it creates unnecessary cost. |

---

## Permissions

The `permissions` block in `settings.json` controls which files agents can access.

### Strategy: Full Access

The system uses a **full access** approach:

```json
"permissions": {
  "allow": ["Read(**)", "Write(**)", "Bash(*)"],
  "deny": []
}
```

This ensures agents never get stuck on permission errors. Regardless of your project structure — `src/`, `packages/`, `modules/`, `api/`, or something entirely different — agents can create, edit, and run commands freely.

### What This Means

| Permission | Description |
|------------|-------------|
| `Read(**)` | Can read all files in the project |
| `Write(**)` | Can write to all files in the project |
| `Bash(*)` | Can run any terminal command |

### Security Is Your Responsibility

These broad permissions enable **full agent productivity**, but the responsibility lies with you:

- **Don't run on production machines** — use development environments only
- **Be careful with repos containing secrets** — make sure `.env` files are in `.gitignore`
- **Commit frequently with git** — so you can quickly rollback if needed
- **Try your first run on an empty demo repo**

> To add restrictions, add rules to the `deny` list:
> ```json
> "deny": ["Write(.env)", "Write(**/secrets/**)", "Bash(rm -rf /*)"]
> ```

---

## MCP Servers (Model Context Protocol)

### What Is MCP?
MCP (Model Context Protocol) allows Claude Code to access external data sources (databases, APIs, file systems). For example, an MCP server can let Claude query your PostgreSQL database directly or read tickets from Jira.

### Default State
```json
"enabledMcpServers": []
```
MCP servers are **disabled by default.** This is a deliberate design decision:
- External connections can pose security risks
- Each MCP server consumes additional tokens
- File system access is sufficient for most projects

### How to Enable MCP

**1.** Run the `/mcp` command in a Claude Code session:
```bash
claude
> /mcp
```
This lists available MCP servers and lets you toggle them on/off.

**2.** Or add them manually in `settings.json`:
```json
"enabledMcpServers": ["postgres-mcp", "github-mcp"]
```

### MCP Risks
| Risk | Description |
|------|-------------|
| **Security** | If an MCP server has write access to a database, an agent could accidentally delete data. Start with read-only access. |
| **Cost** | Each MCP query consumes additional tool-call tokens. Large query results can fill the context window. |
| **Complexity** | The MCP server must be running. If it stops, Claude Code will throw errors. |

> **Recommendation:** Only enable MCP when you truly need it, and only with `claude` (Pro). Using MCP with cheap models (`ccr code`) is not recommended — extra tool calls can trap cheap models in a tool-loop.

---

## Quick Reference: Profile-Based Recommendations

| Use Case | MAX_THINKING | AUTOCOMPACT | NON_ESSENTIAL | MCP |
|----------|------|------|------|-----|
| **Cost-focused (default)** | 8000 | 50 | 1 (off) | [] |
| **Quality-focused (architecture)** | 16000-32000 | 70 | 0 (on) | optional |
| **Ultra-cheap (tests/docs only)** | 4000 | 40 | 1 (off) | [] |
