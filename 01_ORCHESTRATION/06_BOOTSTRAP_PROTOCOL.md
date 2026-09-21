# Bootstrap Protocol

Claude Code doit effectuer les opérations dans cet ordre :

1. Vérifier Git et l'état du dépôt.
2. Lire `CLAUDE.md` et `09_ENVIRONMENT/STACK_TECHNIQUE.md`.
3. Vérifier Node 24.21.0 et npm 11.19.0.
4. Vérifier Docker/Compose.
5. Démarrer PostgreSQL 17 et Redis 8.2 avec `docker-compose.dev.yml`.
6. Créer le workspace NestJS 12.0.1 sans utiliser une CLI globale comme source de vérité.
7. Installer TypeScript 5.9.3.
8. Installer Prisma 7.x et générer le client.
9. Créer le frontend Next.js et verrouiller sa version exacte.
10. Installer Jest, Supertest, Playwright et BullMQ dans des versions compatibles, puis les verrouiller.
11. Créer les `.env` à partir des exemples sans committer les secrets.
12. Exécuter migrations/validation Prisma.
13. Exécuter lint, typecheck, tests et build.
14. Remplir `07_TRACKING/ENVIRONMENT_LOG.md`.
15. Si un prérequis échoue, ne pas contourner le contrôle : consigner le blocage.

## Idempotence

Relancer le bootstrap ne doit pas détruire les données locales ni réinstaller des versions différentes. `reset-dev.sh` est la seule commande explicitement destructive pour les volumes locaux.
