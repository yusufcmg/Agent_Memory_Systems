---
description: Production incident response — triage, containment, root cause, post-mortem
---

# /incident — Incident Response

Activates the incident response agent for structured production incident management.

## Usage

```
/incident P0              # Active P0 incident — immediate triage
/incident P1              # Active P1 incident — 15-min response
/incident post-mortem     # Post-incident review after resolution
/incident runbook         # Browse runbooks for common issues
```

## What Happens

**For active incidents (`/incident P0` or `/incident P1`):**
1. Activates `incident-response` skill
2. Opens severity matrix for classification
3. Guides through containment options (rollback, scale, feature flag)
4. Drafts communication templates (status page, stakeholder message)
5. Starts investigation after containment

**For post-mortems (`/incident post-mortem`):**
1. Opens `post-mortem-template.md`
2. Guides blameless timeline reconstruction
3. Runs 5-Why analysis
4. Produces `memory-bank/domains/operations/incidents/incident-{date}.md`
5. Identifies action items + potential ADR triggers

## Output Files

```
memory-bank/domains/operations/incidents/
└── incident-YYYY-MM-DD.md    # Timeline + root cause + action items
```

## Severity Reference

| Level | Response | Examples |
|-------|----------|---------|
| P0 | 5 min | Site down, login broken, payments failing |
| P1 | 15 min | >50% users affected, critical path degraded |
| P2 | 1 hour | <50% users, non-critical path |
| P3 | Next day | Analytics, cosmetic issues |

## Notes

- Run on `as incident agent` to engage the full agent
- Templates live in `.claude/skills/incident-response/templates/`
- After P0/P1: always run `/incident post-mortem`
- Systemic root causes → `/new-adr` to document the fix
