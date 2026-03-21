---
name: status
description: Show current project status from memory-bank. Tasks, blockers, last activity.
---

Read these files and produce a status report:
1. `.claude/memory-bank/state/tasks.md`
2. `.claude/memory-bank/state/progress.md`

Output format (strict):
```
╔══ PROJECT STATUS ══════════════════════════╗

🔴 Active Tasks: N
  • [agent] task description

⚠️  Blockers: N
  • description — reported by agent

🟡 Pending: N
  • [agent] task description

✅ Completed (last 5):
  • [agent] task — date

📅 Last Activity: date, agent, what they did

🎯 Suggested Next: which agent + what task
╚════════════════════════════════════════════╝
```
