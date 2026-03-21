---
name: new-adr
description: >
  Create a new Architecture Decision Record. Use when making any significant
  technical decision — tech choice, pattern, API contract, DB schema change.
---

Use the `architect` agent to create a new ADR.

Steps:
1. Read `.claude/memory-bank/architecture/_index.md` to get the next ADR number (NNN)
2. Ask the user: "What decision are you recording? (one sentence)"
3. Create `.claude/memory-bank/architecture/ADR-NNN-[slug].md` using the architect agent template
4. Update `.claude/memory-bank/architecture/_index.md` — add new row to ADR table
5. Set status to "Proposed" unless user says otherwise

After creating, print:
```
✅ ADR-NNN created: .claude/memory-bank/architecture/ADR-NNN-slug.md
   Status: Proposed
   Affects: [agents listed in ADR]
```
