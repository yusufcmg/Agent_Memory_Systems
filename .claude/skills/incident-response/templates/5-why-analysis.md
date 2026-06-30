# 5-Why Root Cause Analysis

The 5-Why technique iteratively asks "why" until the systemic root cause is found — typically within 5 iterations. Stop when you reach something you can permanently fix.

## How to Use

1. State the **problem** clearly (observed symptom, not hypothesis)
2. Ask "Why did this happen?" → answer with evidence
3. Repeat for each answer until you reach a root cause you can act on
4. Look for multiple branches (problems often have more than one root cause)
5. Define action items that address root causes, not symptoms

---

## Template

**Incident:** [Brief title and date]  
**Facilitator:** [Name]  
**Participants:** [Names]  
**Date of analysis:** YYYY-MM-DD  

---

### Problem Statement

> State exactly what happened. Use observed facts, not assumptions.
> ❌ "The system crashed" → ✅ "API returned 503 for 100% of requests to /api/checkout from 14:32–15:07 UTC"

**Problem:** 

---

### Why Chain

**Why #1:** Why did [problem] happen?

> Answer: 

**Why #2:** Why did [answer to #1] happen?

> Answer: 

**Why #3:** Why did [answer to #2] happen?

> Answer: 

**Why #4:** Why did [answer to #3] happen?

> Answer: 

**Why #5:** Why did [answer to #4] happen?

> Answer: 

**Root cause:** 

---

### Multiple Branches (if applicable)

Sometimes there are parallel root causes. Repeat the chain for each branch:

**Branch B — Why #1:** [Alternative angle]
> Answer: 

---

### Stop Criteria

Stop asking "why" when you reach:
- A process that doesn't exist but should ("we had no alert for this")
- A process that exists but wasn't followed ("alert existed but was silenced")
- A technical constraint you can actually change ("no retry logic on payment calls")
- A knowledge gap ("team didn't know the DB connection limit was 100")

---

### Root Causes Summary

| # | Root Cause | Category | Actionable? |
|---|-----------|----------|-------------|
| 1 | | Process / Tech / Human | Yes / No |
| 2 | | | |

**Categories:**
- **Process**: Missing procedure, unclear ownership, no runbook
- **Tech**: Missing retry, no circuit breaker, no alerting, no timeout
- **Human**: Wrong assumption, missing context, communication gap
- **External**: Third-party failure, infrastructure provider issue

---

### Action Items

> Each action item must address a root cause, not a symptom.

| # | Action | Addresses Root Cause # | Owner | Due Date | Priority |
|---|--------|------------------------|-------|----------|----------|
| 1 | | | | | P0/P1/P2 |
| 2 | | | | | |

**Action types:**
- **Prevent**: Fix the root cause so this can't happen again
- **Detect**: Add monitoring/alerting so we catch it faster next time
- **Respond**: Improve runbook / automation to reduce MTTR

---

### Lessons Learned

> What did this incident teach us that we didn't know before?

1. 
2. 

---

### ADR Trigger?

If the root cause reveals a systemic architectural issue:
- [ ] Yes → create ADR via `/new-adr` with title: `[ADR-NNN] [Fix description]`
- [ ] No → action items are sufficient
