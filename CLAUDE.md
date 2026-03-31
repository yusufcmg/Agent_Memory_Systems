# CLAUDE.md
<!-- Claude Code native memory. Lean by design — detailed context lives in .claude/skills/ -->

## Project Memory
Full context: `.claude/memory-bank/`
Skills: auto-configured by `/init` — only stack-relevant skills enabled. Disabled skills cost zero tokens; enabled skills inject description only until invoked.

## Agent Roster
| Invoke with...              | Agent        | Model   |
|-----------------------------|--------------|---------|
| "as frontend agent"         | frontend     | sonnet  |
| "as backend agent"          | backend      | sonnet  |
| "as database agent"         | database     | sonnet  |
| "as devops agent"           | devops       | sonnet  |
| "as performance agent"      | performance  | sonnet  |
| "as qa frontend agent"      | qa-frontend  | haiku   |
| "as qa backend agent"       | qa-backend   | haiku   |
| "as security agent"         | security     | haiku   |
| "as docs agent"             | docs         | haiku   |
| "as teamlead"               | teamlead     | opus    |
| "as architect"              | architect    | opus    |
| "as planner"                | planner      | sonnet  |
| "as deployment agent"       | deployment   | sonnet  |

## Slash Commands
- `/init`         — Onboard new project, create memory-bank
- `/status`       — Current tasks + blockers
- `/new-adr`      — Create Architecture Decision Record
- `/sync-memory`  — Reconcile memory-bank with current code

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
