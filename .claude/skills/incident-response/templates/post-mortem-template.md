# Post-Mortem Report

> **Blameless principle:** This document focuses on systems, processes, and decisions — not individuals. The goal is learning, not punishment. Everyone involved acted with the best information available at the time.

---

## [TITLE] — Post-Mortem

**Date of incident:** YYYY-MM-DD  
**Date of post-mortem:** YYYY-MM-DD  
**Severity:** P0 / P1 / P2  
**Author:** [Name]  
**Reviewers:** [Names]  
**Status:** Draft / Final  

---

## Executive Summary

> 2-4 sentences. What happened, how long it lasted, how it was fixed. Suitable for non-technical stakeholders.

[Summary]

**Impact:**
- Duration: X hours Y minutes (HH:MM – HH:MM UTC)
- Users affected: ~N users (X% of traffic)
- Revenue impact: $X or "None detected"
- SLA breach: Yes / No

---

## Timeline

> All times in UTC. Include: detection, escalation, key hypotheses tested, containment, resolution. Be honest about what took longer than expected.

| Time (UTC) | Event |
|------------|-------|
| HH:MM | Alert fired / first user report |
| HH:MM | Incident declared (P0/P1/P2) |
| HH:MM | Initial hypothesis: [what we thought] |
| HH:MM | Hypothesis ruled out: [why] |
| HH:MM | Root cause identified |
| HH:MM | Containment action applied: [what] |
| HH:MM | Impact contained (error rate dropping) |
| HH:MM | Fix deployed |
| HH:MM | Incident resolved, monitoring cleared |
| HH:MM | Status page updated: resolved |

---

## Root Cause

> The actual technical or process failure that caused the incident. Based on 5-Why analysis.

**Immediate cause:** [What directly triggered the failure]

**Root cause:** [The underlying system/process gap that allowed this to happen]

**Contributing factors:**
- [Factor 1]
- [Factor 2]

---

## What Went Well

> Things that worked — good practices that helped contain or resolve faster. Celebrate them.

- [e.g., Alerting fired within 2 minutes of first error]
- [e.g., Rollback procedure was documented and executed in < 5 min]
- [e.g., Team communication was clear in incident channel]

---

## What Went Poorly

> Honest assessment of gaps. Avoid blame — focus on system/process gaps.

- [e.g., No alert for connection pool exhaustion — found by user report]
- [e.g., Rollback script had outdated instructions, took extra 15 min to adapt]
- [e.g., Stakeholder communication sent 45 min late]

---

## Where We Got Lucky

> Factors that limited impact but we can't rely on next time.

- [e.g., Incident happened at 2pm not 2am — had full team available]
- [e.g., Only 20% of traffic hit the affected shard]

---

## Action Items

> Each item must be specific, owned, and time-bound. No vague "improve monitoring."

| # | Action | Type | Owner | Due | Status |
|---|--------|------|-------|-----|--------|
| 1 | | Prevent/Detect/Respond | | YYYY-MM-DD | Open |
| 2 | | | | | Open |
| 3 | | | | | Open |

**Types:**
- **Prevent** — eliminate root cause so this can't recur
- **Detect** — add alerting/monitoring to catch it faster
- **Respond** — improve runbook, automation, or process to reduce MTTR

---

## Metrics

| Metric | Value |
|--------|-------|
| Time to detect (TTD) | X min (from failure to alert) |
| Time to acknowledge (TTA) | X min (from alert to IC assigned) |
| Time to contain (TTC) | X min (from declaration to containment) |
| Time to resolve (TTR) | X hours Y min (full resolution) |
| Total MTTR | X hours Y min |

---

## Follow-Up

- [ ] Action items added to `state/tasks.md`
- [ ] Runbook updated with lessons learned
- [ ] Alert thresholds adjusted (if applicable)
- [ ] ADR created for systemic changes (if applicable): `/new-adr`
- [ ] Post-mortem saved to `memory-bank/domains/operations/incidents/incident-YYYY-MM-DD.md`
- [ ] Shared with team

---

## Appendix

### Supporting Data

> Paste relevant log snippets, error messages, graphs here.

```
[Log excerpt]
```

### Related Incidents

- [Link to similar past incidents if any]

### References

- Runbook used: `templates/runbook-template.md`
- 5-Why analysis: `templates/5-why-analysis.md`
