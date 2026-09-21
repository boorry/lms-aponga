# Quality Gates

Ces gates (**G0–G8**) sont des dimensions transversales, vérifiées à plusieurs reprises au long du projet — elles sont distinctes des **Gate P0–P14** (jalons séquentiels par phase) de `00_MASTER_ORCHESTRATION.md`. Un `G3` ici (dimension « Métier ») n'a rien à voir avec la `Gate P3` de l'orchestration (jalon de la phase Identity & Security).

## G0 — Environnement
- Node 24.21.0
- npm 11.19.0
- Docker/Compose fonctionnels
- PostgreSQL 17.x
- Redis 8.2.x
- installation reproductible

## G1 — Build
- TypeScript sans erreur
- lint sans erreur
- tests verts
- build backend/frontend vert
- ces checks sont exécutés automatiquement par GitHub Actions dès qu'un `package-lock.json` existe ; une PR applicative ne peut pas être considérée validée sur la seule exécution locale

## G2 — Data
- Prisma schema cohérent
- migration from scratch reproductible
- seed idempotent

## G3 — Métier
- transitions autorisées/refusées testées
- invariants couverts

## G4 — Sécurité
- auth + permissions + object-level policies testées
- secrets absents du repo

## G5 — API
- routes conformes au contrat
- erreurs normalisées
- pagination/idempotence conformes

## G6 — Média
- lifecycle complet testé
- signed URLs testées

## G7 — E2E
- parcours critiques verts

## G8 — Production
- migrations revue
- backup/restauration validés
- health/readiness
- logs/correlation ID
- rollback documenté


## Politique CI

GitHub Actions est la CI de référence du dépôt. La CI exécute au minimum lint, typecheck, tests et build sur les Pull Requests et les pushes vers `main`.

Tant que le repository ne contient pas encore le workspace applicatif et son `package-lock.json`, la CI est en mode **kit-only** : elle valide la présence de la structure et n'exécute pas de commandes Node inexistantes. Dès le bootstrap Foundation, l'absence de `package-lock.json` sur une branche applicative est un échec CI.
