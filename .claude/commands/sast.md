---
description: Run full SAST security scan using 16 parallel vulnerability detection agents
---

# /sast — Full Security Scan

Runs a complete Static Application Security Testing (SAST) scan using [utkusen/sast-skills](https://github.com/utkusen/sast-skills).

## Usage

```
/sast              # Full scan — all 16 vulnerability classes
/sast sqli xss     # Targeted scan — specific checks only
```

## What It Does

**Phase 0 (sequential):** Activates `sast-analysis` skill → maps architecture to `sast/architecture.md`

**Phase 1 (parallel):** Launches 16 subagents simultaneously, one per vulnerability class:
- SQL Injection, XSS, SSRF, RCE, IDOR, Missing Auth
- Hardcoded Secrets, Path Traversal, File Upload
- SSTI, XXE, JWT Flaws, Business Logic, GraphQL Injection

**Phase 2 (sequential):** Activates `sast-report` → merges all findings into `sast/final-report.md`

## Instructions

1. Ensure you are in the project root (or pass source directory)
2. Activate skill `sast-scan` for full orchestration guidance
3. Run Phase 0 first: activate `sast-analysis`
4. Then launch all Phase 1 skills in parallel as subagents
5. Finally run `sast-report`

## Output

`sast/final-report.md` — findings ranked by severity (Critical → High → Medium → Low)

## Notes

- Resumable: skips checks where `*-results.md` already exists
- Read-only analysis — never modifies source code
- After HIGH/CRITICAL findings: add to `state/tasks.md` Blockers
