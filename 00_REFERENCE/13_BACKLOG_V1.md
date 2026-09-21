# 13 — Backlog de développement — V1 — APONGA LMS

**Statut : périmètre V1 techniquement fermé.** La colonne **Sensibilité** (Standard/Sensible) indique le niveau d'attention requis, indépendamment de qui développe la tâche.

---

## EPIC 1 — Identity & Access

| ID | Tâche | Prio | Dépendances | Sensibilité | Critère d'acceptation |
|---|---|---|---|---|---|
| T-101 | S'inscrire avec mon email | P0 | — | Sensible | Compte créé, mot de passe hashé (Argon2/bcrypt) |
| T-102 | Se connecter (access + refresh token) | P0 | T-101 | Sensible | Token courte durée + refresh rotatif, conforme à `07_SECURITE_ET_AUTORISATION.md` |
| T-103 | Attribuer un rôle à un utilisateur | P0 | T-101 | Sensible | 6 rôles disponibles |
| T-104 | Vérifier les permissions à chaque action sensible | P0 | T-103 | Sensible | Contrôle contrôleur ET service |
| T-105 | Gérer mon profil | P1 | T-102 | Standard | Édition + changement de mot de passe |
| T-106 | Déclarer sa date de naissance à l'inscription | P0 | T-101 | Sensible | Champ NOT NULL pour Learner |
| T-107 | Vérification d'email obligatoire avant connexion | P0 | T-101 | Sensible | Blocage effectif avant vérification |
| T-108 | Rate limiting login / reset-password | P0 | T-102 | Sensible | Verrouillage temporaire au-delà du seuil |

## EPIC 2 — Catalogue & Découverte

| ID | Tâche | Prio | Dépendances | Sensibilité | Critère d'acceptation |
|---|---|---|---|---|---|
| T-201 | Voir et filtrer le catalogue | P0 | EPIC 3 | Standard | Ne liste que les cours `PUBLISHED` |
| T-202 | Voir la fiche détaillée d'un cours | P0 | T-201 | Standard | Description, programme, previews |
| T-203 | Rechercher un cours | P2 | T-201 | Standard | Recherche textuelle |

## EPIC 3 — Learning Design, versionnement & assignation

| ID | Tâche | Prio | Dépendances | Sensibilité | Critère d'acceptation |
|---|---|---|---|---|---|
| T-701 | Créer un cours en brouillon | P0 | T-101 | Standard | Statut DRAFT |
| T-702 | Structurer modules/leçons ordonnés, `is_required` | P0 | T-701 | Standard | Ordonnancement fonctionnel |
| T-707 | Assigner un ou plusieurs enseignants | P0 | T-701 | Sensible | INV-09, unicité active (`03_MODELE_DE_DONNEES.md`) |
| T-707b | Désassigner un enseignant | P1 | T-707 | Sensible | `deactivated_at/by` renseignés, historique conservé (C-09) |
| T-703 | Publier un cours (transaction atomique) | P0 | T-702, T-707 | Sensible | Snapshot `course_versions` créé, INV-02 révisé appliqué |
| T-708 | Retour en édition d'un cours publié | P0 | T-703 | Sensible | Retrait du catalogue, aucun effet sur les inscrits existants (`05_VERSIONNEMENT_PEDAGOGIQUE.md`) |
| T-709 | Consulter l'historique des versions | P2 | T-708 | Standard | Liste chronologique, append-only |

## EPIC 4 — Media & Learning Delivery

| ID | Tâche | Prio | Dépendances | Sensibilité | Critère d'acceptation |
|---|---|---|---|---|---|
| T-301 | Générer une URL d'upload présignée (`media_assets` INITIATED) | P0 | T-702 | Sensible | Conforme `06_MEDIA_LIFECYCLE.md` |
| T-301b | Finaliser un upload (`complete`) | P0 | T-301 | Sensible | Vérifications taille/type/existence, passage à READY/FAILED |
| T-302 | Lire une vidéo en streaming sécurisé | P0 | T-301b | Sensible | URL signée 1h (INV-06) |
| T-302b | Qualité/vitesse, boucle A-B | P0 | T-302 | Standard | Contrôles fonctionnels |
| T-304 | Consulter un PDF | P1 | T-301b | Sensible | URL signée 15–30 min |
| T-305 | Mode économie de données | P1 | T-302b | Standard | Désactivation vidéo |
| T-306 | Marquer une leçon terminée | P0 | T-302 | Standard | `progress.course_version_id` cohérent |
| T-307 | Voir sa progression | P0 | T-306 | Standard | Calcul `COMPLETED` sur `is_required` |
| T-310 | Cache PWA (shell, métadonnées, PDF) | P1 | T-201 | Standard | Fonctionne hors-ligne, pas pour la vidéo |
| T-311 | Nettoyage des uploads abandonnés (`INITIATED`/`UPLOADING` > 24h) | P1 | T-301 | Standard | Job périodique, purge côté provider |

## EPIC 5 — Enrollment

| ID | Tâche | Prio | Dépendances | Sensibilité | Critère d'acceptation |
|---|---|---|---|---|---|
| T-401 | S'inscrire directement (idempotent) | P0 | T-703 | Sensible | `course_version_id` pinné, `Idempotency-Key` respecté |
| T-401b | Réinscription après annulation | P1 | T-401 | Sensible | Nouvel Enrollment créé, jamais de réactivation (C-11) |
| T-402 | Inscription manuelle par Manager/Admin | P1 | T-401 | Standard | Même règles que T-401 |
| T-403 | Fermer/rouvrir les inscriptions | P1 | T-401 | Standard | Non-rétroactif |
| T-404 | Invariant d'accès (INV-01) | P0 | T-401 | Sensible | Aucun accès sans Enrollment ACTIVE |

## EPIC 6 — Assessment & Feedback

| ID | Tâche | Prio | Dépendances | Sensibilité | Critère d'acceptation |
|---|---|---|---|---|---|
| T-501 | Soumettre une pratique (idempotent) | P0 | T-301b, EPIC 5 | Sensible | Unicité active par leçon (C-21) |
| T-503 | Vérifier l'éligibilité (Guardian si mineur) | P0 | T-106, T-901 | Sensible | Blocage INV-08 |
| T-504 | File d'attente filtrable (cours assignés) | P0 | T-501, T-707 | Sensible | Filtrage INV-07 |
| T-505 | Enregistrer une réponse (côte-à-côte, Niveau 2) | P0 | T-504 | Standard | Conforme spécification Niveau 2 |
| T-506 | Valider/publier le feedback | P0 | T-505 | Sensible | Cardinalité un feedback publié max (C-13), notification |
| T-507 | Historique des feedbacks | P1 | T-506 | Standard | Liste chronologique |
| T-508 | Alerte de surcharge enseignant | P1 | T-504 | Standard | Déclenchement au seuil configuré |
| T-509 | Annuler une soumission (avant prise en charge) | P1 | T-501 | Standard | Refusé si `IN_REVIEW` |

## EPIC 7 — Progression

| ID | Tâche | Prio | Dépendances | Sensibilité | Critère d'acceptation |
|---|---|---|---|---|---|
| T-601 | Dashboard de progression détaillé | P1 | T-307 | Standard | Cours en cours, temps passé, derniers feedbacks |

## EPIC 8 — Guardian

| ID | Tâche | Prio | Dépendances | Sensibilité | Critère d'acceptation |
|---|---|---|---|---|---|
| T-901 | Lier un Guardian à un mineur | P0 | T-106 | Sensible | Âge ≥18, distinction, unicité, `created_by` tracé |
| T-901b | Révoquer un lien Guardian | P1 | T-901 | Sensible | Non-rétroactif, blocage des futures actions du mineur si dernier lien |
| T-902 | Consultation lecture seule (progression/feedbacks) | P0 | T-901, T-307 | Sensible | Aucune action d'écriture possible |

## EPIC 9 — Administration & Reporting

| ID | Tâche | Prio | Dépendances | Sensibilité | Critère d'acceptation |
|---|---|---|---|---|---|
| T-701b | Gérer les utilisateurs | P1 | T-103 | Sensible | CRUD complet, historisé |
| T-705 | KPIs de base | P1 | EPIC 4, 7 | Standard | Dashboard cohérent |
| T-706 | Configurer les paramètres système | P1 | — | Sensible | `settings` éditable |
| T-710 | Journal d'audit | P1 | — | Sensible | Actions sensibles tracées (voir `07_SECURITE_ET_AUTORISATION.md` §6) |

## EPIC 10 — Notifications & jobs

| ID | Tâche | Prio | Dépendances | Sensibilité | Critère d'acceptation |
|---|---|---|---|---|---|
| T-801 | Table `domain_events` + écriture transactionnelle | P0 | — | Sensible | Événement toujours écrit avec la donnée métier (C-20) |
| T-802 | Worker d'enfilage BullMQ + envoi email | P0 | T-801 | Standard | Retry avec backoff, `notification_deliveries` à jour |
| T-803 | Idempotence des jobs de notification | P0 | T-802 | Sensible | Pas de doublon sur rejouage |

## EPIC 11 — Sécurité transverse

| ID | Tâche | Prio | Dépendances | Sensibilité | Critère d'acceptation |
|---|---|---|---|---|---|
| T-1001 | En-têtes de sécurité (CSP, HSTS, etc.) | P0 | — | Sensible | Conforme `07_SECURITE_ET_AUTORISATION.md` §5 |
| T-1002 | CORS restrictif | P0 | — | Sensible | Liste blanche explicite |
| T-1003 | Endpoint de génération d'URL signée avec vérification d'autorisation systématique | P0 | EPIC 4 | Sensible | Même contrôle que l'accès direct à la ressource |

## EPIC 12 — Infrastructure & exploitation

| ID | Tâche | Prio | Dépendances | Sensibilité | Critère d'acceptation |
|---|---|---|---|---|---|
| T-1101 | Pipeline de migration (Prisma) avec revue avant application prod | P0 | — | Sensible | Conforme `11_DEPLOIEMENT_ET_EXPLOITATION.md` |
| T-1102 | Sauvegarde automatisée + test de restauration | P0 | — | Sensible | Restauration testée avant lancement |
| T-1103 | Health/readiness endpoints, logs structurés | P0 | — | Standard | `/health`, `/ready` opérationnels |

---

## Définition du MVP V1

Reprend les tâches P0 de l'ensemble des EPICs ci-dessus. Voir `00_VISION_ET_PERIMETRE.md` pour la description narrative du parcours couvert.

## Annexe — Backlog V2 (différé)

Inchangé par rapport à la révision précédente : Billing, Recognition, feedback avancé (synchronisation, annotations), régulation de charge avancée (liste d'attente automatique), conformité complète (RGPD-like), édition de Feedback publié, migration automatique de version, plusieurs pièces média par Submission.
