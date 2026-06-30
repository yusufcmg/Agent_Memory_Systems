---
name: sast-scan
description: >
  Full SAST (Static Application Security Testing) orchestration. Runs all 16 vulnerability
  detection skills in parallel via subagents. Source: github.com/utkusen/sast-skills.
  Trigger: "run SAST", "security scan", "/sast", full security audit.
---

# SAST Full Scan Orchestrator

Full security scan across 16 vulnerability classes using parallel subagents.
Source: [utkusen/sast-skills](https://github.com/utkusen/sast-skills)

## Prerequisite

**Phase 0 — Architecture Mapping (run first, sequential):**
Activate skill `sast-analysis` to produce `sast/architecture.md`.
All Phase 1 subagents read this file.

## Phase 1 — Parallel Vulnerability Detection

Launch all 16 subagents simultaneously after `sast/architecture.md` exists.
Each subagent activates its dedicated skill:

| Skill | Detects |
|-------|---------|
| `sast-sqli` | SQL Injection |
| `sast-xss` | Cross-Site Scripting |
| `sast-ssrf` | Server-Side Request Forgery |
| `sast-rce` | Remote Code Execution / Command Injection |
| `sast-idor` | Insecure Direct Object Reference |
| `sast-missingauth` | Missing Auth / Broken Function-Level Authorization |
| `sast-hardcodedsecrets` | Hardcoded Secrets (frontend/public code only) |
| `sast-pathtraversal` | Path / Directory Traversal |
| `sast-fileupload` | Insecure File Upload |
| `sast-ssti` | Server-Side Template Injection |
| `sast-xxe` | XML External Entity |
| `sast-jwt` | JWT Implementation Flaws |
| `sast-idor` | IDOR / Horizontal Privilege Escalation |
| `sast-businesslogic` | Business Logic Flaws |
| `sast-graphql` | GraphQL Injection |

Each subagent outputs: `sast/{skillname}-results.md`

## Phase 2 — Report Consolidation (sequential, after Phase 1)

Activate skill `sast-report` to merge all `*-results.md` into `sast/final-report.md`.

## Resumability

Each skill checks if its `*-results.md` already exists and skips if present.
Safe to re-run after partial completion.

## Output Files

```
sast/
├── architecture.md          # Phase 0 — codebase map
├── sqli-results.md
├── xss-results.md
├── ssrf-results.md
├── rce-results.md
├── idor-results.md
├── missingauth-results.md
├── hardcodedsecrets-results.md
├── pathtraversal-results.md
├── fileupload-results.md
├── ssti-results.md
├── xxe-results.md
├── jwt-results.md
├── businesslogic-results.md
├── graphql-results.md
└── final-report.md          # Phase 2 — consolidated findings
```
