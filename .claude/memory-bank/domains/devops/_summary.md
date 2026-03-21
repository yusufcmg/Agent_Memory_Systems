# DevOps Domain Summary
_Last updated: YYYY-MM-DD | Max 100 lines_

## Deploy Target
[Filled by onboarding agent]

## CI/CD
[Filled by onboarding agent]

## Infrastructure
| Component | Config File | Status |
|-----------|------------|--------|
| Docker    | Dockerfile | —      |
| Compose   | docker-compose.yml | — |
| CI/CD     | .github/workflows/ | — |

## Environments
| Env     | URL         | Branch  | Deploy trigger |
|---------|-------------|---------|----------------|
| dev     | localhost   | any     | manual         |
| staging | —           | develop | push           |
| prod    | —           | main    | manual gate    |

## Environment Variables
_All vars must also exist in .env.example_

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| PORT | Server port | yes | 3000 |
| DATABASE_URL | DB connection string | yes | — |
| JWT_SECRET | JWT signing secret | yes | — |

## Deployment Notes
[devops agent documents deploy steps, rollback procedures here]
