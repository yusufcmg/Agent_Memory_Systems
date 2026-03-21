# Memory Bank Guide

How the memory system works, how to keep it healthy, and how to scale it.

## How Agents Read Memory

Each agent has a defined reading order. It reads only what it needs:

```
frontend agent reads:
  core/project.md           ← always (~150 tokens)
  core/conventions.md       ← always (~100 tokens)
  domains/frontend/_summary.md  ← always (~80 tokens)
  state/tasks.md            ← always (~60 tokens)
  architecture/_index.md   ← always (~50 tokens)
  ADR-001.md, ADR-004.md   ← only ADRs tagged "frontend" (~200 tokens)
  ─────────────────────────────────────────────────
  Total context used: ~640 tokens for full project knowledge
```

Compare to loading everything: ~3,000+ tokens.

## How Agents Write Memory

After every task, an agent MUST update:

1. **`state/tasks.md`** — move task to ✅ Completed with date
2. **Domain `_summary.md`** — add new component/endpoint/migration/finding
3. **`state/tasks.md` ⚠️ Blockers** — if something blocked progress

ADR-worthy decisions also update:
4. **`architecture/ADR-NNN-*.md`** — the decision itself
5. **`architecture/_index.md`** — add row to ADR table

## File Size Limits

Files have soft limits to prevent bloat. The `/sync-memory` command flags overflows.

| File | Soft Limit | What to do when exceeded |
|------|-----------|--------------------------|
| `core/project.md` | 200 lines | Extract sections to new domain files |
| `core/conventions.md` | 150 lines | Split into language-specific files |
| `domains/*/_summary.md` | 100 lines | Archive old entries to `_archive.md` |
| `state/tasks.md` | 150 lines | Move old completed items to `progress.md` |
| `state/progress.md` | 300 lines | Archive to `state/archive-YYYY.md` |
| `architecture/_index.md` | 80 lines | It's just an index — ADRs stay separate |

## ADR Pattern — Preventing Architecture File Bloat

Instead of one large `architecture.md`, each decision is its own file:

```
architecture/
├── _index.md               ← routing table only (always small)
├── ADR-001-tech-stack.md   ← one decision, complete context
├── ADR-002-auth-jwt.md
├── ADR-003-db-schema.md
└── ADR-004-state-zustand.md
```

Benefits:
- `_index.md` stays tiny (agents route from it)
- Each ADR can grow without affecting others
- Old ADRs can be marked `Deprecated` without deletion
- Searching for "why did we choose JWT" → open ADR-002

Create a new ADR: `/new-adr`

## Running `/sync-memory`

Run this weekly or after big merges:

```
/sync-memory
```

It will:
1. Compare `domains/frontend/_summary.md` against actual frontend component directories
2. Compare `domains/backend/_summary.md` against actual backend API directories
3. Compare `domains/database/_summary.md` against `db/migrations/**`
4. Flag tasks that are "Active" for more than 7 days
5. Offer to update flagged files

## Monorepo Setup

For monorepos with multiple packages, use nested AGENTS.md files:

```
packages/
├── web/
│   ├── AGENTS.md           ← frontend-specific rules
│   └── .claude/memory-bank/domains/frontend/_summary.md
├── api/
│   ├── AGENTS.md           ← backend-specific rules
│   └── .claude/memory-bank/domains/backend/_summary.md
└── .claude/               ← shared: core/, architecture/, state/
```

The root `.claude/memory-bank/` has shared state. Each package has its own domain summary. Agents in a package read the root core files + their package's domain file.

## Archiving Old Data

When `state/tasks.md` gets too long:

```bash
# Create archive
echo "# Archive — $(date +%Y-Q%q)" > .claude/memory-bank/state/archive-$(date +%Y).md

# Paste old completed entries from tasks.md into archive file
# Then delete from tasks.md

# Agents never read archive files — they're for human reference only
```

## Starting Fresh

If memory-bank gets corrupted or you want to reinitialize:

```bash
rm -rf .claude/memory-bank
cp -r /path/to/agent-memory-system/.claude/memory-bank .claude/
claude
/init   # re-interview and recreate
```

Your agents and skills are untouched.
