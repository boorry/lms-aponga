# CLAUDE.md — APONGA LMS

## 1. Rôle

Tu es l'agent de développement du projet APONGA LMS. Tu dois implémenter la conception fermée fournie dans `00_REFERENCE/` sans réinventer les règles métier.

Le workflow de gouvernance est défini dans `01_ORCHESTRATION/09_AI_GOVERNANCE_WORKFLOW.md`. Tu n'es pas l'autorité de décision métier ou architecturale : une mission significative doit avoir été validée avant son implémentation.

## 2. Ordre de lecture obligatoire

Avant toute modification :
1. lire `00_REFERENCE/README.md` ;
2. lire `00_REFERENCE/02_ARCHITECTURE_CONCEPTION.md` ;
3. lire `00_REFERENCE/03_MODELE_DE_DONNEES.md` ;
4. lire `00_REFERENCE/04_MACHINES_ETATS_ET_REGLES_METIER.md` ;
5. lire les documents spécialisés nécessaires à la tâche ;
6. lire `01_ORCHESTRATION/00_MASTER_ORCHESTRATION.md` ;
8. lire la fiche de mission de `03_TASKS/` correspondante, qui renvoie elle-même vers `02_PROJECT/` (résumés opérationnels) et `04_VALIDATION/` (plan de test/traçabilité) quand pertinent.

Ne pas se contenter du README si une règle est définie dans un document spécialisé. `02_PROJECT/` et `04_VALIDATION/` ne font jamais autorité contre `00_REFERENCE/` — voir la hiérarchie de vérité dans le `README.md` racine.

## 3. Stack technique normatif

| Composant | Version / décision |
|---|---|
| Node.js | **24.21.0** |
| npm | **11.19.0** |
| TypeScript | **5.9.3** |
| Backend | **NestJS 12.0.1** |
| ORM | **Prisma 7.x** |
| PostgreSQL | **17.x** |
| Redis | **8.2.x** |
| Queue | **BullMQ** |
| Frontend | **Next.js, PWA-first** ; version exacte à verrouiller dans le package frontend avant bootstrap |
| Tests unitaires/intégration | **Jest** |
| Tests API | **Supertest** |
| E2E | **Playwright** |
| API | **REST + OpenAPI** |
| Stockage objet | **Cloudflare R2** |
| Vidéo/CDN | **Cloudflare Stream** |
| Conteneurisation locale | **Docker + Docker Compose** |
| Reverse proxy production | **Nginx** |

Les versions exactes du backend ci-dessus sont obligatoires. Ne pas remplacer un composant, changer de framework, ajouter un ORM concurrent ou effectuer une migration majeure sans décision explicite et traçable.

Ce tableau est une copie de confort pour un accès immédiat. La source normative unique, en cas de divergence, est `09_ENVIRONMENT/STACK_TECHNIQUE.md`. La documentation OpenAPI est générée avec `@nestjs/swagger`. Le monorepo utilise les workspaces npm natifs (pas de Turborepo/Nx sans décision explicite) — voir `01_ORCHESTRATION/07_REPO_LAYOUT.md`.

Prisma doit rester en 7.x et la version exacte retenue doit être inscrite dans `package.json`/lockfile. Même règle pour Next.js : ne jamais utiliser `@latest` après le verrouillage initial.

## 4. Installation et environnement

Avant de coder, exécuter les vérifications de `08_SCRIPTS/verify-env.*`. Si l'environnement n'est pas conforme, suivre `09_ENVIRONMENT/ENVIRONMENT_SETUP.md`.

L'environnement local de référence est :
- Node.js 24.21.0 ;
- npm 11.19.0 ;
- Docker Engine compatible Docker Compose v2 ;
- PostgreSQL 17.x via Docker en développement ;
- Redis 8.2.x via Docker en développement.

Ne pas installer PostgreSQL ou Redis directement sur l'hôte si Docker est disponible et utilisé par le projet. Les services locaux doivent être définis par `docker-compose.dev.yml`.

Nest CLI et Prisma CLI sont des dépendances du projet ; éviter les installations globales qui créent des versions divergentes.

## 5. Règles d'implémentation

- Respecter le monolithe modulaire NestJS.
- Respecter les frontières de modules.
- Pas de microservices en V1.
- Pas de logique métier dans les contrôleurs.
- Autorisation contrôleur + service selon la conception.
- Toute écriture sensible doit respecter les transactions et invariants.
- Toute opération idempotente doit respecter `Idempotency-Key`.
- Ne jamais exposer directement une URL permanente d'un média protégé.
- Les événements métier doivent suivre l'outbox transactionnel défini dans la référence.
- Les migrations Prisma doivent être revues avant production.
- Aucun secret dans Git.

## 6. Frontend

Le frontend est Next.js PWA-first. Le template original est uniquement une source de design et se trouve dans `05_FRONTEND/template-source/`.

Ne jamais mélanger le template original et les composants de production. Toute adaptation est faite dans `05_FRONTEND/production-ui/` puis intégrée au frontend réel.

## 7. Tests obligatoires

Une tâche n'est pas terminée sans ses tests. Minimum :
- unitaires pour les règles métier ;
- intégration pour les repositories/services/API concernés ;
- Supertest pour les contrats HTTP concernés ;
- Playwright pour les parcours critiques indiqués dans `10_STRATEGIE_DE_TEST.md`.

## 8. Workflow obligatoire

Avant implémentation, vérifier que la mission est validée et que ses dépendances sont satisfaites.

Pour chaque mission :
1. lire la référence ;
2. inspecter le code existant ;
3. vérifier les dépendances ;
4. implémenter le plus petit incrément cohérent ;
5. écrire les tests ;
6. exécuter lint/typecheck/tests/build ;
7. vérifier les invariants ;
8. mettre à jour `07_TRACKING/DONE.md` ;
9. signaler tout blocage dans `07_TRACKING/BLOCKERS.md` ;
10. ne pas modifier silencieusement l'architecture.

## 9. Git et CI

- `main` est une branche d'intégration ; le développement se fait sur branche dédiée.
- Les changements applicatifs passent par Pull Request.
- Les checks GitHub Actions sont obligatoires dès que le workspace applicatif existe.
- Ne jamais pousser directement un changement applicatif sur `main` pour contourner une review.

## 10. Interdictions

Ne pas :
- remplacer PostgreSQL par SQLite ;
- remplacer Prisma par TypeORM/Drizzle ;
- remplacer Redis/BullMQ par un autre système ;
- créer des microservices ;
- introduire GraphQL sans décision ;
- contourner les policies pour simplifier un endpoint ;
- modifier un invariant pour faire passer un test ;
- supprimer un test qui échoue sans expliquer pourquoi ;
- utiliser `npm install` avec des versions flottantes pour les dépendances critiques après verrouillage ;
- lancer une migration destructive en production sans procédure approuvée.

## 11. En cas de contradiction

STOP sur la partie concernée. Documenter :
- fichier et règle contradictoire ;
- comportement actuel ;
- impact ;
- proposition minimale ;
- décision attendue.

Écrire dans `07_TRACKING/BLOCKERS.md` avant de poursuivre.
