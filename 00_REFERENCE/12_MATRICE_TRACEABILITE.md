# 12 — Matrice de traçabilité — APONGA LMS

**Statut : reflète le schéma et le contrat API définitifs.** Chaîne : `BESOIN → FONCTIONNALITÉ → DONNÉE → API → TÂCHE → TEST`. Les tâches `T-0xx` renvoient à `13_BACKLOG_V1.md`.

---

## 1. Identity & Access

| Besoin | Donnée | API | Tâche | Test |
|---|---|---|---|---|
| Créer un compte, se connecter | `users`, `refresh_tokens` | `POST /auth/register`, `/login`, `/refresh`, `/logout` | T-101, T-102 | Test e2e + rotation/révocation refresh |
| Vérifier son email | `users.email_verified_at`, `email_verification_tokens` | `POST /auth/verify-email` | T-107 | Test du blocage avant vérification + token à usage unique |
| Réinitialiser le mot de passe | `password_reset_tokens` | `POST /auth/forgot-password`, `POST /auth/reset-password` | T-108 | Test expiration + usage unique |
| Restreindre selon le rôle | `roles`, `user_roles` (historisés) | `PATCH /admin/users/:id` | T-103, T-104 | Test de la matrice + révocation effective |
| Déclarer sa date de naissance | `users.birth_date` | `PATCH /users/me` | T-106 | Test NOT NULL + calcul du statut mineur |

## 2. Learning Design, versionnement, assignation

| Besoin | Donnée | API | Tâche | Test |
|---|---|---|---|---|
| Créer/structurer un cours en brouillon | `courses`, `modules`, `lessons` | `POST/PATCH /courses` | T-701, T-702 | Test de structuration |
| Assigner un enseignant | `course_teachers` | `POST /courses/:id/teachers` | T-707 | Test INV-09, unicité active |
| Désassigner un enseignant | `course_teachers.deactivated_at` | `DELETE /courses/:id/teachers/:teacherId` | T-707b | Test d'historisation (C-09) |
| Revoir puis publier un cours | `courses.status`, `course_versions` | `POST /courses/:id/submit-review`, `POST /courses/:id/publish` | T-703, T-708 | Test transitions + INV-02 + snapshot atomique |
| Consulter l'historique des versions | `course_versions` | `GET /courses/:id/versions` | T-709 | Test d'immuabilité (append-only) |
| Fermer/rouvrir les inscriptions | `courses.enrollment_open` | `PATCH /courses/:id/enrollment-status` | T-403 | Test de non-rétroactivité |

## 3. Learning Delivery

| Besoin | Donnée | API | Tâche | Test |
|---|---|---|---|---|
| Lire une vidéo de leçon | `resources`, `media_assets` | `GET /lessons/:id/resources/:resourceId/access` | T-301, T-302 | Test d'expiration d'URL (1h) |
| Consulter un PDF | `resources`, `media_assets` | idem | T-304 | Test d'expiration d'URL (15–30 min) |
| Marquer une leçon terminée | `progress` | `POST /lessons/:id/progress` | T-306 | Test de cohérence `course_version_id` |
| Voir sa progression | `progress`, `enrollments` | `GET /enrollments/:id/progress` | T-307 | Test de calcul `COMPLETED` (is_required) |
| Dashboard détaillé | `progress`, `feedbacks` | `GET /learners/me/dashboard` | T-601 | Test cours actifs + temps passé + derniers feedbacks |

## 4. Enrollment

| Besoin | Donnée | API | Tâche | Test |
|---|---|---|---|---|
| S'inscrire directement | `enrollments` | `POST /courses/:id/enrollment` | T-401 | Test idempotence, unicité ACTIVE |
| Réinscription après annulation | `enrollments` (nouvelle ligne) | `POST /courses/:id/enrollment` | T-401b | Test de non-réactivation de l'ancien Enrollment |
| Inscription manuelle par Manager | `enrollments` | `POST /admin/enrollments` | T-402 | Test de permission |
| Consulter les Enrollments de l'Académie | `enrollments` | `GET /admin/enrollments` | T-402 | Test `enrollment.read_all` + périmètre Manager/Admin |

## 5. Assessment & Feedback

| Besoin | Donnée | API | Tâche | Test |
|---|---|---|---|---|
| Uploader un média | `media_assets` | `POST /media/upload-url`, `POST /media/:id/complete` | T-301b | Test du cycle INITIATED→READY/FAILED |
| Soumettre une pratique | `submissions`, `enrollments` | `POST /submissions` | T-501 | Test unicité active + rattachement Enrollment/version |
| Vérifier l'éligibilité (Guardian si mineur) | `users.birth_date`, `guardianships` | interne à `POST /submissions` | T-503 | Test INV-08 |
| Annuler une soumission | `submissions.status` | `POST /submissions/:id/cancel` | T-509 | Test : refusé si `IN_REVIEW` |
| Consulter ses soumissions | `submissions` | `GET /submissions/me` | T-501 | Test périmètre Learner |
| File d'attente / prise en charge | `submissions`, `course_teachers` | `GET /teacher/submissions`, `POST /teacher/submissions/:id/start-review` | T-504 | Test filtrage + INV-07 + transition explicite |
| Répondre puis publier | `feedbacks` | `POST /submissions/:id/feedback`, `POST /feedbacks/:id/publish` | T-505, T-506 | Test DRAFT→PUBLISHED + cardinalité |
| Historique des feedbacks | `feedbacks` | `GET /learners/me/feedbacks` | T-507 | Test de tri |
| Alerte de surcharge enseignant | `settings`, `domain_events` | job planifié | T-508 | Test de déclenchement au seuil |

## 6. Guardian

| Besoin | Donnée | API | Tâche | Test |
|---|---|---|---|---|
| Lier un Guardian à un mineur | `guardianships` | `POST /admin/guardianships` | T-901 | Test âge ≥18, distinction, unicité |
| Révoquer le lien | `guardianships.deactivated_at` | `DELETE /admin/guardianships/:id` | T-901b | Test de non-rétroactivité |
| Consulter la progression du mineur | `progress`, `feedbacks` | `GET /guardian/minors/:id/progress` | T-902 | Test lecture seule stricte |

## 7. Administration

| Besoin | Donnée | API | Tâche | Test |
|---|---|---|---|---|
| Gérer les utilisateurs | `users`, `user_roles` | `GET /admin/users`, `PATCH /admin/users/:id` | T-701b | Test gestion rôles/statut + audit |
| Configurer les paramètres | `settings` | `GET/PATCH /admin/settings` | T-706 | Test de persistance |
| Consulter le journal d'audit | `audit_log` | `GET /admin/audit-log` | T-710 | Test de traçabilité des actions sensibles |
| KPIs de base | vues agrégées | `GET /admin/reports/kpis` | T-705 | Test de cohérence des chiffres |

## 8. Communication

| Besoin | Donnée | API | Tâche | Test |
|---|---|---|---|---|
| Notifications transactionnelles | `domain_events`, `notification_deliveries` | Event-driven | T-801 | Test outbox : événement jamais perdu (C-20) |

## 9. Écarts explicites avec le périmètre V1

| Élément | Statut |
|---|---|
| Paiement, certificats, badges | Hors V1, voir `00_VISION_ET_PERIMETRE.md` |
| Édition d'un Feedback publié, plusieurs pièces média par Submission, migration automatique de version | Hors V1 par choix assumé, voir `01_ANALYSE_CRITIQUE_ET_SUIVI.md` §4 |
