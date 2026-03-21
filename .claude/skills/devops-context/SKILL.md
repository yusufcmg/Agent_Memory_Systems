---
name: devops-context
description: >
  Infrastructure and deployment patterns. Activate for Docker, CI/CD,
  GitHub Actions, or environment configuration work.
---

# DevOps Domain Context

## Loading Instructions
Read: `.claude/memory-bank/domains/devops/_summary.md`

## Docker Multi-Stage Template
Adapt the base image and commands to match the project's stack from `core/project.md`.

```dockerfile
# Stage 1: Build (adapt base image to project stack)
FROM node:20-alpine AS builder    # Node.js example — use python:3.12, golang:1.22, etc.
WORKDIR /app
COPY package*.json ./             # Adapt to project's dependency manifest
RUN npm ci --frozen-lockfile      # Adapt to project's package manager
COPY . .
RUN npm run build                 # Adapt to project's build command

# Stage 2: Production
FROM node:20-alpine AS runner     # Match base image above
WORKDIR /app
RUN addgroup --system --gid 1001 appgroup \
 && adduser  --system --uid 1001 appuser
COPY --from=builder --chown=appuser:appgroup /app/dist ./dist
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/package.json ./
USER appuser
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node", "dist/index.js"]     # Adapt to project's start command
```

## GitHub Actions Template
```yaml
## CI/CD Template
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - run: npm run lint
      - run: npm run typecheck
      - run: npm test -- --coverage

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build Docker image
        run: docker build -t app:${{ github.sha }} .

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - name: Deploy
        run: echo "deploy step here"
```

## Environment Variables Convention
- All required vars in `.env.example` with description comments
- Never default to real values in `.env.example`
- Use `zod` or equivalent to validate env at startup
