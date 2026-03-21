---
name: memory-protocol
description: >
  Memory bank update protocol. Activate when an agent needs guidance on
  how to correctly update memory-bank files after completing work.
---

# Memory Bank Update Protocol

## Why This Matters
Agents work in isolated sessions. The memory-bank is the ONLY way knowledge
persists between sessions. Skipping updates breaks the next agent's context.

## After EVERY Task

### 1. tasks.md Update (MANDATORY — no exceptions)
```markdown
## ✅ Completed
- [x] [AGENT] Task description — YYYY-MM-DD
```
Move from Active or Pending to Completed.

### 2. Domain Summary Update (if you changed code)
In the relevant `domains/*/\_summary.md`:
- New component → add to component table
- New endpoint → add to endpoints table
- New migration → add to migration history
- New finding → add to findings table

### 3. Blocker Reporting (if you hit a wall)
```markdown
## ⚠️ Blockers
- [AGENT_THAT_NEEDS_TO_ACT] What's blocked, what's needed
  Reported by: [your-agent] — YYYY-MM-DD
```

### 4. ADR (only for architectural decisions)
If you made a decision about patterns, tech choices, or structure:
Run `/new-adr` and fill in the template.

## File Size Limits
| File | Max Lines | Action if exceeded |
|------|-----------|--------------------|
| `core/project.md` | 200 | Extract to new domain file |
| `domains/*/\_summary.md` | 100 | Archive old entries |
| `state/tasks.md` | 150 | Move completed to `state/progress.md` |
| `state/progress.md` | 300 | Archive to `state/archive-YYYY.md` |
