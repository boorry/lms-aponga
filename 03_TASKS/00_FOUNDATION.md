# T-FOUNDATION — Foundation

## Objectif
Créer un workspace reproductible conforme au stack.

Respecter la structure cible de `01_ORCHESTRATION/07_REPO_LAYOUT.md` (monorepo `apps/api` + `apps/web`, npm workspaces natif — pas de Turborepo/Nx sans décision explicite).

## Actions
1. Vérifier Node/npm/Docker.
2. Créer backend NestJS 12.0.1.
3. Créer frontend Next.js PWA-first et verrouiller sa version exacte ; démarrer le serveur de développement sur le port 3001 (cohérent avec `CORS_ORIGINS` de `.env.example`).
4. Configurer TypeScript 5.9.3 côté backend.
5. Ajouter Prisma 7.x.
6. Préparer PostgreSQL 17 et Redis 8.2 via Docker Compose.
7. Configurer Jest/Supertest/Playwright.
8. Ajouter health/readiness (T-1103).
9. Configurer CORS et les en-têtes de sécurité de base — CSP, HSTS, `X-Content-Type-Options`, `X-Frame-Options` (T-1001, T-1002). Ces éléments doivent exister dès le premier démarrage, pas être ajoutés plus tard.
10. Configurer la génération de la documentation OpenAPI avec `@nestjs/swagger`.
11. Ajouter lint/typecheck/build.
12. Documenter les commandes.

## Acceptance
`verify-env`, install, build, test et démarrage local fonctionnent depuis un clone propre. `health`/`ready` répondent, CORS et en-têtes de sécurité actifs, backend et frontend démarrent sans collision de port.
