---
name: worktree-clean
description: >
  Clean up finished worktrees to reclaim disk space.
  Shows all active worktrees, identifies merged/stale ones, removes them safely.
---

Run these steps to clean up worktrees and save disk space:

## Step 1 — List all worktrees
```bash
git worktree list
```
Show output to user.

## Step 2 — Check disk usage
```bash
du -sh .claude/worktrees/* 2>/dev/null || echo "No worktrees in .claude/worktrees/"
du -sh ../*-worktree 2>/dev/null || true
```

## Step 3 — Identify safe-to-remove worktrees
A worktree is safe to remove if:
- Its branch has been merged into main/develop: `git branch --merged main`
- Or user confirms it's abandoned

## Step 4 — Remove confirmed worktrees
```bash
# For each confirmed worktree:
git worktree remove <path>          # safe (fails if uncommitted changes)
git worktree remove --force <path>  # force (only if user confirms data loss is OK)

# Clean stale references
git worktree prune
```

## Step 5 — Report
Show: disk space freed, worktrees remaining.

⚠️ Never force-remove without explicit user confirmation.
