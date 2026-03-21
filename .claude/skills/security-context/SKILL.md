---
name: security-context
description: >
  OWASP Top 10 checklist and security scan patterns. Activate for security
  audits, vulnerability scanning, and auth reviews.
---

# Security Scan Context

## Loading Instructions
Read: `.claude/memory-bank/domains/security/_summary.md`

## OWASP Top 10 Quick Reference
| # | Vulnerability | Quick Check |
|---|--------------|-------------|
| A01 | Broken Access Control | Check every route has auth + role |
| A02 | Cryptographic Failures | No MD5/SHA1, secrets in env only |
| A03 | Injection | No string interpolation in queries |
| A04 | Insecure Design | Rate limits, input bounds |
| A05 | Security Misconfiguration | No debug mode in prod, CORS strict |
| A06 | Vulnerable Components | `npm audit` / `pnpm audit` |
| A07 | Auth Failures | Brute force, weak tokens, no expiry |
| A08 | Data Integrity | Verify dependencies, signed packages |
| A09 | Logging Failures | No sensitive data in logs |
| A10 | SSRF | Validate all outbound URLs |

## Scan Commands
Use the source directory from `core/project.md` (referred to as `$SRC` below).
```bash
# Dependency vulnerabilities (adapt to package manager from core/project.md)
npm audit --audit-level=high              # Node.js
# pip audit                               # Python

# Secrets in codebase (replace $SRC with actual source directory)
grep -rE "(password|secret|key|token)\s*=\s*['\"][^'\"]{8,}" $SRC/

# SQL injection patterns
grep -rE "query\s*\+|interpolat|template.*sql" $SRC/

# XSS / unsafe HTML patterns (adapt to project's framework)
grep -rE "dangerouslySetInnerHTML|innerHTML\s*=|v-html|bypassSecurity" $SRC/
```

## Severity Definitions
- **HIGH**: Exploitable remotely, data breach risk → must fix before deploy
- **MED**: Exploitable with user interaction → fix this sprint
- **LOW**: Defense-in-depth improvement → backlog
