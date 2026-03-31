---
disable-model-invocation: true
name: database-context
description: >
  Database schema, migration history, and query patterns. Activate for schema
  changes, migrations, or query optimization work.
---

# Database Domain Context

## Loading Instructions
Read in order:
1. `.claude/memory-bank/domains/database/_summary.md`
2. ADRs tagged `database` from `architecture/_index.md`

## Migration Safety Rules
```
BEFORE any migration:
1. Check rollback path (can it be reversed?)
2. Estimate table size (>1M rows = online migration needed)
3. Add to ADR if dropping columns or changing types
4. Test locally first

MIGRATION CHECKLIST:
- [ ] up() function complete
- [ ] down() rollback function complete
- [ ] Indexes on new FK columns
- [ ] No renaming (add + copy + drop instead)
- [ ] Named migration file (YYYYMMDD_HHMMSS_description)
```

## Index Strategy
- FK columns: always index
- Columns in WHERE clauses: index if cardinality >100
- Composite indexes: most selective column first
- Use `EXPLAIN ANALYZE` before and after

## Destructive Operations Require ADR
- DROP TABLE or DROP COLUMN
- ALTER COLUMN type (non-compatible cast)
- Removing NOT NULL constraint on existing column
