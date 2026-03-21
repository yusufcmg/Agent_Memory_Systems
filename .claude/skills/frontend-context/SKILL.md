---
name: frontend-context
description: >
  Deep frontend domain knowledge for this project. Activate when working on
  UI components, state management, routing, or styling. Loads component registry,
  patterns, and domain-specific conventions on demand.
---

# Frontend Domain Context

## Loading Instructions
Read these files from memory-bank in order:
1. `.claude/memory-bank/domains/frontend/_summary.md` — component registry + patterns
2. `.claude/memory-bank/architecture/_index.md` — check for state management and stack ADRs
3. Load referenced ADR files that affect frontend

## Key Patterns to Follow
After reading memory-bank files, apply patterns documented there.
The project's framework and state management approach are defined in `core/project.md`.

## Common Frontend Anti-Patterns (Always Avoid)
- Deep prop/data passing (>2 levels) → use project's state management solution
- Business logic in UI components → extract to reusable functions/hooks/services
- Direct API calls in components → use a service layer or data-fetching abstraction
- Magic strings → define as constants
- Redundant state derivation → compute derived values instead of storing them

## Component Creation Checklist
- [ ] Input/props interface defined (no untyped parameters)
- [ ] Loading state handled
- [ ] Error state handled
- [ ] Empty state handled
- [ ] Accessible (ARIA where needed)
- [ ] Responsive (mobile-first)
- [ ] Test file created alongside

## State Management Decision Tree
```
Is state local to one component?
  YES → Component-local state
  NO → Is it shared across multiple pages/views?
    YES → Global store (see project's state management in core/project.md)
    NO → Parent state + props, or scoped shared state
```
