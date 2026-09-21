# T-FOUNDATION — Foundation

## Objectif
Créer un workspace reproductible conforme au stack.

Respecter la structure cible de `01_ORCHESTRATION/07_REPO_LAYOUT.md` (monorepo `apps/api` + `apps/web`, npm workspaces natif — pas de Turborepo/Nx sans décision explicite).

## Actions
1. Vérifier Node/npm/Docker.
2. Créer/vérifier `.gitignore` avant toute génération de secrets ou installation de dépendances.
3. Créer backend NestJS 12.0.1.
4. Créer frontend Next.js PWA-first et verrouiller sa version exacte ; démarrer le serveur de développement sur le port 3001 (cohérent avec `CORS_ORIGINS` de `.env.example`).
5. Configurer TypeScript 5.9.3 côté backend.
6. Ajouter Prisma 7.x.
7. Préparer PostgreSQL 17 et Redis 8.2 via Docker Compose.
8. Configurer Jest/Supertest/Playwright.
9. Ajouter health/readiness (T-1103).
10. Configurer CORS et les en-têtes de sécurité de base — CSP, HSTS, `X-Content-Type-Options`, `X-Frame-Options` (T-1001, T-1002). Ces éléments doivent exister dès le premier démarrage, pas être ajoutés plus tard.
11. Configurer la génération de la documentation OpenAPI avec `@nestjs/swagger`.
12. Ajouter `argon2` comme dépendance de sécurité pour le hash des mots de passe.
13. Ajouter lint/typecheck/build.
14. Documenter les commandes.

## Acceptance
`.gitignore` protège les secrets et artefacts ; `verify-env`, install, build, test et démarrage local fonctionnent depuis un clone propre avec `package-lock.json` committé. `health`/`ready` répondent, CORS et en-têtes de sécurité actifs, backend et frontend démarrent sans collision de port.
