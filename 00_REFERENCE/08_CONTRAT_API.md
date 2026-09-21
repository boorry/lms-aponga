# 08 — Contrat API — APONGA LMS

**Statut : normatif.** Ferme C-05 et C-16. Ce document est la référence jusqu'à la génération d'un contrat OpenAPI à partir du code, qui en deviendra alors la source de vérité vivante (sans contredire les décisions ci-dessous).

---

## 1. Conventions générales

| Sujet | Convention |
|---|---|
| Base path | `/api/v1` |
| Authentification | Bearer access token (`Authorization: Bearer ...`) ou cookie de session selon le flux |
| Pagination | `?page=1&pageSize=20` (défaut 20, max 100) ; réponse enveloppée : `{ "data": [...], "meta": { "page": 1, "pageSize": 20, "total": 134 } }` |
| Tri | `?sort=field` ou `?sort=-field` (ordre décroissant) |
| Filtres | `?filter[field]=value` |
| Idempotence | En-tête `Idempotency-Key` obligatoire sur : création d'Enrollment, finalisation d'upload média, création de Submission, publication de Course |
| Versioning | Le numéro de version est dans le chemin (`/v1`), pas dans un en-tête |

## 2. États autorisés dans les réponses API

**Aucune route ne doit jamais renvoyer ou accepter `PENDING`** comme statut de Submission (C-05). Seuls les états listés dans `04_MACHINES_ETATS_ET_REGLES_METIER.md` sont valides, partout.

## 3. Format d'erreur

```json
{
  "code": "COURSE_NOT_PUBLISHED",
  "message": "Course is not published",
  "details": {},
  "requestId": "..."
}
```

| Code HTTP | Usage |
|---|---|
| 400 | Payload invalide |
| 401 | Non authentifié |
| 403 | Permission insuffisante ou hors périmètre objet |
| 404 | Ressource inexistante ou non visible pour l'utilisateur courant |
| 409 | Conflit métier (ex. Enrollment déjà actif) |
| 422 | Règle métier non satisfaite (distincte d'une simple erreur de validation) |
| 429 | Limite de fréquence atteinte |
| 500 | Erreur inattendue |

## 4. Endpoints par domaine

### Identity
```text
POST /auth/register
POST /auth/login
POST /auth/refresh
POST /auth/logout
POST /auth/forgot-password
POST /auth/reset-password
GET  /users/me
PATCH /users/me
```

**Rôle par défaut à l'inscription** *(ajouté lors de l'audit final — non spécifié jusqu'ici, voir `FINAL_AUDIT.md`)* : `POST /auth/register` attribue toujours et uniquement le rôle `learner`. Aucun autre rôle ne peut être obtenu par auto-inscription. Teacher, Content Author, Academy Manager, Administrator et Guardian sont exclusivement attribués par un Administrator via `PATCH /admin/users/{id}` (voir §4 Administration). Le tout premier compte Administrator est créé par le seed de développement (`01_DATA_MODEL.md`), jamais par auto-inscription ni promotion automatique.

### Catalogue
```text
GET /courses
GET /courses/:id
GET /courses/:id/versions
```

### Learning Design & assignation
```text
POST  /courses
PATCH /courses/:id
POST  /courses/:id/publish
POST  /courses/:id/teachers
DELETE /courses/:id/teachers/:teacherId
PATCH /courses/:id/enrollment-status
```

### Enrollment
```text
POST /courses/:id/enrollment
GET  /enrollments/me
POST /admin/enrollments
```

### Learning Delivery
```text
GET  /courses/:id/lessons/:lessonId
POST /lessons/:lessonId/progress
GET  /enrollments/:id/progress
GET  /lessons/:lessonId/resources/:resourceId/access
```

### Submission / Feedback
```text
POST /media/upload-url
POST /media/:id/complete
POST /submissions
POST /submissions/:id/cancel
GET  /teacher/submissions
POST /submissions/:id/feedback
GET  /learners/me/feedbacks
GET  /submissions/:id/access
GET  /feedbacks/:id/access
```

### Guardian
```text
POST /admin/guardianships
DELETE /admin/guardianships/:id
GET  /guardian/minors
GET  /guardian/minors/:minorId/progress
GET  /guardian/minors/:minorId/feedbacks
```

### Administration
```text
GET/PATCH /admin/users
GET/PATCH /admin/settings
GET /admin/audit-log
GET /admin/reports/kpis
```

## 5. Permission et idempotence par endpoint

*(section ajoutée lors de l'audit final : la liste d'endpoints ci-dessus donnait la méthode et l'URL, mais pas systématiquement la permission requise — voir `FINAL_AUDIT.md`. Les schémas complets de payload/réponse restent volontairement différés à la génération OpenAPI à partir des DTO NestJS au moment du code : les lister à la main ici serait long, redondant avec le code, et rapidement obsolète. Permission et idempotence, en revanche, sont des décisions d'architecture qui doivent être figées avant le code.)*

| Méthode | Endpoint | Permission requise | Idempotent |
|---|---|---|---|
| POST | `/auth/register` | Public | Non |
| POST | `/auth/login` | Public | Non |
| POST | `/auth/refresh` | Self (refresh token valide) | Non |
| POST | `/auth/logout` | Self | Non |
| POST | `/auth/forgot-password` | Public | Non |
| POST | `/auth/reset-password` | Public (token à usage unique) | Non |
| GET | `/users/me` | Self | — |
| PATCH | `/users/me` | Self | Non |
| GET | `/courses` | Public | — |
| GET | `/courses/:id` | Public | — |
| GET | `/courses/:id/versions` | `course.edit` | — |
| POST | `/courses` | `course.create` | Non |
| PATCH | `/courses/:id` | `course.edit` | Non |
| POST | `/courses/:id/publish` | `course.publish` | **Oui** (`Idempotency-Key`) |
| POST | `/courses/:id/teachers` | `course_teacher.manage` | Non |
| DELETE | `/courses/:id/teachers/:teacherId` | `course_teacher.manage` | Non |
| PATCH | `/courses/:id/enrollment-status` | `enrollment.manage_status` | Non |
| POST | `/courses/:id/enrollment` | `enrollment.create` | **Oui** (`Idempotency-Key`) |
| GET | `/enrollments/me` | `enrollment.read_own` | — |
| POST | `/admin/enrollments` | `enrollment.create` (portée administrateur) | **Oui** (`Idempotency-Key`) |
| GET | `/courses/:id/lessons/:lessonId` | `enrollment.read_own` (INV-01) | — |
| POST | `/lessons/:lessonId/progress` | `progress.write_own` | Non |
| GET | `/enrollments/:id/progress` | `progress.read_own` | — |
| GET | `/lessons/:lessonId/resources/:resourceId/access` | `media.access` | — |
| POST | `/media/upload-url` | `media.upload` | Non |
| POST | `/media/:id/complete` | `media.upload` | **Oui** (`Idempotency-Key`) |
| POST | `/submissions` | `submission.create` | **Oui** (`Idempotency-Key`) |
| POST | `/submissions/:id/cancel` | `submission.cancel_own` | Non |
| GET | `/teacher/submissions` | `submission.read_assigned` | — |
| POST | `/submissions/:id/feedback` | `feedback.create` + `feedback.publish` | Non |
| GET | `/learners/me/feedbacks` | `feedback.read_own` | — |
| GET | `/submissions/:id/access` | `media.access` | — |
| GET | `/feedbacks/:id/access` | `media.access` | — |
| POST | `/admin/guardianships` | `guardianship.manage` | Non |
| DELETE | `/admin/guardianships/:id` | `guardianship.manage` | Non |
| GET | `/guardian/minors` | `guardian.read_minor_progress` | — |
| GET | `/guardian/minors/:minorId/progress` | `guardian.read_minor_progress` | — |
| GET | `/guardian/minors/:minorId/feedbacks` | `guardian.read_minor_progress` | — |
| GET/PATCH | `/admin/users` | `admin.user.manage` | Non |
| GET/PATCH | `/admin/settings` | `admin.settings.manage` | Non |
| GET | `/admin/audit-log` | `admin.audit.read` | — |
| GET | `/admin/reports/kpis` | `admin.reports.read` | — |

Toute permission listée ici mais absente de `07_SECURITE_ET_AUTORISATION.md` §2 (ou inversement) est une erreur à signaler dans `07_TRACKING/BLOCKERS.md` avant de coder l'endpoint concerné.

## 6. Exigence pour la génération frontend

Les noms de routes ci-dessus sont figés. Toute modification passe par une mise à jour de ce document **avant** le développement du frontend correspondant — jamais l'inverse.

## 7. Ce que ce document ferme

| Point de l'analyse critique | Fermé par |
|---|---|
| C-05 — incohérence `PENDING` entre architecture et traçabilité | §2 |
| C-16 — API en exemples, pas en contrat stable | §1, §3, §4, §5 |
