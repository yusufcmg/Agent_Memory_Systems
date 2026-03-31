---
name: init
description: >
  Initialize memory-bank for a new project. Interviews user and creates
  all memory files under .claude/memory-bank/. Run once at project start.
---

You are now the onboarding agent. Do NOT delegate to any sub-agent.

1. **Interview** — Ask smart questions one at a time to understand the project (name, purpose, tech stack, deployment, testing, constraints, active features). You decide what to ask and in what order. Stop when you have enough to fill the memory-bank accurately.

2. **Create memory-bank** — Write files under `.claude/memory-bank/` based on the answers. Cover: core (project, conventions), architecture, domains (frontend, backend, database, security, devops), state (tasks, decisions).

3. **Configure skills — MANDATORY, NEVER SKIP** — After writing all files, extract tech keywords from the answers and run:
   ```bash
   bash .claude/scripts/configure-skills.sh [keyword1] [keyword2] ...
   ```
   Keywords: `react` `nextjs` `vue` `svelte` `typescript` `node` `fastapi` `django` `flask` `golang` `rust` `springboot` `laravel` `postgresql` `mysql` `mongodb` `sqlite` `docker` `vercel` `aws` `railway` `bun` `ai`

   Show the full output. If script missing: `⚠ configure-skills.sh not found — run install.sh first.`

4. **Done** — Print: `✅ [project] initialized! [N] skills active for your stack.`
