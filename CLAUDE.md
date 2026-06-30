# CLAUDE.md
<!-- Claude Code native memory. Lean by design — detailed context lives in .claude/skills/ -->

## Project Memory
Full context: `.claude/memory-bank/`
Skills: auto-configured by `/init` — only stack-relevant skills enabled. Disabled skills cost zero tokens; enabled skills inject description only until invoked.

## Agent Roster
Model tiers: T1=opus (critical), T2=opus-fast (complex routine), T3=sonnet (routine), T4=haiku (fast/cheap)

| Invoke with...              | Agent        | Tier |
|-----------------------------|--------------|------|
| "as frontend agent"         | frontend     | T3   |
| "as backend agent"          | backend      | T2   |
| "as database agent"         | database     | T2   |
| "as devops agent"           | devops       | T3   |
| "as performance agent"      | performance  | T2   |
| "as qa frontend agent"      | qa-frontend  | T4   |
| "as qa backend agent"       | qa-backend   | T4   |
| "as security agent"         | security     | T1   |
| "as docs agent"             | docs         | T4   |
| "as teamlead"               | teamlead     | T1   |
| "as architect"              | architect    | T1   |
| "as planner"                | planner      | T2   |
| "as deployment agent"       | deployment   | T2   |
| "as incident agent"         | incident-response | T1 |
| "as data scientist"         | data-scientist | T3  |
| "as ml engineer"            | ml-engineer  | T3   |
| "as mlops engineer"         | mlops-engineer | T3  |
| "as data engineer agent"    | data-engineer | T3   |
| "as rust engineer"          | rust-engineer | T3   |
| "as trading strategist"     | crypto-trading-strategist | T1 |

## Slash Commands
- `/init`                — Onboard new project, create memory-bank
- `/status`              — Current tasks + blockers
- `/new-adr`             — Create Architecture Decision Record
- `/sync-memory`         — Reconcile memory-bank with current code
- `/incident <severity>` — Production incident triage (P0/P1/P2/post-mortem)
- `/sync-from-template`  — Push local agent/skill improvements back to AMS2 template

## ⚠️ Rules (All Agents — No Exceptions)
1. Write ONLY inside the project source directory defined in `memory-bank/core/project.md`
2. NEVER write secrets to any file
3. NEVER break existing public API contracts without an ADR
4. After EVERY task → update `.claude/memory-bank/state/tasks.md` (MANDATORY)
5. Architectural change → create new ADR in `.claude/memory-bank/architecture/`

## Token Tips
- Run `/context` to check window usage
- Run `/compact` at task boundaries
- Disable unused MCP servers with `/mcp`
