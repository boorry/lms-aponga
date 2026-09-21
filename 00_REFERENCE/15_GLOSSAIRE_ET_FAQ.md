# 15 — Glossaire & FAQ — APONGA LMS

---

## Glossaire

### Rôles
Learner, Teacher, Content Author, Academy Manager, Administrator, Guardian — voir `00_VISION_ET_PERIMETRE.md` §3.

### Entités et tables clés

| Terme | Définition |
|---|---|
| **Course** (`courses`) | Une formation. Représente toujours le **brouillon de travail courant**, jamais la version figée servie aux inscrits. |
| **course_versions** | Historique immuable des publications d'un Course (instantané complet à chaque publication). |
| **course_teachers** | Table d'assignation many-to-many entre Course et Teacher. |
| **Enrollment** | Inscription d'un Learner à un Course, pinée sur une `course_version_id` précise, qui ne change jamais. |
| **Submission** | Preuve de pratique soumise par un Learner, rattachée à une leçon et une version précises. |
| **Feedback** | Réponse d'un Teacher à une Submission. Un seul feedback publié par Submission en V1. |
| **media_assets** | Table technique partagée pour tout fichier (vidéo, audio, PDF), avec sa propre machine d'états. |
| **guardianships** | Lien entre un Guardian et un Learner mineur. |
| **domain_events** | Table technique qui garantit qu'aucun événement métier (notification) n'est perdu. |
| **notification_deliveries** | Suivi des envois de notifications, avec gestion des tentatives. |

### États normatifs

| Entité | États |
|---|---|
| Course | `DRAFT → IN_REVIEW → PUBLISHED`, puis retour explicite en édition |
| Enrollment | `ACTIVE → COMPLETED` / `ACTIVE → CANCELLED` |
| Submission | `SUBMITTED → IN_REVIEW → FEEDBACK_GIVEN` / `SUBMITTED → CANCELLED` |
| Feedback | `DRAFT → PUBLISHED` |
| Progress | `NOT_STARTED → IN_PROGRESS → COMPLETED` |
| Guardianship / course_teachers | actif ↔ désactivé (`is_active`, `deactivated_at/by`) |
| media_assets | `INITIATED → UPLOADING → READY` / `FAILED` / `DELETED` |

**Aucun autre état n'existe. `PENDING` n'est jamais un état valide de Submission — c'était une incohérence de l'ancienne documentation, désormais corrigée partout.**

---

## FAQ

**Un Course publié peut-il être modifié directement ?**
Non. Toute modification se fait sur le brouillon de travail (la ligne `courses` elle-même). Une nouvelle publication crée une nouvelle version figée dans `course_versions`. Voir `05_VERSIONNEMENT_PEDAGOGIQUE.md`.

**Si je modifie un cours déjà publié, les apprenants inscrits voient-ils le changement ?**
Non, jamais. Chaque Enrollment est pinné sur la version publiée au moment de l'inscription et ne bouge plus.

**Un apprenant peut-il soumettre plusieurs fois pour la même leçon ?**
Oui, mais une seule soumission « active » (en attente ou en cours de revue) à la fois. Après un feedback reçu, une nouvelle soumission est possible et crée une nouvelle ligne — l'historique est conservé.

**Peut-on annuler une soumission ?**
Oui, tant qu'un Teacher ne l'a pas encore ouverte (statut `SUBMITTED`). Plus possible une fois `IN_REVIEW`.

**Un feedback peut-il être corrigé après envoi ?**
Non, en V1. Un feedback publié est immuable. C'est un choix assumé pour le lancement, pas un oubli.

**Comment un Guardian est-il lié à un mineur ?**
Uniquement par un Academy Manager ou un Administrator, qui capture le consentement au moment de la création du lien. Il n'y a pas de parcours d'acceptation en ligne par le Guardian en V1.

**Que se passe-t-il si le seul Guardian actif d'un mineur est désactivé ?**
Le mineur ne peut plus s'inscrire à un nouveau cours ni soumettre une nouvelle pratique, mais garde l'accès à ce qui était déjà actif.

**Où sont stockés les fichiers vidéo/audio/PDF ?**
Tous transitent par une table technique unique, `media_assets`, mais avec des politiques différentes selon qu'il s'agit d'un contenu pédagogique (permanent, versionné) ou d'un upload personnel (Submission/Feedback, à rétention limitée). Voir `06_MEDIA_LIFECYCLE.md`.

**Comment une notification ne peut-elle jamais se perdre ?**
Elle est d'abord écrite dans une table `domain_events`, dans la **même transaction** que l'action métier. Un worker séparé s'occupe ensuite de l'envoi. Voir `09_NOTIFICATIONS_ET_JOBS.md`.

**Où trouver la liste exacte des routes API ?**
Dans `08_CONTRAT_API.md`, qui fait foi jusqu'à la génération d'un contrat OpenAPI à partir du code.

**Que faire si une question n'est couverte par aucun document ?**
Le dossier est fermé pour tout ce qui est décrit. S'il reste un point réellement absent, il doit être posé explicitement avant tout développement — jamais comblé par une hypothèse silencieuse dans le code.
