---
name: incident-response
description: >
  Production incident management: triage, containment, root cause analysis, post-mortem.
  Includes severity matrix, runbooks, 5-Why analysis, blameless post-mortem templates.
  Trigger: "as incident agent", /incident, P0/P1 alert, production down, post-mortem.
---

# Incident Response Skill

Structured playbook for managing production incidents from first alert to resolved post-mortem.

## Workflow Overview

```
ALERT → Triage → Containment → Communicate → Investigate → Resolve → Post-mortem → ADR (if systemic)
```

## Phase 1: Triage (< 5 min for P0/P1)

Read `templates/severity-matrix.md` to classify the incident.

Key questions:
- What is broken? (feature, endpoint, entire service)
- Who is affected? (all users, subset, internal only)
- Since when? (deploy correlation, external event)
- What changed? (`git log --oneline -10`)

## Phase 2: Containment

**Priority order (fastest to safest):**
1. Kill switch / feature flag → disable affected feature immediately
2. Rollback last deploy (git revert + redeploy)
3. Scale out (add replicas)
4. Database failover (promote read replica)
5. Block/rate-limit affected endpoint

**Never investigate before containment for P0/P1.**

## Phase 3: Communication

Use templates in `templates/runbook-template.md`.

Cadence:
- P0: Update every 15 minutes until resolved
- P1: Update every 30 minutes
- Always: time-stamp every message

## Phase 4: Root Cause Investigation

After containment, investigate with:
```bash
# Recent git changes
git log --oneline --since="2 hours ago"

# Error pattern
grep -c "ERROR" /var/log/app.log

# Resource usage
df -h && free -m && uptime

# Recent DB migrations
# (check your migration log or git history of migration files)
```

Apply `templates/5-why-analysis.md` iteratively.

## Phase 5: Post-Mortem

Use `templates/post-mortem-template.md`.

Principles:
- **Blameless**: systems failed, not people
- **Timeline**: exact timestamps from logs/git/deploy history
- **Action items**: specific, owned, time-bound
- **Systemic patterns**: if it happened once it will happen again → ADR

Write to: `memory-bank/domains/operations/incidents/incident-{YYYY-MM-DD}.md`

## Templates

- `templates/severity-matrix.md` — P0–P4 classification guide
- `templates/runbook-template.md` — incident runbook + comms templates
- `templates/post-mortem-template.md` — blameless post-mortem structure
- `templates/5-why-analysis.md` — iterative root cause analysis

## Integration Points

- **Sentry**: check releases tab for error spike correlated with deploy
- **Grafana/Datadog**: error rate, latency, saturation dashboards
- **PagerDuty/OpsGenie**: acknowledge alert to stop escalation
- **Status page**: update at containment and resolution
- **Slack/Discord**: incident channel — use `/incident` command

## Output

Every incident produces:
```
memory-bank/domains/operations/incidents/
└── incident-YYYY-MM-DD.md    # Timeline + root cause + action items
```

Systemic findings → ADR via `/new-adr`.
