# Severity Matrix

Use this to classify an incident within the first 2 minutes. When in doubt, go higher (P0 > P1).

## Classification Table

| Severity | Users Affected | Service Impact | Response SLA | Escalation |
|----------|---------------|----------------|--------------|------------|
| **P0** | All / majority | Core feature completely unavailable | 5 min | CTO + On-call immediately |
| **P1** | >50% or key segment | Critical path severely degraded | 15 min | Engineering lead + On-call |
| **P2** | <50% or non-critical | Partial / workaround exists | 1 hour | On-call engineer |
| **P3** | Small subset | Minor degradation, analytics-only | Next business day | Team Slack |
| **P4** | Internal / no user impact | Monitoring / debt signal | Sprint planning | Team backlog |

## P0 Examples
- Login / authentication completely broken
- Payment processing failing for all users
- Website / API returning 5xx for all requests
- Data loss or corruption detected
- Security breach detected

## P1 Examples
- Search returning wrong results
- Email notifications not sending
- Dashboard loading > 10s for most users
- Mobile app crashing on launch for >50% of users
- Checkout works but confirmation emails fail

## P2 Examples
- Edge case in form validation
- Report PDF generation slow (not broken)
- One localization language showing errors
- Admin panel feature broken (users unaffected)

## P3 Examples
- Wrong metric in analytics dashboard
- Typo in UI copy
- Non-critical cron job skipped once
- Minor CSS misalignment on specific browser

## P4 Examples
- Performance regression below threshold
- Test flakiness in CI
- Dependency version behind (no CVE)
- Technical debt flagged by lint

---

## Downgrade / Upgrade Rules

**Upgrade to higher severity if:**
- Impact is spreading (error rate increasing over time)
- Workaround is complex or not user-friendly
- Revenue impact confirmed

**Downgrade to lower severity if:**
- Effective workaround exists and communicated
- Impact confirmed smaller than initially assessed
- Auto-recovery detected (error rate dropping)

---

## First 5 Minutes Checklist (P0/P1)

- [ ] Classify severity using this matrix
- [ ] Assign Incident Commander (IC)
- [ ] Open incident Slack channel: `#incident-YYYY-MM-DD-brief-description`
- [ ] Post initial status to status page
- [ ] Begin containment (do NOT investigate before containing)
