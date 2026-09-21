# 08 — Contrat API — APONGA LMS

**Statut : normatif.** Ce contrat est figé avant le développement. Les DTO/OpenAPI générés à partir du code doivent rester conformes à ce document ; ils deviennent la source de vérité vivante après génération, sans pouvoir contredire les décisions métier.

## 1. Conventions générales

| Sujet | Convention |
|---|---|
| Base path | `/api/v1` |
| Authentification | Bearer access token ; refresh token opaque en cookie `httpOnly` |
| Pagination | `?page=1&pageSize=20` (défaut 20, max 100) ; `{ data, meta }` |
| Tri | `?sort=field` ou `?sort=-field` |
| Filtres | `?filter[field]=value` |
| Idempotence | `Idempotency-Key` obligatoire sur Enrollment, media complete, Submission et publication de Course |
| Erreur de clé réutilisée avec payload différent | HTTP 409 |
| Versioning | `/api/v1` |

## 2. États autorisés

Les états sont exclusivement ceux de `04_MACHINES_ETATS_ET_REGLES_METIER.md`. `PENDING` n'est jamais un statut de Submission.

## 3. Format d'erreur

```json
{
  "code": "COURSE_NOT_PUBLISHED",
  "message": "Course is not published",
  "details": {},
  "requestId": "..."
}
```

| Code | Usage |
|---|---|
| 400 | Payload invalide |
| 401 | Non authentifié |
| 403 | Permission insuffisante ou hors périmètre |
| 404 | Ressource inexistante ou non visible |
| 409 | Conflit métier ou clé d'idempotence incompatible |
| 422 | Règle métier non satisfaite |
| 429 | Limite de fréquence |
| 500 | Erreur inattendue |

## 4. Endpoints

### Identity
```text
POST /auth/register
POST /auth/login
POST /auth/refresh
POST /auth/logout
POST /auth/verify-email
POST /auth/forgot-password
POST /auth/reset-password
GET  /users/me
PATCH /users/me
```

`POST /auth/register` attribue uniquement le rôle `learner`. Les autres rôles sont attribués par un Administrator ; le Manager peut gérer les rôles non-administrator selon la matrice de sécurité. Le premier Administrator est créé par le seed de développement.

### Catalogue
```text
GET /courses
GET /courses/:id
GET /courses/:id/versions
```

### Learning Design & assignation
```text
POST   /courses
PATCH  /courses/:id
POST   /courses/:id/submit-review
POST   /courses/:id/publish
POST   /courses/:id/return-to-edit
POST   /courses/:id/teachers
DELETE /courses/:id/teachers/:teacherId
PATCH  /courses/:id/enrollment-status
```

`POST /courses/:id/submit-review` effectue uniquement `DRAFT → IN_REVIEW` et exige `course.review`. `POST /courses/:id/return-to-edit` effectue uniquement `PUBLISHED → IN_REVIEW` et retire immédiatement le cours du catalogue. `PATCH /courses/:id` ne peut jamais modifier directement `status`, `published_version_id` ou `current_version_number`.

### Enrollment
```text
POST /courses/:id/enrollment
GET  /enrollments/me
GET  /admin/enrollments
POST /admin/enrollments
```

### Learning Delivery / Progress
```text
GET  /courses/:id/lessons/:lessonId
POST /lessons/:lessonId/progress
GET  /enrollments/:id/progress
GET  /learners/me/dashboard
GET  /lessons/:lessonId/resources/:resourceId/access
```

Le payload de progression peut mettre à jour `status` et `time_spent_seconds`. La durée cumulée ne peut pas diminuer.

### Submission / Feedback / Media
```text
POST /media/upload-url
POST /media/:id/complete

POST /submissions
GET  /submissions/me
POST /submissions/:id/cancel
GET  /teacher/submissions
POST /teacher/submissions/:id/start-review

POST /submissions/:id/feedback
POST /feedbacks/:id/publish
GET  /learners/me/feedbacks

GET  /submissions/:id/access
GET  /feedbacks/:id/access
```

`POST /submissions/:id/feedback` crée ou modifie uniquement un Feedback `DRAFT`. `POST /feedbacks/:id/publish` effectue `DRAFT → PUBLISHED`, rend le feedback visible et produit l'événement de notification.

`POST /teacher/submissions/:id/start-review` effectue `SUBMITTED → IN_REVIEW`. Une simple lecture ne change jamais l'état d'une Submission.

### Guardian
```text
POST   /admin/guardianships
DELETE /admin/guardianships/:id
GET    /guardian/minors
GET    /guardian/minors/:minorId/progress
GET    /guardian/minors/:minorId/feedbacks
```

### Administration
```text
GET   /admin/users
PATCH /admin/users/:id
GET   /admin/settings
PATCH /admin/settings
GET   /admin/audit-log
GET   /admin/reports/kpis
```

## 5. Permission et idempotence par endpoint

| Méthode | Endpoint | Permission | Idempotent |
|---|---|---|---|
| POST | `/auth/register` | Public | Non |
| POST | `/auth/login` | Public | Non |
| POST | `/auth/refresh` | Self | Non |
| POST | `/auth/logout` | Self | Non |
| POST | `/auth/verify-email` | Public, token | Non |
| POST | `/auth/forgot-password` | Public | Non |
| POST | `/auth/reset-password` | Public, token | Non |
| GET | `/users/me` | Self | — |
| PATCH | `/users/me` | Self | Non |
| GET | `/courses` | Public | — |
| GET | `/courses/:id` | Public | — |
| GET | `/courses/:id/versions` | `course.edit` | — |
| POST | `/courses` | `course.create` | Non |
| PATCH | `/courses/:id` | `course.edit` | Non |
| POST | `/courses/:id/submit-review` | `course.review` | Non |
| POST | `/courses/:id/publish` | `course.publish` | Oui |
| POST | `/courses/:id/return-to-edit` | `course.edit` | Non |
| POST | `/courses/:id/teachers` | `course_teacher.manage` | Non |
| DELETE | `/courses/:id/teachers/:teacherId` | `course_teacher.manage` | Non |
| PATCH | `/courses/:id/enrollment-status` | `enrollment.manage_status` | Non |
| POST | `/courses/:id/enrollment` | `enrollment.create` | Oui |
| GET | `/enrollments/me` | `enrollment.read_own` | — |
| GET | `/admin/enrollments` | `enrollment.read_all` | — |
| POST | `/admin/enrollments` | `enrollment.create` + admin scope | Oui |
| GET | `/courses/:id/lessons/:lessonId` | `enrollment.read_own` | — |
| POST | `/lessons/:lessonId/progress` | `progress.write_own` | Non |
| GET | `/enrollments/:id/progress` | `progress.read_own` | — |
| GET | `/learners/me/dashboard` | `progress.read_own` + `feedback.read_own` | — |
| GET | `/lessons/:lessonId/resources/:resourceId/access` | `media.access` | — |
| POST | `/media/upload-url` | `media.upload` | Non |
| POST | `/media/:id/complete` | `media.upload` | Oui |
| POST | `/submissions` | `submission.create` | Oui |
| GET | `/submissions/me` | `submission.read_own` | — |
| POST | `/submissions/:id/cancel` | `submission.cancel_own` | Non |
| GET | `/teacher/submissions` | `submission.read_assigned` | — |
| POST | `/teacher/submissions/:id/start-review` | `submission.review` | Non |
| POST | `/submissions/:id/feedback` | `feedback.create` | Non |
| POST | `/feedbacks/:id/publish` | `feedback.publish` | Non |
| GET | `/learners/me/feedbacks` | `feedback.read_own` | — |
| GET | `/submissions/:id/access` | `media.access` | — |
| GET | `/feedbacks/:id/access` | `media.access` | — |
| POST | `/admin/guardianships` | `guardianship.manage` | Non |
| DELETE | `/admin/guardianships/:id` | `guardianship.manage` | Non |
| GET | `/guardian/minors` | `guardian.read_minor_progress` | — |
| GET | `/guardian/minors/:minorId/progress` | `guardian.read_minor_progress` | — |
| GET | `/guardian/minors/:minorId/feedbacks` | `guardian.read_minor_progress` | — |
| GET | `/admin/users` | `admin.user.manage` | — |
| PATCH | `/admin/users/:id` | `admin.user.manage` | Non |
| GET | `/admin/settings` | `admin.settings.manage` | — |
| PATCH | `/admin/settings` | `admin.settings.manage` | Non |
| GET | `/admin/audit-log` | `admin.audit.read` | — |
| GET | `/admin/reports/kpis` | `admin.reports.read` | — |

## 6. Idempotence

Pour chaque endpoint marqué idempotent :

1. la clé est obligatoire ;
2. la clé est associée à l'utilisateur, l'endpoint et un hash du payload ;
3. une répétition avec le même hash rejoue la réponse initiale ;
4. une même clé avec un hash différent retourne `409` ;
5. la persistance de la clé survit au redémarrage du backend ;
6. l'opération métier et l'enregistrement nécessaire à son idempotence sont protégés par transaction lorsque le domaine le permet.

## 7. Exigence frontend

Les écrans consomment uniquement les routes de ce contrat. Toute modification de route, permission ou statut doit précéder l'implémentation frontend et passer par `05_CHANGE_CONTROL.md`.

## 8. Source OpenAPI

Les DTO NestJS et `@nestjs/swagger` généreront la documentation OpenAPI. Une divergence entre OpenAPI générée et ce contrat est un blocker de validation, pas une invitation à modifier silencieusement le contrat.
