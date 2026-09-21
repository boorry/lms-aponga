# 03 — Modèle de données — APONGA LMS

**Statut : schéma définitif pour le V1.** Ce document intègre les corrections demandées par l'analyse critique (C-03, C-07, C-08, C-09) et les décisions architecturales complémentaires (ADR-006, 007, 009, 012, 015).

---

## 1. Diagramme relationnel (vue d'ensemble)

```text
users ───< user_roles >─── roles
  │  │
  │  └──< guardianships >──┐ (guardian_user_id, minor_user_id → users)
  │
  ├──< course_teachers >── courses ──< course_versions
  │                            │            (snapshot JSONB immuable)
  │                            ├──< modules ──< lessons ──< resources ── media_assets
  │                            │
  │                            └──< enrollments ──< progress
  │                                     │
  │                                     └── course_version_id (FK, pin de version)
  │
  ├──< submissions ── media_assets
  │        │
  │        └──< feedbacks ── media_assets (réponse, optionnelle)
  │
  └──< audit_log
       notification_deliveries
       settings (table globale, sans FK vers users)
```

Chaque flèche `──<` signifie « un vers plusieurs ». `media_assets` est référencée depuis trois points d'attache distincts (`resources`, `submissions`, `feedbacks`) — voir `06_MEDIA_LIFECYCLE.md` pour la distinction entre leurs cycles de vie respectifs.

## 2. Tables

### `users`
```text
id UUID PK
email CITEXT UNIQUE
password_hash
status (ACTIVE / DISABLED)
birth_date DATE                 -- NOT NULL pour tout compte avec le rôle Learner (voir §3)
country_code
locale
created_at
updated_at
```
Le champ `person_id` envisagé précédemment est retiré : sans usage métier concret en V1, il n'ajoutait que de l'ambiguïté (recommandation de l'analyse reçue, adoptée telle quelle).

**Règle** : le statut « mineur » (âge < 15 ans) n'est jamais stocké ; il est calculé à la volée à partir de `birth_date`, pour rester toujours exact.

### `roles` / `user_roles`
```text
roles(id PK, code UNIQUE, name)
  -- codes : learner, teacher, content_author, academy_manager, administrator, guardian

user_roles(user_id FK, role_id FK)
```

### `guardianships`
```text
id UUID PK
guardian_user_id FK → users
minor_user_id FK → users
relationship (nullable)
consent_given_at (timestamp)     -- capturé à la création du lien en V1 (voir 04 §4)
is_active boolean
deactivated_at (nullable)
deactivated_by (nullable, FK → users)
created_at
created_by FK → users            -- toujours Academy Manager ou Administrator
```
**Contrainte DB** : `CHECK (guardian_user_id <> minor_user_id)`.
**Contrainte DB** : unicité de la relation active — `UNIQUE (guardian_user_id, minor_user_id) WHERE is_active = true`.

### `courses`
```text
id UUID PK
slug UNIQUE
title_i18n JSONB, description_i18n JSONB
level, type
status (DRAFT / IN_REVIEW / PUBLISHED / ARCHIVED)
enrollment_open boolean DEFAULT true
published_version_id (nullable, FK → course_versions)   -- version actuellement servie
current_version_number integer DEFAULT 0
price_amount (nullable)          -- réservé V2
price_currency (nullable)        -- réservé V2
created_at, updated_at
```
Cette table représente **toujours le brouillon de travail courant** (voir `05_VERSIONNEMENT_PEDAGOGIQUE.md`) ; `published_version_id` pointe vers l'instantané figé réellement consommé par les inscrits.

### `course_teachers`
```text
id PK
course_id FK → courses
user_id FK → users               -- doit avoir le rôle Teacher (policy applicative, voir 04 §5)
assigned_by FK → users           -- doit être Manager/Admin (policy d'autorisation)
assigned_at timestamp
role_in_course (nullable : "main_teacher", "assistant")
is_active boolean
deactivated_at (nullable)
deactivated_by (nullable, FK → users)
```
**Contrainte DB** : unicité de l'assignation active — `UNIQUE (course_id, user_id) WHERE is_active = true`.

### `course_versions`
```text
id UUID PK
course_id FK → courses
version_number integer
snapshot JSONB                   -- Course + Modules + Lessons + Resources + ordre + is_required + requires_submission
published_by FK → users
published_at timestamp
```
**Contrainte DB** : `UNIQUE (course_id, version_number)`. Table append-only — aucune ligne n'est jamais modifiée ni supprimée.

### `modules`
```text
id UUID PK, course_id FK, title_i18n JSONB, position
```

### `lessons`
```text
id UUID PK, module_id FK, title_i18n JSONB, position
content_type, requires_submission boolean
is_required boolean NOT NULL DEFAULT true    -- ajouté (C-12, ADR-006)
```

### `resources`
```text
id UUID PK, lesson_id FK
resource_type (VIDEO/AUDIO/PDF)
media_asset_id FK → media_assets             -- remplace external_url (C-03)
bpm (nullable), time_signature (nullable)
```

### `enrollments`
```text
id UUID PK
learner_id FK → users
course_id FK → courses
course_version_id FK → course_versions       -- pin de version (C-10, ADR-002)
payer_user_id (nullable, FK → users)         -- réservé V2, égal à learner_id en V1
status (ACTIVE / COMPLETED / CANCELLED)
enrolled_at, completed_at (nullable), cancelled_at (nullable)
```
**Contrainte DB** : `UNIQUE (learner_id, course_id) WHERE status = 'ACTIVE'` (C-11).

### `progress`
```text
id UUID PK
enrollment_id FK → enrollments
lesson_id FK → lessons
course_version_id FK → course_versions       -- dénormalisé depuis enrollment, pour permettre une contrainte de cohérence (C-08)
status (NOT_STARTED / IN_PROGRESS / COMPLETED)
started_at (nullable), completed_at (nullable)
updated_at
```

### `submissions`
```text
id UUID PK
learner_id FK → users
course_version_id FK → course_versions       -- (ADR-003)
lesson_id FK → lessons
media_id FK → media_assets                   -- une seule pièce média en V1 (C-19)
notes
status (SUBMITTED / IN_REVIEW / FEEDBACK_GIVEN / CANCELLED / ARCHIVED)
submitted_at, created_at
retention_expires_at                         -- calculé = submitted_at + durée de rétention par défaut (24 mois)
```
**Contrainte DB** : `UNIQUE (learner_id, lesson_id) WHERE status IN ('SUBMITTED', 'IN_REVIEW')` — une seule soumission active à la fois par leçon (C-04, C-21).

### `feedbacks`
```text
id UUID PK
submission_id FK → submissions
teacher_id FK → users
response_text
response_media_id (nullable, FK → media_assets)
status (DRAFT / PUBLISHED)                   -- (C-13)
created_at, published_at (nullable)
```
**Contrainte DB** : `UNIQUE (submission_id) WHERE status = 'PUBLISHED'` — un seul feedback publié par soumission en V1.

### `media_assets`
Table technique partagée, décrite en détail dans `06_MEDIA_LIFECYCLE.md`.
```text
id UUID PK
owner_user_id FK → users
provider (r2 / stream)
object_key
resource_kind (VIDEO / AUDIO / PDF / IMAGE)
mime_type, size_bytes, duration_seconds (nullable)
checksum (nullable)
status (INITIATED / UPLOADING / READY / FAILED / DELETED)
created_at, ready_at (nullable)
```

### `settings`
```text
key UNIQUE, value JSONB
-- inclut notamment : max_active_submissions_per_teacher (défaut 20),
--                     submission_retention_months (défaut 24)
```

### `audit_log`
```text
id UUID PK, actor_user_id FK, action, entity_type, entity_id, metadata JSONB, created_at
```

### `notification_deliveries`
Décrite en détail dans `09_NOTIFICATIONS_ET_JOBS.md`.
```text
id UUID PK, event_id, channel, recipient_user_id FK, template_code
status, attempt_count, last_error (nullable), sent_at (nullable), created_at
```

## 3. Tables réservées V2 — non construites en V1

```text
subscriptions
payment_transactions   -- avec identifiant externe unique pour l'idempotence des webhooks
refunds
badges / user_badges
certificates
```

## 4. Ce qui a changé par rapport à la révision précédente

| Changement | Raison |
|---|---|
| Retrait de `users.person_id` | Sans usage concret, source d'ambiguïté (C-07 / recommandation reçue) |
| `users.birth_date` NOT NULL pour les Learners | Alignement modèle/backlog (C-07) |
| Ajout `courses.published_version_id` | Distinction claire brouillon / version servie (C-01) |
| Ajout `lessons.is_required` | Calcul de complétion explicite (C-12, ADR-006) |
| `resources.external_url` remplacé par `resources.media_asset_id` | Cycle de vie du média unifié (C-03) |
| Ajout `enrollments.course_version_id`, `cancelled_at` | Pin de version, annulation tracée (C-10, C-11) |
| Ajout `progress.course_version_id`, `started_at` | Cohérence de version vérifiable (C-08, C-10) |
| `submissions.media_url` remplacé par `submissions.media_id` ; ajout `course_version_id` | Cycle média unifié, rattachement de version (C-03, ADR-003) |
| Ajout contrainte unicité soumission active par leçon | Cardinalité fermée (C-04, C-21) |
| Ajout `feedbacks.status`, `published_at` | Cardinalité et immutabilité fermées (C-13) |
| Ajout `course_teachers.deactivated_at/by` | Historisation robuste (C-09) |
| Ajout `guardianships.deactivated_at/by`, `created_by`, contraintes d'unicité et de distinction | Règles Guardian fermées (C-06) |
| Nouvelle table `media_assets` | Cycle de vie des médias unifié (C-03) |
| Nouvelle table `notification_deliveries` | Traçabilité et idempotence des notifications (C-14) |
