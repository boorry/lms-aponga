# 04 — Machines d'états et règles métier — APONGA LMS

**Statut : normatif.** Chaque état listé ici est le seul vocabulaire autorisé, y compris dans le code, les routes API et les tests. Aucun état non listé (par exemple `PENDING`) ne doit apparaître nulle part dans le système.

---

## 1. Course

```text
DRAFT → IN_REVIEW → PUBLISHED → ARCHIVED
```

- Ces états s'appliquent à la ligne `courses`, qui représente **toujours le brouillon de travail courant** — jamais la version historique servie aux inscrits (voir `05_VERSIONNEMENT_PEDAGOGIQUE.md` pour le détail complet de cette distinction, centrale au système).
- Passage à `PUBLISHED` : crée un `course_versions` (append-only), met à jour `courses.published_version_id` et incrémente `current_version_number`. Transaction obligatoire (publication + snapshot atomiques).
- Un cours `PUBLISHED` peut repasser en édition (retour effectif à un statut de travail) : il est alors retiré du catalogue public et fermé aux nouvelles inscriptions, **sans effet sur les inscrits existants**, qui continuent de consulter la version qu'ils ont pinée à l'inscription.
- `ARCHIVED` : cours définitivement retiré du catalogue. Les inscrits existants gardent l'accès à leur version pinée, sauf décision explicite contraire de l'Administration (non automatisée en V1).

## 2. Submission

```text
SUBMITTED → IN_REVIEW → FEEDBACK_GIVEN
SUBMITTED → CANCELLED
```

Règles fermées (C-04, C-21) :

- **Cardinalité** : une seule Submission « active » (statut `SUBMITTED` ou `IN_REVIEW`) à la fois par couple (Learner, Lesson) — contrainte DB, voir `03_MODELE_DE_DONNEES.md`.
- **Annulation** : possible uniquement tant que le statut est `SUBMITTED` (avant qu'un Teacher ne l'ouvre). Dès `IN_REVIEW`, l'apprenant ne peut plus annuler — évite un conflit avec une correction en cours.
- **Resoumission** : autorisée après `FEEDBACK_GIVEN`. Elle crée une **nouvelle** ligne `submissions` (l'historique n'est jamais écrasé). La contrainte d'unicité ne bloque que les soumissions actives, pas l'historique.
- **Pièces média** : une seule par Submission en V1 (`media_id`). Plusieurs pièces = évolution V2 sans migration de schéma nécessaire (la table `media_assets` le permettrait déjà).
- **Teacher désassigné en cours de traitement** : la Submission reste visible pour l'Academy Manager (accès non restreint par assignation) ; aucune réassignation automatique en V1 — c'est une action manuelle du Manager.
- **SLA** : pas de règle bloquante en V1. Un indicateur d'urgence est calculé pour l'affichage (`now() - submitted_at > 48h`), sans escalade automatique au-delà de l'alerte de charge déjà définie (voir `02_ARCHITECTURE_CONCEPTION.md` et `13_BACKLOG_V1.md`).

## 3. Enrollment

```text
ACTIVE → COMPLETED
ACTIVE → CANCELLED
```

Règles fermées (C-10, C-11, C-12) :

- **Création** : toujours à l'état `ACTIVE`, avec un `course_version_id` figé sur la version `PUBLISHED` au moment de l'inscription (C-10). Cette version ne change plus jamais pour cet Enrollment.
- **Unicité** : un seul Enrollment `ACTIVE` par (Learner, Course) — contrainte DB.
- **Réinscription après `CANCELLED`** : crée un **nouvel** Enrollment (jamais de réactivation de l'ancien), pinné sur la version publiée au moment de la réinscription. L'historique pédagogique de chaque tentative reste ainsi distinct et lisible.
- **Fermeture des inscriptions** (`courses.enrollment_open = false`) : n'affecte jamais un Enrollment existant (principe de non-rétroactivité, voir `02_ARCHITECTURE_CONCEPTION.md` §5).
- **Passage à `COMPLETED`** : calculé automatiquement lorsque toutes les Lessons avec `is_required = true` de la `course_version_id` pinée ont une `progress.status = COMPLETED`. Le recalcul est déclenché à chaque fois qu'une Progress atteint `COMPLETED`. Une leçon ajoutée dans une version ultérieure n'a aucun effet, puisque l'Enrollment reste pinné sur sa propre version.

## 4. Guardianship

```text
(création) → is_active = true → (désactivation) → is_active = false
```

Règles fermées (C-06) :

- **Âge minimal du Guardian** : 18 ans, vérifié contre `birth_date` au moment de la création du lien.
- **Distinction obligatoire** : un utilisateur ne peut pas être son propre Guardian — contrainte DB (`guardian_user_id <> minor_user_id`).
- **Rôle** : le compte Guardian doit porter le rôle `guardian` (vérifié en policy applicative à la création).
- **Multi-rôles** : un même compte peut cumuler `guardian` et un autre rôle (ex. `learner` pour son propre apprentissage) — aucune restriction technique.
- **Qui crée le lien** : uniquement Academy Manager ou Administrator (même schéma d'autorité que pour `course_teachers`).
- **Consentement (V1, choix assumé)** : `consent_given_at` est renseigné au moment de la création du lien par le Manager/Admin, sur la base d'un consentement obtenu par ailleurs (processus d'inscription physique ou déclaratif). **Il n'y a pas de parcours d'acceptation en ligne par le Guardian en V1** — c'est une simplification volontaire (voir `01_ANALYSE_CRITIQUE_ET_SUIVI.md` §4), pas un oubli. Un parcours d'acceptation par email pourra être ajouté en V2 sans changer le schéma.
- **Révocation** : `is_active = false`, `deactivated_at`, `deactivated_by` renseignés. Si c'était le seul Guardian actif du mineur, celui-ci ne peut plus s'inscrire à un nouveau cours ni soumettre une nouvelle pratique (INV-08), mais garde l'accès à ce qui était déjà actif (non-rétroactivité).
- **Historique** : jamais de suppression physique d'une ligne `guardianships`.

## 5. Feedback

```text
DRAFT → PUBLISHED
```

Règles fermées (C-13) :

- Un Teacher peut enregistrer une réponse (`DRAFT`, non visible du Learner) avant de la valider (`PUBLISHED`, déclenche la notification et devient visible).
- Un seul Feedback `PUBLISHED` par Submission — contrainte DB.
- Un Feedback `PUBLISHED` est **immuable**. Pas d'édition en V1 (choix assumé, voir `01_ANALYSE_CRITIQUE_ET_SUIVI.md` §4).

## 6. Progress

```text
NOT_STARTED → IN_PROGRESS → COMPLETED
NOT_STARTED → COMPLETED   (autorisé directement pour une leçon marquée « terminée » sans suivi intermédiaire)
```

## 7. Course_teachers (assignation)

```text
(création) → is_active = true → (désactivation) → is_active = false
```

Règles fermées (C-09) :
- Unicité de l'assignation active par (Course, Teacher) — contrainte DB.
- Désactivation via `deactivated_at`/`deactivated_by`, jamais de suppression physique — historique complet conservé.
- Réactivation : crée une nouvelle ligne active (ne réutilise pas l'ancienne), pour garder une trace fidèle de chaque période d'assignation.

## 8. Media asset

Détail complet en `06_MEDIA_LIFECYCLE.md`.
```text
INITIATED → UPLOADING → READY
INITIATED → UPLOADING → FAILED
READY → DELETED
```

## 9. Classification des règles relationnelles (C-08)

Chaque règle mentionnée par l'analyse critique comme « laissée à la couche applicative » est classée ici explicitement, pour qu'un développeur sache où l'implémenter :

| Règle | Classification | Où l'implémenter |
|---|---|---|
| `course_teachers.user_id` doit avoir le rôle Teacher | Policy applicative (validation transactionnelle) | Service Course_teachers, à la création |
| `course_teachers.assigned_by` doit être Manager/Admin | Policy d'autorisation | Middleware de permission (`course_teacher.manage`) |
| `guardianships.guardian_user_id` doit avoir le rôle Guardian | Policy applicative | Service Guardianship, à la création |
| `guardianships.minor_user_id` doit être Learner | Policy applicative | Service Guardianship, à la création |
| `guardianships.guardian_user_id ≠ minor_user_id` | **Contrainte DB** (CHECK) | Migration de schéma |
| `progress.lesson_id` doit appartenir à la `course_version_id` de l'Enrollment | **Contrainte DB** (via colonne dénormalisée `progress.course_version_id` + validation applicative à l'écriture) | Service Progress, à la création/mise à jour |
| `submissions.lesson_id` doit appartenir à un cours auquel le Learner est inscrit (`course_version_id` cohérent) | Invariant de domaine, vérifié en transaction applicative | Service Submission, à la création |
| `feedback.teacher_id` doit avoir une assignation active **au moment de l'action** | Policy d'autorisation, vérifiée uniquement à la création (un Feedback déjà `PUBLISHED` reste valide même si l'assignation est ensuite désactivée) | Service Feedback, à la création |

## 10. Transactions obligatoires

Les opérations suivantes doivent être exécutées dans une transaction unique (tout ou rien) :

- Publication d'un Course + création de `course_versions`.
- Assignation ou désassignation d'un Teacher.
- Création d'un Enrollment.
- Changement d'état d'une Submission.
- Création/publication d'un Feedback.
- Activation/désactivation d'un Guardianship.
- Écriture d'une donnée métier + écriture de l'événement destiné aux notifications (voir `09_NOTIFICATIONS_ET_JOBS.md`).

## 11. Idempotence obligatoire

Les opérations suivantes, susceptibles d'être rejouées par le client (réseau instable, double-clic) doivent être idempotentes (via un `Idempotency-Key`, voir `08_CONTRAT_API.md`) :

- Création d'Enrollment.
- Finalisation d'un upload média (`media_assets` → `READY`).
- Création d'une Submission.
- Publication d'un Course.
