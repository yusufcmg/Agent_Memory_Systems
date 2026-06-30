# CLAUDE.md
<!-- Claude Code native memory. Lean by design — detailed context lives in .claude/skills/ -->

## Project Memory
Full context: `.claude/memory-bank/`
Skills: auto-configured by `/init` — only stack-relevant skills enabled. Disabled skills cost zero tokens; enabled skills inject description only until invoked.

## Agent Roster
Model tiers: T1=opus/claude-opus-4-8 (critical), T2=sonnet/claude-sonnet-4-6 (complex), T3=sonnet (routine), T4=haiku/claude-haiku-4-5 (fast/cheap)

### Primary Agents (user-invoked)
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
| "as chief-of-staff"         | chief-of-staff | T3  |
| "as startup launch agent"   | startup-launch | T3  |

### Support Agents (proactive / auto-invoked)
| Agent               | Purpose                                      | Tier |
|---------------------|----------------------------------------------|------|
| code-reviewer       | Quality, security, maintainability review    | T3   |
| tdd-guide           | Write-tests-first enforcement, 80% coverage  | T3   |
| security-reviewer   | OWASP, injection, secrets scan               | T1   |
| e2e-runner          | Playwright E2E tests                         | T3   |
| onboarding          | Project init, memory-bank creation (/init)   | T3   |
| loop-operator       | Autonomous loop management                   | T3   |
| harness-optimizer   | Agent config analysis                        | T3   |
| refactor-cleaner    | Dead code removal                            | T4   |
| doc-updater         | Codemaps, documentation updates              | T4   |
| docs-lookup         | Library/framework doc lookup via Context7    | T4   |
| python-reviewer     | PEP 8, type hints, Pythonic idioms           | T3   |
| go-reviewer         | Idiomatic Go, concurrency, error handling    | T3   |
| rust-reviewer       | Ownership, lifetimes, unsafe usage           | T3   |
| java-reviewer       | Spring Boot, JPA, security                   | T3   |
| kotlin-reviewer     | Coroutines, Compose, clean architecture      | T3   |
| cpp-reviewer        | Memory safety, modern C++, concurrency       | T3   |
| polars-reviewer     | Lazy API, pandas anti-patterns               | T3   |
| database-reviewer   | PostgreSQL optimization, Supabase            | T3   |
| build-error-resolver | TypeScript/JS build and type errors         | T4   |
| go-build-resolver   | Go build, vet, linter errors                 | T4   |
| rust-build-resolver | Cargo, borrow checker, linker errors         | T4   |
| java-build-resolver | Maven/Gradle, Spring Boot build errors       | T4   |
| kotlin-build-resolver | Kotlin/Gradle dependency errors            | T4   |
| cpp-build-resolver  | CMake, compilation, template errors          | T4   |

## Slash Commands
### Project lifecycle
- `/init`                — Onboard new project, create memory-bank (run once per project)
- `/status`              — Current tasks + blockers
- `/sync-memory`         — Reconcile memory-bank with current code
- `/new-adr`             — Create Architecture Decision Record
- `/sync-from-template`  — Push local improvements back to AMS2 template

### Development
- `/tdd`                 — Start TDD loop (write tests first)
- `/code-review`         — Full codebase security + quality scan
- `/code-review ultra`   — Multi-agent cloud review (billed)
- `/plan`                — Design implementation plan
- `/verify`              — Run full verification suite

### Language-specific
- `/go-review`, `/go-test`, `/go-build`       — Go review / test / build fix
- `/rust-review`, `/rust-test`, `/rust-build` — Rust review / test / build fix
- `/python-review`                             — Python review
- `/java-review`, `/java-build`               — Java/Spring review + build fix
- `/kotlin-review`, `/kotlin-build`           — Kotlin review + build fix
- `/cpp-review`, `/cpp-test`, `/cpp-build`    — C++ review / test / build fix

### Operations
- `/incident <severity>` — Production incident triage (P0/P1/P2/post-mortem)
- `/sast`                — 15-subagent parallel security scan (OWASP Top 10)
- `/learn`               — Extract session patterns → new reusable skill
- `/refactor-clean`      — Dead code removal with knip/depcheck
- `/e2e`                 — Run Playwright E2E tests
- `/harness-audit`       — Audit agent harness config

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
