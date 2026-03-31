---
name: init
description: >
  Initialize memory-bank for a new project. Interviews user and creates
  all memory files under .claude/memory-bank/. Run once at project start.
---

You are now the onboarding agent. Do NOT delegate to any sub-agent. Run this entire workflow yourself.

## Phase 1: Interview

Ask smart, contextual questions to understand the project. You decide what to ask and in what order.
The goal is to gather enough information to fill the memory-bank accurately.

**Minimum info you must collect:**
- Project name and purpose
- Frontend tech (framework, language)
- Backend tech (framework, language, version)
- Database and ORM
- Auth method
- Deployment target
- Testing setup
- Source directory structure
- Hard rules / things agents must never do
- Features currently being built

Ask one question at a time. Do not combine. Do not acknowledge answers — just ask the next question.
Stop when you have all the above information.

## Phase 2: Create memory-bank files

Run: `mkdir -p .claude/memory-bank/core .claude/memory-bank/state .claude/memory-bank/architecture .claude/memory-bank/domains/frontend .claude/memory-bank/domains/backend .claude/memory-bank/domains/database .claude/memory-bank/domains/security .claude/memory-bank/domains/devops`

Write these files:

### `.claude/memory-bank/core/project.md`
Project name, purpose, tech stack table, source directory, hard rules, agent→domain mapping.

### `.claude/memory-bank/core/conventions.md`
Naming conventions, git commit format, code style, package manager commands, testing approach.

### `.claude/memory-bank/architecture/README.md`
ADR index — empty, with headers.

### `.claude/memory-bank/domains/frontend/_summary.md`
Stack, empty component/hooks tables. Skip if no frontend.

### `.claude/memory-bank/domains/backend/_summary.md`
Stack, auth method, empty endpoints/services tables. Skip if no backend.

### `.claude/memory-bank/domains/database/_summary.md`
DB + ORM, empty schema/migration tables. Skip if no database.

### `.claude/memory-bank/domains/security/_summary.md`
Auth method, empty findings log.

### `.claude/memory-bank/domains/devops/_summary.md`
Deploy target, CI/CD tool, empty environments/env vars tables.

### `.claude/memory-bank/state/tasks.md`
Pending tasks from active features. Mark onboarding complete under ✅ Completed.

### `.claude/memory-bank/state/decisions.md`
First entry: today's date, tech stack decisions.

## Phase 3: Configure skills — MANDATORY, NEVER SKIP

After writing ALL files, extract tech keywords from the answers and call configure-skills.sh.

Keyword rules:
- React → `react`, Next.js → `nextjs`, Vue → `vue`, Svelte → `svelte`
- TypeScript mentioned → `typescript`
- FastAPI → `fastapi`, Django → `django`, Flask → `flask`, Node/Express → `node`
- Go/Gin → `golang`, Rust → `rust`, Spring Boot → `springboot`, Laravel → `laravel`
- PostgreSQL → `postgresql`, MySQL → `mysql`, MongoDB → `mongodb`, SQLite → `sqlite`
- Docker → `docker`, Vercel → `vercel`, AWS → `aws`, Railway → `railway`
- Bun → `bun`, AI/LLM/agents → `ai`

```bash
bash .claude/scripts/configure-skills.sh [keyword1] [keyword2] ...
```

Show the full script output to the user so they can see which skills are now active.

If the script is missing: `⚠ configure-skills.sh not found — run install.sh first.`

## Phase 4: Done

```
✅ [project name] initialized!
Memory-bank created + [N] skills configured for your stack.
Next: type 'as planner, break down [first active feature]'
```
