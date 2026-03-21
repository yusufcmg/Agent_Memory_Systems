---
name: sync-memory
description: >
  Reconcile memory-bank with actual code. Detects stale docs, missing entries,
  files that were changed but summaries not updated. Run weekly or after big merges.
---

Scan the codebase and compare against memory-bank. Check for drift.

Steps:
1. Read `core/project.md` to get the source directory
2. Read all `domains/*/_summary.md` files to get directory layouts
3. Read `state/tasks.md` — find tasks marked active >7 days with no progress note
4. Glob frontend component directories (from `domains/frontend/_summary.md`) — compare against component table
5. Glob backend API directories (from `domains/backend/_summary.md`) — compare against endpoints table
6. Glob migration directories (from `domains/database/_summary.md`) — compare against migration history

Output format:
```
╔══ MEMORY SYNC REPORT ══════════════════════╗

🔴 Stale Entries (in memory but not in code):
  • domains/frontend/_summary.md: ComponentX not found in source

🟡 Missing Entries (in code but not in memory):
  • [path]/NewWidget.tsx not in frontend summary
  • [path]/reports.ts not in backend endpoints

⚠️  Stale Tasks (active >7 days):
  • "Build auth page" — active since YYYY-MM-DD

📊 Memory Health: X/Y files up to date
╚════════════════════════════════════════════╝
```

After report, ask: "Update memory-bank now? (yes/no)"
If yes: update all flagged files.
