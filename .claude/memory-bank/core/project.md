# [PROJECT_NAME] — Project Core
_Last updated: YYYY-MM-DD by onboarding_

## Purpose
[1-2 sentence project description]

## Tech Stack
| Layer          | Technology                  |
|----------------|-----------------------------|
| Frontend       | —                           |
| Backend        | —                           |
| Database       | —                           |
| Auth           | —                           |
| Deploy         | —                           |
| Package Mgr    | —                           |
| Testing        | —                           |
| CI/CD          | —                           |

## Source Directory
Primary source: `[filled by /init — e.g. src/, app/, packages/]`

## ⚠️ Hard Rules (All Agents)
1. Write ONLY inside the source directory defined above
2. NEVER write secrets to any file
3. NEVER break existing API contracts without an ADR
4. ALWAYS update `state/tasks.md` after completing a task
5. Schema changes require an ADR

## Agent → Domain Mapping
| Agent       | Reads                                          |
|-------------|------------------------------------------------|
| frontend    | core/project, core/conventions, domains/frontend, state/tasks |
| backend     | core/project, core/conventions, domains/backend, domains/database, state/tasks |
| qa-frontend | core/project, domains/frontend, state/tasks    |
| qa-backend  | core/project, domains/backend, domains/database, state/tasks |
| security    | core/project, domains/security, domains/backend |
| database    | core/project, domains/database, state/tasks    |
| devops      | core/project, domains/devops, state/tasks      |
| performance | core/project, domains/frontend, domains/backend, domains/database, state/tasks |
| deployment  | core/project, domains/devops, domains/security, state/tasks, state/progress |
| docs        | core/project, domains/backend, domains/frontend |
| planner     | core/project, state/tasks, state/progress, architecture/_index |
| onboarding  | ALL (creates all memory-bank files)            |
| teamlead    | ALL                                            |
| architect   | core/*, architecture/*, state/decisions        |
