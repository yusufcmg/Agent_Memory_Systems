---
disable-model-invocation: true
name: backend-context
description: >
  Deep backend domain knowledge. Activate for API development, service layer,
  middleware, or authentication work. Loads endpoint registry and patterns.
---

# Backend Domain Context

## Loading Instructions
Read in order:
1. `.claude/memory-bank/domains/backend/_summary.md`
2. `.claude/memory-bank/domains/database/_summary.md`
3. ADRs tagged `backend` from `architecture/_index.md`

## Endpoint Conventions
After reading `_summary.md`, follow patterns established there.

## Standard API Response Shapes
Check `domains/backend/_summary.md` for project-specific response format.
Common pattern:
```
// Success
{ data: <result>, meta?: { page, total } }

// Error
{ error: "<ERROR_CODE>", message: "<human-readable>", code: "<app-code>" }
```

## Middleware Order (typical)
1. CORS
2. Rate limiter
3. Authentication (method defined in `core/project.md`)
4. Role/permission check
5. Input validation
6. Handler

## Service Layer Rules
- Controllers: request/response only, no business logic
- Services: business logic, no HTTP concepts
- Repositories: data access only, no business logic

## Auth Checklist for Every Protected Route
- [ ] Authentication middleware applied
- [ ] Role/permission check if needed
- [ ] Rate limiting on auth endpoints
- [ ] Input validated before DB query
