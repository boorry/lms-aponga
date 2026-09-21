# FINAL_AUDIT.md — APONGA LMS — Revue de verrouillage avant développement

**Date : 2026-09-21**  
**Périmètre :** ZIP `lms-aponga-main.zip` fourni pour la revue de verrouillage, croisé avec l'audit Claude AI du 21/09/2026, les audits précédents et les décisions de conception APONGA déjà établies.

## Verdict

**KIT VERROUILLÉ POUR LE DÉMARRAGE DU DÉVELOPPEMENT, APRÈS APPLICATION DES CORRECTIONS DE CETTE REVUE.**

Le kit ne doit plus demander à Claude Code d'interpréter des points structurants qui peuvent être décidés avant l'implémentation.

La revue a identifié les 8 points `AUD-01` à `AUD-08` de Claude AI, mais aussi des incohérences supplémentaires non détectées par cet audit. Elles ont été traitées directement dans le kit lorsqu'elles pouvaient être déduites des décisions déjà établies. Les seuls choix restant variables sont les versions exactes des composants explicitement laissés en plage (Prisma 7.x, Next.js, Jest, Supertest, Playwright, BullMQ) : leur verrouillage est désormais encadré par une procédure avant installation, sans fallback automatique.

---

# 1. Méthode

La revue a porté sur :

- la structure réelle des 91 entrées du ZIP ;
- les 77 fichiers textuels exploitables ;
- les documents normatifs `00_REFERENCE/` ;
- l'orchestration `01_ORCHESTRATION/` ;
- les tâches `03_TASKS/` ;
- la validation `04_VALIDATION/` ;
- le frontend/template ;
- le suivi `07_TRACKING/` ;
- les scripts `08_SCRIPTS/` ;
- l'environnement `09_ENVIRONMENT/` ;
- `CLAUDE.md`, `README.md`, `FINAL_AUDIT.md`, `CHANGELOG_FINAL.md` ;
- les références croisées, identifiants de tâches, invariants, permissions, routes et états.

Les corrections ont été appliquées dans une copie de travail du kit et seront livrées dans une nouvelle archive.

---

# 2. Résolution des AUD-01 à AUD-08 de Claude AI

## AUD-01 — Permissions orphelines

### Constat

Les permissions `course.review`, `enrollment.read_all` et `submission.read_own` existaient sans couverture API suffisante.

### Correction

Le contrat API définit maintenant explicitement :

- `POST /courses/:id/submit-review` → `course.review` ;
- `GET /admin/enrollments` → `enrollment.read_all` ;
- `GET /submissions/me` → `submission.read_own`.

La permission `submission.review` a également été ajoutée pour rendre explicite la transition `SUBMITTED → IN_REVIEW`.

La matrice rôle → permission est maintenant normative dans `07_SECURITE_ET_AUTORISATION.md`.

**Statut : CLOSED.**

---

## AUD-02 — Registre des invariants

### Constat

INV-01, INV-02, INV-06 à INV-09 étaient utilisés, tandis que INV-03/04/05 n'avaient plus d'énoncé canonique.

### Correction

Un registre unique `INV-01` à `INV-09` est maintenant intégré à `04_MACHINES_ETATS_ET_REGLES_METIER.md`.

`INV-03`, `INV-04` et `INV-05` sont explicitement marqués comme identifiants retirés et non réutilisables.

**Statut : CLOSED.**

---

## AUD-03 — Versions exactes

### Correction

Aucune version obligatoire déjà verrouillée ne peut être remplacée automatiquement.

Si Node 24.21.0, npm 11.19.0, TypeScript 5.9.3 ou NestJS 12.0.1 sont indisponibles :

```text
BLOCKER
→ arrêt
→ décision humaine
```

Pour Prisma 7.x, Next.js, Jest, Supertest, Playwright et BullMQ, une version exacte doit être choisie, vérifiée, consignée puis verrouillée avant installation.

**Statut : CLOSED.**

---

## AUD-04 — `.gitignore`

### Correction

Un `.gitignore` normatif a été ajouté avant le bootstrap applicatif.

Il protège notamment :

- `.env` ;
- `node_modules/` ;
- `dist/` ;
- `.next/` ;
- `coverage/` ;
- rapports Playwright ;
- artefacts locaux.

**Statut : CLOSED.**

---

## AUD-05 — Workflow Claude AI → humain → Claude Code

### Correction

`01_ORCHESTRATION/09_AI_GOVERNANCE_WORKFLOW.md` formalise désormais :

```text
Dépôt réel
↓
Claude AI
↓
Audit / conception
↓
Décision humaine
↓
Mission validée
↓
Claude Code
↓
Implémentation / tests
↓
Review
↓
PR
```

Les audits sont archivés dans `07_TRACKING/AUDIT_LOG.md`, les décisions dans `DECISIONS_DEV.md` et les points ouverts dans `BLOCKERS.md`.

**Statut : CLOSED.**

---

## AUD-06 — Stagiaire

Le périmètre détaillé du stagiaire n'est pas prématurément construit.

Le workflow Git/PR indique toutefois déjà qu'il ne travaille pas directement sur `main`.

**Statut : DEFERRED BY DESIGN — non bloquant.**

---

## AUD-07 — CI/CD

### Correction

GitHub Actions est maintenant la CI de référence.

`.github/workflows/quality-gates.yml` exécute, dès que le workspace applicatif existe :

- lint ;
- typecheck ;
- tests ;
- build.

Avant le bootstrap, la CI fonctionne en mode `kit-only` afin de ne pas prétendre exécuter des commandes Node inexistantes.

**Statut : CLOSED.**

---

## AUD-08 — Branches / PR

### Correction

`01_ORCHESTRATION/10_GIT_BRANCH_PR_WORKFLOW.md` définit :

- `main` comme branche d'intégration ;
- branches `feat/`, `fix/`, `chore/`, `docs/`, `refactor/`, `test/` ;
- Pull Request obligatoire pour le développement applicatif ;
- CI obligatoire ;
- revue humaine ;
- absence de contournement des Quality Gates.

Un template de PR est ajouté dans `.github/pull_request_template.md`.

**Statut : CLOSED.**

---

# 3. Points supplémentaires détectés pendant la revue

## LOCK-01 — Authentification : persistance manquante

### Problème

La sécurité exigeait :

- refresh token opaque stocké en base ;
- rotation ;
- révocation ;
- vérification email ;
- reset password.

Mais le modèle de données ne contenait aucune table correspondante.

### Correction

Ajout :

- `refresh_tokens` ;
- `email_verification_tokens` ;
- `password_reset_tokens` ;
- `users.email_verified_at`.

Les tokens persistants sont stockés sous forme hachée.

Le mot de passe V1 est verrouillé sur **Argon2id**.

**Statut : CLOSED.**

---

## LOCK-02 — `JWT_REFRESH_SECRET` incohérent

Le refresh token étant opaque et persistant en base, un secret JWT dédié au refresh n'était pas cohérent.

### Correction

`JWT_REFRESH_SECRET` est supprimé de `.env.example`.

**Statut : CLOSED.**

---

## LOCK-03 — `domain_events` absent du modèle

`09_NOTIFICATIONS_ET_JOBS.md` utilisait `domain_events`, mais cette table n'apparaissait pas dans le modèle de données définitif.

### Correction

`domain_events` est maintenant explicitement modélisée et reliée à `notification_deliveries`.

**Statut : CLOSED.**

---

## LOCK-04 — Idempotence sans stockage de clé

Le contrat imposait `Idempotency-Key`, mais aucun mécanisme persistant ne permettait de rejouer une réponse après redémarrage.

### Correction

Ajout de `idempotency_keys` avec :

- clé ;
- utilisateur ;
- endpoint ;
- hash de requête ;
- réponse ;
- code HTTP ;
- expiration.

Une même clé avec un payload différent retourne `409`.

**Statut : CLOSED.**

---

## LOCK-05 — Workflow Course incomplet

La machine d'état définissait :

```text
DRAFT → IN_REVIEW → PUBLISHED
```

mais le contrat API ne permettait pas explicitement `DRAFT → IN_REVIEW`.

### Correction

Ajout :

```text
POST /courses/:id/submit-review
```

avec `course.review`.

`Content Author` ne peut pas publier.

**Statut : CLOSED.**

---

## LOCK-06 — Workflow Submission incomplet

La machine d'état définissait :

```text
SUBMITTED → IN_REVIEW
```

mais aucune action API explicite ne réalisait cette transition.

### Correction

Ajout :

```text
POST /teacher/submissions/:id/start-review
```

avec `submission.review`.

Une simple lecture ne modifie jamais l'état.

**Statut : CLOSED.**

---

## LOCK-07 — Feedback : création et publication confondues

Le backlog séparait T-505 et T-506, tandis que l'API combinait `feedback.create` et `feedback.publish` dans une seule route.

### Correction

```text
POST /submissions/:id/feedback
        ↓
DRAFT

POST /feedbacks/:id/publish
        ↓
PUBLISHED
```

La publication déclenche `FeedbackPublished`.

**Statut : CLOSED.**

---

## LOCK-08 — `Submission.ARCHIVED` sans transition normative

Le modèle listait `ARCHIVED`, alors que la machine d'état ne le définissait pas et qu'aucune tâche V1 ne l'utilisait.

### Correction

`ARCHIVED` est retiré du statut V1 des Submissions.

**Statut : CLOSED.**

---

## LOCK-09 — Ordre des phases incompatible avec Guardian

Le workflow initial plaçait Submission avant Guardian alors que T-503 dépend de T-901 et que INV-08 s'applique à l'inscription et à la soumission.

### Correction

Ordre verrouillé :

```text
P5 Media backend
↓
P6 Guardian foundation
↓
P7 Enrollment / Progress
↓
P8 Notifications
↓
P9 Submission / Feedback
↓
P10 Administration + Guardian consultation
↓
P11 Frontend
```

Le domaine Guardian est volontairement livré en deux étapes :

- T-901/T-901b en P6 ;
- T-902 en P10 après disponibilité de Progress/Feedback.

**Statut : CLOSED.**

---

## LOCK-10 — Learning Delivery UI prématuré

Le fichier Media regroupait lecteur vidéo, cache PWA et mode économie de données en Phase 5, alors que le frontend n'arrivait qu'en Phase 11.

### Correction

Phase 5 :

- capacités backend média ;
- accès vidéo/PDF ;
- signed URLs.

Phase 11 :

- contrôles du lecteur ;
- mode économie de données ;
- cache PWA.

**Statut : CLOSED.**

---

## LOCK-11 — `user_roles` sans historique

Le système exigeait la traçabilité des rôles mais le modèle ne conservait qu'une relation many-to-many brute.

### Correction

`user_roles` conserve :

- `granted_at` ;
- `granted_by` ;
- `revoked_at` ;
- `revoked_by`.

Seules les affectations actives donnent une permission.

**Statut : CLOSED.**

---

## LOCK-12 — Suppression physique des Lessons/Resources incompatible avec les références historiques

`progress`, `submissions` et les snapshots historiques pouvaient dépendre de Lessons/Resources dont le brouillon pouvait être supprimé physiquement.

### Correction

Les Modules, Lessons et Resources utilisent `deleted_at` pour les retraits du brouillon.

Aucune suppression physique en V1 lorsqu'une référence historique ou opérationnelle existe.

**Statut : CLOSED.**

---

## LOCK-13 — Submission insuffisamment rattachée

Une Submission possédait `learner_id`, `course_version_id` et `lesson_id`, mais pas de référence directe vers l'Enrollment précis.

### Correction

Ajout de :

```text
submissions.enrollment_id
```

La cohérence Learner / Enrollment / CourseVersion / Lesson est vérifiée transactionnellement.

**Statut : CLOSED.**

---

## LOCK-14 — `IMAGE` incohérent

`media_assets` supportait `IMAGE`, mais `resources.resource_type` ne le listait pas.

### Correction

`IMAGE` est maintenant un type de Resource V1, avec `provider = r2`.

**Statut : CLOSED.**

---

## LOCK-15 — Dashboard Progression sans donnée de temps passé

T-601 demandait le temps passé, mais `progress` ne possédait aucune donnée permettant de le calculer.

### Correction

Ajout :

```text
progress.time_spent_seconds
```

Le cumul ne peut pas diminuer.

Ajout du contrat :

```text
GET /learners/me/dashboard
```

**Statut : CLOSED.**

---

## LOCK-16 — Endpoint Administration ambigu

Le contrat alternait :

```text
GET/PATCH /admin/users
```

et :

```text
PATCH /admin/users/{id}
```

### Correction

Contrat normalisé :

```text
GET   /admin/users
PATCH /admin/users/:id
```

Le rôle `administrator` ne peut être géré que par un Administrator.

**Statut : CLOSED.**

---

## LOCK-18 — Seed Administrator et historique des rôles

Le seed du premier Administrator ne peut pas avoir un `granted_by` humain existant.

### Correction

`user_roles.granted_by` est nullable uniquement pour le bootstrap/system seed. Toutes les affectations administratives normales sont historisées avec `granted_by`.

**Statut : CLOSED.**

---

## LOCK-17 — T-105 non explicitement rattachée

L'audit précédent annonçait une couverture complète des 58 tâches, mais `T-105` n'était pas explicitement cité dans un fichier de mission.

### Correction

`T-105` est explicitement rattachée à `03_TASKS/02_IDENTITY_SECURITY.md`.

Une vérification finale confirme désormais la couverture explicite des **58/58 tâches**.

**Statut : CLOSED.**

---

## LOCK-19 — État Course `ARCHIVED` sans tâche V1

Le modèle et la machine d'état initiale mentionnaient `ARCHIVED`, mais aucune tâche V1 ni route ne définissait sa transition.

### Correction

Le statut `ARCHIVED` est retiré du V1. Le cycle normatif V1 est :

```text
DRAFT → IN_REVIEW → PUBLISHED
PUBLISHED → IN_REVIEW
```

Le retour en édition est explicite via `POST /courses/:id/return-to-edit`. `PATCH /courses/:id` ne peut pas modifier directement le cycle de vie.

**Statut : CLOSED.**

---

# 4. Architecture de vérité après verrouillage

La hiérarchie est maintenant :

```text
00_REFERENCE/
    ↓
règles métier / architecture / données / états / sécurité / API
    ↓
01_ORCHESTRATION/
    ↓
comment implémenter sans modifier la conception
    ↓
03_TASKS/
    ↓
missions concrètes
    ↓
04_VALIDATION/
    ↓
preuves de conformité
    ↓
07_TRACKING/
    ↓
décisions / blockers / audits / environnement
```

`02_PROJECT/` reste un résumé opérationnel sans autorité propre.

---

# 5. Vérifications de cohérence effectuées

## Tâches

- 58 identifiants uniques dans le backlog.
- 58/58 explicitement couverts par les fichiers de mission.

## Invariants

- INV-01 à INV-09 disposent maintenant d'un registre unique.
- INV-03/04/05 sont retirés explicitement et ne peuvent plus être réutilisés.

## Permissions

Les permissions du contrat API sont maintenant alignées sur la liste normative de sécurité.

Une permission supplémentaire, `submission.review`, est explicitement documentée et reliée à la transition `SUBMITTED → IN_REVIEW`.

## États

Les transitions importantes ont maintenant une action API explicite.

Aucune lecture ne modifie implicitement l'état métier.

## API

Les routes d'authentification, de revue de cours, d'enrollment, de submission, de feedback et d'administration ont été alignées avec les règles métier.

## Données

Les éléments nécessaires à :

- authentification persistante ;
- idempotence ;
- outbox ;
- historique des rôles ;
- versionnement ;
- progression ;
- soumission ;

sont maintenant représentés dans le modèle.

## Git

- `main` = intégration ;
- branches dédiées ;
- Pull Request ;
- CI.

## CI

GitHub Actions est défini comme garde-fou automatique.

---

# 6. Points qui restent volontairement variables

Ils ne constituent plus des ambiguïtés d'architecture :

| Élément | Règle |
|---|---|
| Prisma | 7.x ; patch exact choisi puis verrouillé avant bootstrap |
| Next.js | PWA-first ; version exacte choisie puis verrouillée avant bootstrap |
| Jest | version compatible puis verrouillée |
| Supertest | version compatible puis verrouillée |
| Playwright | version compatible puis verrouillée |
| BullMQ | version compatible puis verrouillée |

La règle est :

```text
choix
↓
vérification compatibilité
↓
validation / journalisation
↓
installation exacte
↓
package-lock.json
```

Pour Node 24.21.0, npm 11.19.0, TypeScript 5.9.3 et NestJS 12.0.1, aucune substitution automatique n'est autorisée.

---

# 7. État final

```text
KIT APONGA LMS
      ↓
AUDIT COMPLET
      ↓
CORRECTIONS APPLIQUÉES
      ↓
COHÉRENCE INTER-DOCUMENTS
      ↓
DÉCISIONS EXPLICITES
      ↓
ORCHESTRATION VERROUILLÉE
      ↓
CI / GIT / PR VERROUILLÉS
      ↓
DÉVELOPPEMENT POSSIBLE
```

## Conclusion

Le repository peut maintenant passer à la phase suivante :

**Pré-Gate → Mission G0/P0 Environment Bootstrap.**

Mais Claude Code ne doit pas encore improviser cette mission : Claude AI doit produire le prompt de mission à partir de ce kit verrouillé, puis le responsable humain doit le valider avant son exécution.

Aucun développement métier ne doit être commencé avant cette dernière transmission contrôlée.
