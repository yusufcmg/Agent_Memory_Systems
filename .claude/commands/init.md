---
name: init
description: >
  Initialize memory-bank for a new project. Interviews user and creates
  all memory files under .claude/memory-bank/. Run once at project start.
---

Invoke the `onboarding` sub-agent to handle this entire workflow.
Do NOT run the interview yourself. Delegate entirely to the onboarding agent.

## After the onboarding agent finishes — MANDATORY FINAL STEP

You MUST run `configure-skills.sh` after memory-bank is created.
Do NOT skip this step. This is not optional.

1. Look at the tech stack answers collected during the interview.
2. Build a keyword list using these rules:
   - React/Next.js/Vue/Svelte mentioned → add `react`/`nextjs`/`vue`/`svelte`
   - TypeScript mentioned anywhere → add `typescript`
   - FastAPI/Django/Flask mentioned → add `fastapi`/`django`/`flask`
   - Node/Express mentioned → add `node`
   - Python mentioned → skip (covered by fastapi/django/flask)
   - Go/Gin mentioned → add `golang`
   - Rust mentioned → add `rust`
   - PostgreSQL/MySQL/MongoDB/SQLite → add `postgresql`/`mysql`/`mongodb`/`sqlite`
   - Docker mentioned → add `docker`
   - Vercel mentioned → add `vercel`
   - AWS mentioned → add `aws`
   - Railway mentioned → add `railway`
   - Bun mentioned → add `bun`
   - AI/LLM/agents mentioned → add `ai`

3. Run:
```bash
bash .claude/scripts/configure-skills.sh [keyword1] [keyword2] ...
```

4. Show the output to the user.

If `.claude/scripts/configure-skills.sh` does not exist, print:
```
⚠ configure-skills.sh not found — run install.sh first.
```
