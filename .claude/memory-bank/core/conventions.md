# Code Conventions
_Last updated: YYYY-MM-DD_

## Naming
| Thing          | Convention    | Example                  |
|----------------|---------------|--------------------------|
| Files          | [filled by /init] | `user-profile.tsx`   |
| Components     | [filled by /init] | `UserProfile`        |
| Functions/vars | [filled by /init] | `getUserById`        |
| Constants      | [filled by /init] | `MAX_RETRY_COUNT`    |
| DB columns     | [filled by /init] | `created_at`         |
| CSS classes    | [filled by /init] | `user-avatar--large` |
| Env vars       | UPPER_SNAKE       | `DATABASE_URL`       |

## Git
- Branch naming: `feat/`, `fix/`, `chore/`, `test/`, `docs/`
- Commit format: `type(scope): description` (Conventional Commits)
- PR: squash merge preferred
- Never force-push to main/develop

## Code Style
[Filled by onboarding agent based on project language and framework]
- No debug/log statements in committed code (use structured logger)
- Max function length: 50 lines (extract if longer)
- Max file length: 300 lines (split if longer)

## Testing
- Test file location: [filled by /init — e.g. alongside source, or in tests/ directory]
- Minimum coverage: 80% on changed files
- No testing implementation details — test behavior

## Error Handling
- Never swallow errors silently
- Always log context with the error
- User-facing errors: generic message + error code
- Internal errors: full stack trace in logs

## Import Order
[Filled by onboarding agent based on project language]
