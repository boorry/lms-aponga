# 00 — Master Orchestration Claude Code

## Mission

Transformer progressivement la conception fermée APONGA LMS en un produit testé, documenté et déployable.

## Pré-Gate — Verrouillage avant développement

Avant toute Phase P0, le repository réel doit avoir été audité selon `01_ORCHESTRATION/09_AI_GOVERNANCE_WORKFLOW.md`.

Conditions obligatoires :
- audit du dépôt réel par Claude AI ou revue humaine équivalente ;
- corrections et décisions documentées ;
- aucun blocker architectural non arbitré ;
- mission destinée à Claude Code explicitement validée ;
- baseline Git publiée sur `main`.

Claude Code ne reçoit pas de mission d'implémentation tant que ce pré-gate n'est pas satisfait.

## À propos des « Gate P » de ce document

Chaque phase ci-dessous se termine par une **Gate Px** (« Phase Gate ») : le critère minimal pour passer à la phase suivante. Ces Gate P sont **distinctes** des **Quality Gates G0–G8** de `03_QUALITY_GATES.md`, qui sont des dimensions transversales (build, données, métier, sécurité, API, média, E2E, production) vérifiées à plusieurs reprises au long du projet, pas des jalons séquentiels. Ne pas confondre `Gate P3` (jalon de la phase 3) et `Quality Gate G3` (dimension « Métier ») : les deux existent, avec des définitions différentes, et se complètent plutôt qu'elles ne se substituent l'une à l'autre.

## Phase 0 — Préparation

Lire `09_ENVIRONMENT/ENVIRONMENT_SETUP.md`. Exécuter `08_SCRIPTS/verify-env` puis initialiser le workspace selon `01_ORCHESTRATION/01_WORKFLOW_CLAUDE_CODE.md`.

**Gate P0** : versions conformes, Docker fonctionnel, PostgreSQL et Redis démarrables, lockfiles présents ou bootstrap planifié.

## Phase 1 — Foundation

Mission : `03_TASKS/00_FOUNDATION.md`.

Créer : monorepo/workspace, backend NestJS, frontend Next.js, configuration TypeScript, lint, tests, Docker Compose local, Prisma et health checks. Inclut la configuration de base CORS et des en-têtes de sécurité (T-1001, T-1002) et les endpoints health/readiness (T-1103), car ces éléments doivent exister dès le premier démarrage de l'application, pas être ajoutés a posteriori en fin de projet.

**Gate P1** : backend démarre, frontend démarre, DB/Redis accessibles, `health` et `ready` fonctionnent, CORS et en-têtes de sécurité de base actifs.

## Phase 2 — Data Model

Mission : `03_TASKS/01_DATA_MODEL.md`.

Prisma schema (y compris `users`, `roles`, `user_roles` nécessaires à la phase suivante), migrations, seed minimal, contraintes et repositories.

**Gate P2** : migration from scratch + seed + tests invariants DB.

> **Dépendance corrigée** : cette phase doit précéder Identity & Security, car l'implémentation des comptes et des rôles suppose que les tables correspondantes existent déjà. L'ordre a été corrigé lors de l'audit final (voir `FINAL_AUDIT.md`) — la version précédente de ce document plaçait Identity & Security avant Data Model.

## Phase 3 — Identity & Security

Mission : `03_TASKS/02_IDENTITY_SECURITY.md`.

Implémenter comptes, rôles, permissions, access/refresh tokens, vérification email, rate limiting, Guardian prerequisites et audit sensible. `POST /auth/register` crée toujours un compte Learner (voir `00_REFERENCE/08_CONTRAT_API.md`) ; les autres rôles sont attribués selon la matrice de sécurité ; seul le rôle `administrator` est réservé à un Administrator. Le seed de la phase 2 doit avoir créé le premier compte Administrator (aucun parcours d'auto-promotion n'existe).

**Gate P3** : aucune route sensible accessible sans policy valide ; un compte Administrator seedé permet de se connecter et d'attribuer des rôles.

## Phase 4 — Learning Design & Versioning

Mission : `03_TASKS/03_LEARNING_DESIGN.md`.

Course, Module, Lesson, Resource, CourseVersion, publication atomique, assignation Teacher.

**Gate P4** : snapshot immuable et non-rétroactivité démontrées par tests.

## Phase 5 — Media & Learning Delivery backend

Mission : `03_TASKS/04_MEDIA_LEARNING_DELIVERY.md`.

Implémenter les capacités backend du cycle média : `T-301`, `T-301b`, `T-302`, `T-304`, `T-311`, `T-1003`. Les éléments UI/PWA (`T-302b`, `T-305`, `T-310`) sont explicitement livrés en Phase 11.

**Gate P5** : upload → complete → access → expiration testé ; autorisations média testées ; endpoints vidéo/PDF conformes au contrat. Aucun critère frontend n'est requis à ce stade.

## Phase 6 — Guardian foundation

Mission : `03_TASKS/07_GUARDIAN.md` (volet Phase 6).

Implémenter T-901 et T-901b : création/révocation des liens Guardian et policies nécessaires à INV-08.

**Gate P6** : Guardian >=18, distinction Guardian/mineur, rôle Guardian, unicité, création/révocation et INV-08 testés.

## Phase 7 — Enrollment & Progress

Mission : `03_TASKS/05_ENROLLMENT_PROGRESS.md`.

Enrollment idempotent, pin version, progression, temps passé et calcul completion.

**Gate P7** : INV-01 et INV-08 couverts ; cohérence de version démontrée.

## Phase 8 — Notifications / Jobs

Mission : `03_TASKS/08_NOTIFICATIONS.md`.

Outbox transactionnel, worker BullMQ, retries et idempotence.

**Gate P8** : aucun événement métier perdu lors d'une panne worker simulée ; les jobs rejoués ne produisent pas de doublon.

## Phase 9 — Submission & Feedback

Mission : `03_TASKS/06_SUBMISSION_FEEDBACK.md`.

Soumission, prise en charge explicite, feedback brouillon → publié et événements de notification.

**Gate P9** : Teacher ne voit et ne prend en charge que les Submissions autorisées ; Guardian/Learner permissions respectées ; les transitions d'état sont explicites.

## Phase 10 — Administration / Guardian consultation

Missions : `03_TASKS/09_ADMIN_REPORTING.md` et volet Phase 10 de `03_TASKS/07_GUARDIAN.md`.

Utilisateurs, catalogue, KPIs, settings, audit et consultation Guardian.

**Gate P10** : permissions d'administration testées ; KPIs cohérents ; audit log alimenté ; Guardian ne lit que les mineurs liés et ne peut rien écrire.

## Phase 11 — Frontend

Missions `03_TASKS/10_FRONTEND_PUBLIC_LEARNER.md` à `12_FRONTEND_MANAGER_ADMIN.md`.

Le frontend ne doit consommer que les routes figées du contrat API. Chaque écran implémenté met à jour `02_PROJECT/SCREEN_CONTRACT.md` avec sa route, ses permissions et ses endpoints réellement consommés.

**Gate P11** : responsive, PWA shell, accessibilité de base, contrôles vidéo/PDF, mode économie de données, cache PWA sans vidéo hors-ligne, parcours critiques Playwright.

## Phase 12 — E2E / Validation

Mission : `03_TASKS/13_E2E_VALIDATION.md`.

**Gate P12** : tous les parcours obligatoires de `00_REFERENCE/10_STRATEGIE_DE_TEST.md` §4 sont verts ; `04_VALIDATION/ACCEPTANCE_CHECKLIST.md` entièrement cochée.

## Phase 13 — Deployment

Mission : `03_TASKS/14_DEPLOYMENT.md`.

**Gate P13** : migration revue et appliquée en staging avant production ; sauvegarde et restauration testées ; health/readiness et logs actifs en production ; procédure de rollback documentée.

## Phase 14 — Revue transverse

Mission : `03_TASKS/15_CROSS_CUTTING_REVIEW.md`.

Vérifier architecture, sécurité, invariants, tests, observabilité, documentation et dette technique.

**Gate P14** : liste de corrections produite et traitée ou explicitement reportée dans `07_TRACKING/DECISIONS_DEV.md` avant le pilote.

## Règle de progression

Claude Code ne passe pas à une phase suivante si la Gate P précédente est rouge, sauf décision explicite consignée dans `07_TRACKING/DECISIONS_DEV.md`.
