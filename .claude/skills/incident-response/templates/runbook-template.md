# Incident Runbook

> Copy this template for each incident. Fill in as you go — don't wait for full information.

---

## Incident: [TITLE]

**Date:** YYYY-MM-DD  
**Severity:** P0 / P1 / P2  
**Incident Commander:** [Name]  
**Scribe:** [Name]  
**Status:** 🔴 Investigating / 🟡 Contained / 🟢 Resolved  

---

## Quick Facts

| Field | Value |
|-------|-------|
| Detected at | HH:MM UTC |
| Declared at | HH:MM UTC |
| Contained at | HH:MM UTC |
| Resolved at | HH:MM UTC |
| Duration | X hours Y minutes |
| Users affected | ~N users / X% of traffic |
| Revenue impact | $X or Unknown |

---

## Symptoms

> What alerted us? What are users experiencing?

- [ ] Error: `[paste error message]`
- [ ] Alert: `[alert name and threshold]`
- [ ] User report: `[description]`
- [ ] Monitoring: `[metric and value]`

---

## Containment Actions

> List actions taken to stop the bleeding. Timestamps required.

| Time (UTC) | Action | Result | By |
|------------|--------|--------|----|
| HH:MM | | | |

**Containment options tried (check all that apply):**
- [ ] Feature flag / kill switch disabled
- [ ] Rollback to previous deploy: `git revert [SHA]` + redeploy
- [ ] Scale out (added N replicas)
- [ ] DB failover (promoted read replica)
- [ ] Rate limiting applied on endpoint
- [ ] Blocked specific user/IP pattern
- [ ] Third-party dependency bypassed

---

## Communication Log

### Status Page Updates

**T+0 (initial — post within 5 min of P0/P1 declaration):**
```
We are investigating an issue affecting [feature/service].
Users may experience [impact description].
We will provide an update in [30] minutes.
[HH:MM UTC]
```

**T+30 (first update):**
```
We have identified [brief description] as the cause.
We are currently [containment action].
Next update in [15-30] minutes.
[HH:MM UTC]
```

**Resolution:**
```
The issue affecting [feature/service] has been resolved as of [HH:MM UTC].
Users should no longer experience [impact].
Total impact duration: [X hours Y minutes].
We are conducting a post-mortem and will share findings.
[HH:MM UTC]
```

### Stakeholder Message Template

```
Subject: [P0/P1] [Brief title] — [Status: Investigating/Contained/Resolved]

Summary: [1-2 sentences on what's broken and who's affected]

Status: [Current status]

What we know:
- [Key finding 1]
- [Key finding 2]

What we're doing:
- [Action 1]
- [Action 2]

Next update: [HH:MM UTC] or upon status change

IC: [Name] | Channel: #incident-[name]
```

---

## Investigation Notes

> Raw notes — timestamps, findings, dead ends. Speed over polish.

```
HH:MM - [Note]
HH:MM - [Note]
```

**Hypothesis log:**
| # | Hypothesis | Evidence | Confirmed? |
|---|-----------|----------|------------|
| 1 | | | |

---

## Resolution

**Root cause (preliminary):**
> [1-2 sentences. Full RCA in post-mortem.]

**Fix applied:**
```bash
# Commands / changes made
```

**Verification:**
- [ ] Error rate back to baseline
- [ ] Health endpoint returning 200
- [ ] Sample user flow tested
- [ ] Monitoring alert cleared

---

## Action Items (immediate)

| Action | Owner | Due | Priority |
|--------|-------|-----|----------|
| | | | |

---

## Post-Mortem

- [ ] Post-mortem scheduled for within 48h of resolution
- [ ] Use `templates/post-mortem-template.md`
- [ ] Invite all responders + affected stakeholders
