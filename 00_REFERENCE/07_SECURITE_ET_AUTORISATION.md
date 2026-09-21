# 07 — Sécurité et autorisation — APONGA LMS

**Statut : normatif, obligatoire avant toute mise en production.** Ferme C-15 et complète C-06/C-08 côté autorisation.

---

## 1. Authentification

| Élément | Décision |
|---|---|
| Access token | JWT, durée de vie courte (15 minutes) |
| Refresh token | Opaque, stocké en base, rotation à chaque utilisation, durée 30 jours, révocable individuellement |
| Transport | Cookie `httpOnly`, `Secure`, `SameSite=Strict` pour le refresh token ; Bearer header pour l'access token |
| Mot de passe | Hash avec un algorithme moderne (Argon2 ou bcrypt), politique de longueur minimale |
| Vérification email | Obligatoire avant première connexion pour un compte auto-inscrit |
| Reset password | Token à usage unique, expiration 30 minutes |
| Rate limiting | Login, reset-password, upload : limité par IP et par compte (ex. 5 tentatives / 15 min), avec verrouillage temporaire au-delà |

## 2. Permissions

Liste normative (référencée depuis `02_ARCHITECTURE_CONCEPTION.md` §2.2, détaillée ici) :

```text
course.create
course.edit
course.review
course.publish
course_teacher.manage
enrollment.create
enrollment.read_own
enrollment.read_all
enrollment.manage_status         -- fermer/rouvrir enrollment_open
progress.read_own
progress.write_own
submission.create
submission.read_own
submission.read_assigned
submission.cancel_own
feedback.create
feedback.publish
feedback.read_own
guardianship.manage
guardian.read_minor_progress
media.upload
media.access
admin.user.manage
admin.settings.manage
admin.audit.read
admin.reports.read
```

*(`progress.read_own`, `progress.write_own`, `feedback.read_own` et `admin.reports.read` ont été ajoutés lors de l'audit final : la liste précédente ne couvrait pas explicitement tous les endpoints du contrat API — voir `08_CONTRAT_API.md` §5 et `FINAL_AUDIT.md`.)*

## 3. Règles d'autorisation objet

L'autorisation par rôle seule ne suffit jamais : chaque permission sensible est vérifiée **dans le périmètre de l'objet concerné**, pas seulement au niveau du rôle.

| Rôle | Périmètre autorisé |
|---|---|
| **Learner** | Ses propres Enrollments, les Lessons des Courses où il a un Enrollment `ACTIVE`, ses propres Submissions, ses propres Feedbacks |
| **Teacher** | Les Courses où `course_teachers.is_active = true` pour lui, les Submissions de ces Courses, création de Feedback sur ces Submissions uniquement |
| **Guardian** | Les Learners liés par `guardianships.is_active = true`, leur Progress, leurs Feedbacks — lecture seule stricte |
| **Content Author** | Ses brouillons (ou tous les brouillons de l'Académie, selon configuration) — jamais la publication |
| **Academy Manager / Administrator** | Selon la matrice complète de `02_ARCHITECTURE_CONCEPTION.md` §2.2 |

**Règle absolue** : la simple présence d'un `user_id` dans une route (`GET /users/{id}/...`) n'est jamais, à elle seule, une preuve d'autorisation. Chaque contrôleur vérifie explicitement que l'utilisateur courant a le droit d'agir sur l'objet demandé, indépendamment de ce que l'URL contient. Vérification systématique à deux niveaux : contrôleur **et** service (défense en profondeur).

## 4. Protection des URLs signées

Un endpoint de génération d'URL signée (`/media/.../access`) applique **la même vérification d'autorisation** que l'accès direct à la ressource protégée (INV-01 pour une Lesson, assignation active pour une Submission, lien Guardian actif pour les données d'un mineur). Une URL signée n'est jamais générée « par défaut » sans ce contrôle.

## 5. Sécurité transverse

| Sujet | Décision |
|---|---|
| CORS | Liste blanche explicite (domaines `aponga.com` et sous-domaines LMS) |
| CSRF | Cookie `SameSite=Strict` sur le refresh token réduit le risque ; en défense supplémentaire, vérification de l'en-tête d'origine sur les endpoints de mutation |
| CSP / en-têtes de sécurité | CSP restrictive, HSTS, `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY` |
| Secrets | Variables d'environnement / gestionnaire de secrets de l'hébergeur, jamais dans le dépôt Git |
| Validation des fichiers uploadés | Type MIME et taille vérifiés côté backend à la complétion de l'upload (voir `06_MEDIA_LIFECYCLE.md`) |
| HTTPS | Obligatoire partout, pas d'exception |
| Journalisation | Jamais de mot de passe ni de token en clair dans les logs |

## 6. Audit

Toute action « Sensible » (voir `13_BACKLOG_V1.md`) est tracée dans `audit_log` : changement de rôle, création/désactivation de `course_teachers`, création/désactivation de `guardianships`, publication d'un cours, modification des `settings`, désactivation d'un compte utilisateur.

## 7. Ce que ce document ferme

| Point de l'analyse critique | Fermé par |
|---|---|
| C-15 — authentification et sécurité insuffisamment spécifiées | §1, §5 |
| C-06 (partie contraintes du rôle Guardian) | Renvoi vers `04_MACHINES_ETATS_ET_REGLES_METIER.md` §4, autorisation objet en §3 ici |
| C-08 (partie policies d'autorisation) | §2, §3 |
