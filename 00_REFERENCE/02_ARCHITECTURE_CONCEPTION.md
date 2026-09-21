# 02 — Architecture & Conception — APONGA LMS

**Statut : conception fermée. Vue d'ensemble normative.** Le détail technique de chaque sujet sensible (versionnement, média, sécurité, API, notifications) vit dans un document dédié, référencé ici, pour qu'il n'existe qu'un seul endroit où chaque règle est écrite.

---

## 1. Vision et relation avec APONGA

APONGA Academy est une plateforme d'apprentissage en ligne de la batterie et des percussions, avec un feedback humain personnalisé. Le LMS est un système **indépendant**, intégré au site vitrine `www.aponga.com`, sans intégration fonctionnelle avec l'école physique ni la Drumline.

**Identité utilisateur** : le LMS gère lui-même ses comptes (module Identity interne), avec une frontière claire permettant de brancher un fournisseur d'identité APONGA partagé plus tard, si nécessaire.

## 2. Utilisateurs et rôles

### 2.1 Les six rôles

| Rôle | Objectif principal | Restrictions |
|---|---|---|
| **Learner** | Apprendre | N'accède qu'à ses propres données |
| **Teacher** | Corriger et guider | Accès limité aux cours avec assignation active |
| **Content Author** | Créer le contenu | Brouillon uniquement, ne publie pas |
| **Academy Manager** | Piloter l'Académie | Pas d'accès à la configuration technique globale |
| **Administrator** | Maintenir le système | — |
| **Guardian** | Superviser un mineur | Lecture seule, aucune écriture |

**Multi-rôles** : un compte peut cumuler plusieurs rôles (`user_roles`, many-to-many).

### 2.2 Permissions

L'autorisation est exprimée par **permissions granulaires**, pas seulement par rôle (ex. `course.publish`, `submission.read_assigned`, `course_teacher.manage`, `guardian.read_minor_progress`). La liste complète des permissions et les règles de périmètre objet (ex. « un Teacher ne voit que les Submissions des cours où il a une assignation active ») sont définies dans `07_SECURITE_ET_AUTORISATION.md`.

**Principe d'implémentation** : vérification systématique à deux niveaux — contrôleur API **et** couche service.

### 2.3 Assignation Enseignant ↔ Cours

Relation many-to-many (`course_teachers`). Seuls Academy Manager et Administrator peuvent créer ou désactiver une assignation. Un cours ne peut être publié sans au moins un enseignant activement assigné. Détail des états et de l'historisation en `04_MACHINES_ETATS_ET_REGLES_METIER.md` §5.

### 2.4 Guardian et apprenant mineur

Un Learner de moins de 15 ans doit avoir au moins un Guardian actif lié avant de s'inscrire à un cours ou de soumettre une pratique. Règles complètes (âge minimal du Guardian, création du lien, consentement, révocation) en `04_MACHINES_ETATS_ET_REGLES_METIER.md` §4.

## 3. Cartographie des modules

```text
LMS APONGA
│
├── Identity & Access          (géré en interne au LMS)
├── Learning Design            (Course → Module → Lesson → Resource)
├── Content & Media            (upload, stockage, streaming sécurisé — voir 06)
├── Enrollment                 (inscription et accès — SANS facturation en V1)
├── Learning Delivery          (expérience de consommation du contenu)
├── Assessment                 (soumissions, feedback — différenciateur produit)
├── Progression                (avancement, reprise)
├── Communication              (notifications — voir 09)
├── Reporting                  (tableaux de bord, statistiques basiques)
├── Administration             (utilisateurs, configuration, audit)
└── Localization                (langues FR/EN, fuseaux horaires)
```

**Différés en V2** : Billing (paiement), Recognition (badges, certificats).

**Architecture interne : monolithe modulaire.** Frontières de module strictes, pas de microservices — décision définitive.

## 4. Écrans et parcours

### 4.1 Arborescence

```text
APONGA ACADEMY
├── Public : Accueil, Catalogue, Détail d'un cours, Connexion/Inscription
├── Learner : Dashboard, Mes formations, Lecteur de cours,
│             Soumission de pratique, Historique des feedbacks, Mon Compte
├── Teacher : Dashboard de correction, Liste des soumissions assignées,
│             Interface de feedback (côte-à-côte)
├── Guardian : Suivi du mineur (lecture seule)
├── Content Author / Manager : Éditeur de formation, Bibliothèque média,
│                               Gestion des assignations Teacher↔Course
└── Administration : Utilisateurs & Rôles, Catalogue, Rapports,
                      Configuration système, Journal d'audit
```

### 4.2 Parcours Learner (V1 — sans paiement)

Découverte → Inscription/Connexion → Catalogue → **Inscription directe (accès immédiat)** → Suivi des leçons → Soumission de pratique → Réception de feedback → Progression.

### 4.3 Parcours Teacher

Connexion → Dashboard (soumissions en attente sur cours assignés) → Ouverture d'une soumission → Feedback (côte-à-côte, Niveau 2) → Validation → Suivi des apprenants.

### 4.4 Parcours Content Author / Academy Manager

Brouillon → structuration → upload des médias → soumission pour revue → validation → **assignation d'au moins un enseignant** → publication (voir `05_VERSIONNEMENT_PEDAGOGIQUE.md` pour ce que « publier » signifie réellement).

### 4.5 Parcours Guardian

Connexion → sélection du mineur lié → consultation de sa progression et de ses feedbacks (lecture seule).

## 5. Principe transverse — non-rétroactivité des fermetures

**Fermer un accès n'annule jamais un accès déjà accordé.** Ce principe unique est appliqué de façon identique à plusieurs endroits du système :

| Action de fermeture | Effet |
|---|---|
| Fermer les inscriptions d'un cours (`enrollment_open = false`) | Bloque les nouvelles inscriptions ; les inscrits existants gardent leur accès |
| Désactiver une assignation Teacher↔Course | Bloque les nouvelles actions de ce Teacher sur ce cours ; n'affecte pas les feedbacks déjà publiés |
| Désactiver un lien Guardian | Bloque les nouvelles inscriptions/soumissions du mineur si c'était son seul Guardian actif ; n'annule pas les accès déjà en cours |
| Remettre un Course publié en édition | Retire le cours du catalogue et bloque les nouvelles inscriptions ; les apprenants déjà inscrits continuent sur la version qu'ils ont pinée (voir `05_VERSIONNEMENT_PEDAGOGIQUE.md`) |

Ce principe n'est pas réexpliqué ailleurs dans le dossier : il est simplement appliqué.

## 6. Comment le module Billing s'intégrera en V2, sans réécriture

- Le flux d'Enrollment crée aujourd'hui directement un Enrollment `ACTIVE`. En V2, un état `PENDING_PAYMENT` sera inséré avant `ACTIVE`, activé par un webhook — les états en aval ne changent pas.
- `courses.price_amount` / `price_currency` existent déjà (nullable, inutilisés en V1).
- `enrollments.payer_user_id` existe déjà, prêt pour le cas où un Guardian paie pour un mineur.
- L'intégration des moyens de paiement se fera via des adaptateurs, sans toucher au cœur métier — même principe que Media et Localization.

## 7. Stack technique — définitive

| Couche | Choix |
|---|---|
| Frontend | Next.js, PWA-first |
| Backend | NestJS, monolithe modulaire |
| Base de données | PostgreSQL |
| Stockage objet | Cloudflare R2 |
| Streaming vidéo / CDN | Cloudflare Stream |
| Cache / sessions, files de jobs | Redis (+ BullMQ pour les jobs asynchrones — voir `09_NOTIFICATIONS_ET_JOBS.md`) |

## 8. Internationalisation et contraintes terrain

- Langues au lancement : Français et Anglais. Contenu pédagogique en JSONB par langue.
- Devise : `price_currency` réservé pour V2.
- Fuseaux horaires : stockage UTC, conversion côté client. `birth_date` reste une date civile sans fuseau (voir `03_MODELE_DE_DONNEES.md`).
- Mode hors-ligne : cache PWA du shell, des métadonnées et des PDF déjà ouverts — **jamais** la vidéo (URLs signées à courte durée, incompatibles avec un cache permanent). Choix fermé, pas une limitation technique non résolue.
- Mode économie de données : masque la vidéo, priorise audio + PDF.

## 9. Ce que ce document ne couvre pas — voir ailleurs

| Sujet | Document |
|---|---|
| Schéma de données complet | `03_MODELE_DE_DONNEES.md` |
| États et règles de cycle de vie détaillés | `04_MACHINES_ETATS_ET_REGLES_METIER.md` |
| Ce que signifie « publier un cours » | `05_VERSIONNEMENT_PEDAGOGIQUE.md` |
| Cycle de vie des fichiers média | `06_MEDIA_LIFECYCLE.md` |
| Authentification, permissions détaillées, sécurité | `07_SECURITE_ET_AUTORISATION.md` |
| Endpoints, conventions, erreurs | `08_CONTRAT_API.md` |
| Événements et traitement asynchrone | `09_NOTIFICATIONS_ET_JOBS.md` |
| Tests | `10_STRATEGIE_DE_TEST.md` |
| Déploiement et exploitation | `11_DEPLOIEMENT_ET_EXPLOITATION.md` |
