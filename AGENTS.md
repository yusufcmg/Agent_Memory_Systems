# AGENTS.md
<!-- Universal standard: https://agents.md — works with Cursor, Codex, Copilot, Aider, etc. -->
<!-- Claude Code detail: CLAUDE.md + .claude/memory-bank/ -->

## Setup
```bash
bash install.sh          # First time: installs Claude Code Router + memory-bank templates
claude                   # Start Claude Code
/init                    # Onboard project (creates memory-bank from scratch)
```

## Daily Usage
```bash
# Start a task
claude -p "as frontend agent, build the user profile card component"

# Route to cheap model for tests
ccr code -p "as qa frontend agent, write tests for UserProfile"

# Security scan with minimal model
ccr code -p "as security agent, scan auth endpoints"

# Review everything
claude -p "as teamlead, review this week's changes"
```

## ⚠️ Rules (All Agents)
- Write ONLY inside project source directory
- NEVER add secrets to any file
- ALWAYS update `.claude/memory-bank/state/tasks.md` after task completion
- Architectural decisions → new ADR file

## Memory Bank
`.claude/memory-bank/` — Project's institutional knowledge.
Each agent reads ONLY its own domain slice. No full-file dumps.

## Model Routing (via Claude Code Router)
| Task Type    | Model   | Why              |
|--------------|---------|------------------|
| Core dev     | sonnet  | Best tool-use    |
| Architecture | opus    | Deep reasoning   |
| QA / Tests   | haiku   | Cost efficient   |
| Security     | haiku   | Cheap scan       |
| Docs / CI    | haiku   | Minimal cost     |
