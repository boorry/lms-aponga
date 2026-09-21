# CHANGELOG_FINAL.md — APONGA LMS Development Ready Kit

> **Note historique :** la section initiale décrit l'état du kit avant la revue de verrouillage du 21/09/2026. Le verdict actuel est celui de `FINAL_AUDIT.md`, qui la remplace comme état de référence.

Modifications apportées lors de l'audit final, par fichier. Voir `FINAL_AUDIT.md` pour le détail et la justification de chaque décision.

## Fichiers renommés

| Ancien nom | Nouveau nom | Raison |
|---|---|---|
| 03_TASKS/01_IDENTITY_SECURITY.md | `03_TASKS/02_IDENTITY_SECURITY.md` | Correction de l'ordre Data Model → Identity |
| 03_TASKS/02_DATA_MODEL.md | `03_TASKS/01_DATA_MODEL.md` | Correction de l'ordre Data Model → Identity |
| 03_TASKS/04_MEDIA.md | `03_TASKS/04_MEDIA_LEARNING_DELIVERY.md` | Périmètre élargi (voir ci-dessous) |

## Fichiers réécrits ou modifiés en profondeur

- **`01_ORCHESTRATION/00_MASTER_ORCHESTRATION.md`** — Gates renommées `G0-G9,G11` → `P0-P14` ; Phase 2 (Data Model) et Phase 3 (Identity & Security) permutées ; Gates manquantes ajoutées pour les phases 10, 12, 13, 14 ; Phase 5 renommée « Media & Learning Delivery » avec périmètre élargi ; note de non-confusion avec les Quality Gates ajoutée.
- **`01_ORCHESTRATION/03_QUALITY_GATES.md`** — note de non-confusion avec les Phase Gates ajoutée en tête de fichier.
- **`01_ORCHESTRATION/02_CONTEXT_MINIMAL.md`** — section « Data Model » ajoutée (absente) ; ordre Foundation/Data Model/Identity corrigé ; section « Media » renommée « Media & Learning Delivery ».
- **`CLAUDE.md`** — note de source canonique unique pour le stack (renvoi vers `09_ENVIRONMENT/STACK_TECHNIQUE.md`) ; mention de `@nestjs/swagger` et des workspaces npm natifs ; ordre de lecture complété avec un renvoi vers `02_PROJECT/` et `04_VALIDATION/`.
- **`README.md`** (racine) — sections « Résumés opérationnels (`02_PROJECT/`) » et « Validation de développement (`04_VALIDATION/`) » ajoutées.
- **`00_REFERENCE/06_MEDIA_LIFECYCLE.md`** — règle de routage provider (VIDEO→stream, AUDIO/PDF/IMAGE→r2) ajoutée, absente jusqu'ici.
- **`00_REFERENCE/07_SECURITE_ET_AUTORISATION.md`** — quatre permissions ajoutées à la liste normative : `progress.read_own`, `progress.write_own`, `feedback.read_own`, `admin.reports.read`.
- **`00_REFERENCE/08_CONTRAT_API.md`** — règle de rôle par défaut à l'inscription ajoutée ; nouvelle section « Permission et idempotence par endpoint » (39 endpoints) ; renumérotation des sections suivantes.
- **`00_REFERENCE/16_STACK_TECHNIQUE.md`** — contenu remplacé par un pointeur vers `09_ENVIRONMENT/STACK_TECHNIQUE.md` (suppression du doublon).
- **`09_ENVIRONMENT/.env.example`** — ajout de `SEED_ADMIN_EMAIL`, `SEED_ADMIN_PASSWORD`, `WEB_PORT`, `NEXT_PUBLIC_API_BASE_URL` ; en-tête explicatif ajouté.
- **`02_PROJECT/ARCHITECTURE.md`, `PRD.md`, `PRD_UI.md`, `TODO.md`** — bandeau de subordination à `00_REFERENCE/` ajouté.
- **`02_PROJECT/TODO.md`** — ordre Data model/Identity corrigé dans la checklist.

## Fichiers de tâches (`03_TASKS/`) modifiés

- **`00_FOUNDATION.md`** — actions ajoutées : CORS/en-têtes de sécurité (T-1001, T-1002), health/readiness explicitement lié à T-1103, génération OpenAPI (`@nestjs/swagger`), port frontend 3001, renvoi vers `07_REPO_LAYOUT.md`.
- **`01_DATA_MODEL.md`** *(ex-02)* — exigence de seed (compte Administrator, variables d'environnement) ajoutée ; note de non-rattachement à des `T-xxx` dédiés.
- **`02_IDENTITY_SECURITY.md`** *(ex-01)* — prérequis Data Model explicité ; règle de rôle par défaut à l'inscription ajoutée ; rattachement de T-1001/T-1002.
- **`03_LEARNING_DESIGN.md`** — identifiants `T-xxx` explicités (au lieu d'aucune citation) ; rattachement de T-201, T-202, T-203 (catalogue), auparavant orphelins.
- **`04_MEDIA_LEARNING_DELIVERY.md`** *(ex-04_MEDIA.md)* — périmètre élargi en deux volets (cycle média technique + consommation d'une leçon) pour rattacher T-302, T-302b, T-304, T-305, T-310, auparavant orphelins ; rattachement de T-1003 ; règle de routage provider répétée pour visibilité immédiate.
- **`05_ENROLLMENT_PROGRESS.md`** — notation de plage ambiguë remplacée par une liste explicite incluant T-401b.
- **`07_GUARDIAN.md`** — notation de plage ambiguë remplacée par une liste explicite incluant T-901b.
- **`08_NOTIFICATIONS.md`** — identifiants T-801, T-802, T-803 explicités (au lieu d'aucune citation).
- **`09_ADMIN_REPORTING.md`** — identifiants T-701b, T-705, T-706, T-710 explicités (au lieu d'aucune citation).
- **`10_FRONTEND_PUBLIC_LEARNER.md`** — rattachement de T-201/T-202/T-203 côté frontend ; renvoi vers `SCREEN_CATALOGUE.md`/`PRD_UI.md`/`SCREEN_CONTRACT.md` ; exigence de mise à jour de `SCREEN_CONTRACT.md` ajoutée.
- **`11_FRONTEND_TEACHER_GUARDIAN.md`** — mêmes renvois ajoutés.
- **`12_FRONTEND_MANAGER_ADMIN.md`** — mêmes renvois ajoutés.
- **`13_E2E_VALIDATION.md`** — renvoi vers les trois fichiers de `04_VALIDATION/`, auparavant orphelins.
- **`14_DEPLOYMENT.md`** — rattachement explicite de T-1101, T-1102 ; critère d'acceptation ajouté.

## Fichiers non modifiés (vérifiés conformes)

Les 16 documents de `00_REFERENCE/` autres que `06`, `07`, `08` et `16` (soit `00`, `01`, `02`, `03`, `04`, `05`, `09` à `15`) ont été relus intégralement et n'ont nécessité aucune correction. Les scripts de `08_SCRIPTS/` ont été relus ligne à ligne (logique, chemins, healthchecks) sans défaut trouvé. 07_TRACKING/*.md n'a pas été modifié : ces fichiers sont des modèles vides destinés à l'équipe de développement réelle, pas à l'auditeur.

## Vérifications automatiques exécutées après corrections

- Scan de toutes les références de fichiers (un nom de fichier Markdown, `.sh`, `.yml`, `.ps1`, `.env`) dans les 76 fichiers du dépôt : aucune référence cassée hors des trois renvois historiques intentionnels vers l'ancien pack `07/08/09` reçu séparément (documentés comme obsolètes dans `00_REFERENCE/01_ANALYSE_CRITIQUE_ET_SUIVI.md`).
- Extraction des 58 identifiants `T-xxx` de `13_BACKLOG_V1.md` et vérification de leur présence (citation directe ou plage explicite) dans `03_TASKS/` : couverture 58/58 après corrections (contre 50/58 avant).
- Recherche de collisions résiduelles entre `Gate G` et `Gate P` : aucune.


---

# Revue de verrouillage — 2026-09-21

Cette section documente les corrections appliquées après l'audit Claude AI et la revue de verrouillage.

## Gouvernance

- ajout de `01_ORCHESTRATION/09_AI_GOVERNANCE_WORKFLOW.md` ;
- ajout de `01_ORCHESTRATION/10_GIT_BRANCH_PR_WORKFLOW.md` ;
- ajout de `07_TRACKING/AUDIT_LOG.md` ;
- ajout d'une structure de décisions/blockers/done ;
- ajout de GitHub Actions et d'un template PR ;
- ajout du pré-gate obligatoire avant Claude Code.

## Sécurité / identité

- ajout de `email_verified_at` ;
- ajout des tables `refresh_tokens`, `email_verification_tokens`, `password_reset_tokens` ;
- choix V1 verrouillé sur Argon2id ;
- suppression de `JWT_REFRESH_SECRET` incohérent avec le refresh opaque ;
- historique des rôles dans `user_roles` ;
- matrice rôle → permission normative ;
- ajout de `POST /auth/verify-email`.

## API / métier

- ajout de `course.review` avec `POST /courses/:id/submit-review` ;
- ajout de `enrollment.read_all` avec `GET /admin/enrollments` ;
- ajout de `submission.read_own` avec `GET /submissions/me` ;
- ajout de `submission.review` avec `POST /teacher/submissions/:id/start-review` ;
- séparation Feedback DRAFT / PUBLISHED ;
- normalisation de `/admin/users` et `/admin/users/:id` ;
- suppression de `Submission.ARCHIVED` en V1 ;
- registre unique INV-01 à INV-09 ;
- explicitation du rattachement Submission → Enrollment ;
- ajout de `progress.time_spent_seconds` et du dashboard Learner.

## Données / infrastructure

- ajout de `domain_events` ;
- ajout de `idempotency_keys` ;
- ajout de `media IMAGE` côté Resource ;
- soft-delete des Modules/Lessons/Resources ;
- procédure stricte de verrouillage des versions ;
- `.gitignore` ajouté ;
- CI GitHub Actions ajoutée.

## Orchestration

- réordonnancement des phases pour respecter les dépendances Guardian → Enrollment → Submission ;
- séparation Media backend / Learning Delivery frontend ;
- T-105 explicitement rattachée à la mission Identity ;
- 58/58 tâches du backlog explicitement couvertes.
