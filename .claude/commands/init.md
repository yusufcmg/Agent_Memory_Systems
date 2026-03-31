---
name: init
description: >
  Initialize memory-bank for a new project. Interviews user and creates
  all memory files under .claude/memory-bank/. Run once at project start.
---

You are now the onboarding agent. Do NOT delegate to any sub-agent. Run this entire workflow yourself.

## Phase 1: Interview (STRICT — no deviations)

Ask EXACTLY these 11 questions, ONE at a time. Wait for the user's answer before asking the next.
Do NOT greet. Do NOT acknowledge answers. Do NOT combine questions. Just ask and wait.

```
Q1/11: What's this project called and what does it do? (1-2 sentences)
Q2/11: Frontend stack? (e.g. React + TypeScript, Vue + Nuxt, Svelte, Flutter, or 'none')
Q3/11: Backend stack? (e.g. Node.js + Express, Python + FastAPI, Go + Gin, Ruby on Rails, or 'none')
Q4/11: Database and ORM? (e.g. PostgreSQL + Prisma, MySQL + SQLAlchemy, MongoDB, or 'none')
Q5/11: How is authentication handled? (e.g. JWT + refresh tokens, OAuth2, sessions, or 'none yet')
Q6/11: Where does this deploy? (e.g. Vercel, AWS ECS, Railway, Docker, or 'not decided')
Q7/11: Package manager? (e.g. npm / pnpm / yarn / bun / pip / go mod / cargo)
Q8/11: Testing setup? (e.g. Vitest, Jest, Playwright, pytest, go test, or 'none yet')
Q9/11: Where is the source code? (e.g. src/, app/, packages/, cmd/)
Q10/11: Anything agents must NEVER do in this codebase? (hard rules, or 'none')
Q11/11: What features are actively being built right now? (comma-separated or 'nothing yet')
```

After Q11 is answered → proceed to Phase 2.

## Phase 2: Create memory-bank files

Run: `mkdir -p .claude/memory-bank/core .claude/memory-bank/state .claude/memory-bank/architecture .claude/memory-bank/domains/frontend .claude/memory-bank/domains/backend .claude/memory-bank/domains/database .claude/memory-bank/domains/security .claude/memory-bank/domains/devops`

Then write these files using the collected answers:

### `.claude/memory-bank/core/project.md`
Fill: project name, purpose, tech stack table (Frontend/Backend/DB/Auth/Deploy/Testing), source directory, hard rules (from Q10), agent→domain mapping.

### `.claude/memory-bank/core/conventions.md`
Fill: naming conventions, git commit format, code style, package manager commands, testing approach.

### `.claude/memory-bank/architecture/README.md`
ADR index — empty, with headers.

### `.claude/memory-bank/domains/frontend/_summary.md`
Fill from Q2. Leave empty if no frontend.

### `.claude/memory-bank/domains/backend/_summary.md`
Fill from Q3. Leave empty if no backend.

### `.claude/memory-bank/domains/database/_summary.md`
Fill from Q4. Leave empty if no database.

### `.claude/memory-bank/domains/security/_summary.md`
Fill from Q5 (auth method).

### `.claude/memory-bank/domains/devops/_summary.md`
Fill from Q6 (deploy target).

### `.claude/memory-bank/state/tasks.md`
Create pending tasks from Q11 answers.

### `.claude/memory-bank/state/decisions.md`
First entry: today's date, tech stack selected.

## Phase 3: Configure skills (MANDATORY — do NOT skip)

Extract keywords from Q2–Q6 answers using these rules:
- React → `react`, Next.js → `nextjs`, Vue → `vue`, Svelte → `svelte`
- TypeScript mentioned anywhere → `typescript`
- FastAPI → `fastapi`, Django → `django`, Flask → `flask`, Node/Express → `node`
- Go/Gin → `golang`, Rust → `rust`, Spring Boot → `springboot`, Laravel → `laravel`
- PostgreSQL → `postgresql`, MySQL → `mysql`, MongoDB → `mongodb`, SQLite → `sqlite`
- Docker → `docker`, Vercel → `vercel`, AWS → `aws`, Railway → `railway`
- Bun → `bun`, AI/LLM → `ai`

Run:
```bash
bash .claude/scripts/configure-skills.sh [keyword1] [keyword2] ...
```

Show the full output to the user.

If the script is missing, print: `⚠ configure-skills.sh not found — run install.sh first.`

## Phase 4: Done

Print:
```
✅ [project name] initialized!
Memory-bank created + skills configured for your stack.
Next: type 'as planner, break down [first feature from Q11]'
```
