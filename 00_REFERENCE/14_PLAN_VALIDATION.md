# 14 — Plan de validation — APONGA LMS

**Rôle** : vérifier que ce qui est construit correspond au besoin fermé décrit dans ce dossier — pas seulement que le code fonctionne et que les tests automatisés passent (voir aussi `10_STRATEGIE_DE_TEST.md` pour le détail des tests).

---

## 1. Validation fonctionnelle

| Quoi tester | Condition de réussite |
|---|---|
| Parcours Learner complet (découverte → inscription directe → apprentissage → soumission → feedback) | Parcours réalisable sans blocage ni aide externe |
| Parcours Teacher complet | Temps de correction jugé acceptable |
| Parcours Guardian (lecture seule) | Aucune action d'écriture possible |
| Toutes les règles de `04_MACHINES_ETATS_ET_REGLES_METIER.md` | 100 % couvertes par un test automatisé |
| Fonctionnement du MVP (`13_BACKLOG_V1.md`) | Toutes les User Stories P0 passent leurs critères d'acceptation |

## 2. Validation du versionnement pédagogique

| Quoi tester | Condition de réussite |
|---|---|
| Republication d'un cours après modification | Les inscrits existants ne voient aucun changement rétroactif |
| Suppression d'une leçon dans le brouillon | La version historique publiée la conserve intacte |
| Retour en édition d'un cours publié | Cours retiré du catalogue, inscrits existants non affectés |

## 3. Validation du cycle de vie média

| Quoi tester | Condition de réussite |
|---|---|
| Upload abandonné | Nettoyé après 24h |
| Accès à une Resource, une Submission, un Feedback | URL signée avec la durée correcte (1h vidéo, 15–30 min sensible) |
| Tentative d'accès non autorisé à un média | Refus systématique |

## 4. Validation Guardian / mineur

| Quoi tester | Condition de réussite |
|---|---|
| Blocage d'inscription/soumission pour un mineur sans Guardian actif | Refus systématique (INV-08) |
| Création d'un lien Guardian | Âge ≥18 vérifié, distinction vérifiée, unicité vérifiée |
| Révocation d'un lien | Non-rétroactive sur les accès déjà accordés |

## 5. Validation sécurité

| Quoi tester | Condition de réussite |
|---|---|
| Permissions par rôle et par objet | Aucun accès non autorisé possible |
| Expiration des URLs signées | Accès refusé après expiration |
| Rate limiting login/reset/upload | Verrouillage temporaire au-delà du seuil |
| Défense en profondeur | Aucun endpoint ne repose sur un seul niveau de contrôle |

## 6. Validation API

| Quoi tester | Condition de réussite |
|---|---|
| Conformité au contrat (`08_CONTRAT_API.md`) | Pas de route ni de statut hors contrat, notamment pas de `PENDING` |
| Idempotence (`Idempotency-Key`) | Une requête rejouée ne produit pas d'effet en double |
| Format d'erreur | Conforme sur l'ensemble des endpoints |

## 7. Validation notifications

| Quoi tester | Condition de réussite |
|---|---|
| Panne du worker de notification | Aucune perte de donnée métier, l'événement reste en attente puis se traite au redémarrage |
| Rejouage d'un job | Pas d'envoi en double |

## 8. Validation données

| Quoi tester | Condition de réussite |
|---|---|
| Cohérence du modèle logique (`03_MODELE_DE_DONNEES.md`) | Contraintes respectées, pas d'orphelins possibles |
| Calcul de `COMPLETED` sur un Enrollment | Cohérent avec les leçons obligatoires de la version pinée |
| Calcul de `retention_expires_at` | Cohérent avec la durée configurée |

## 9. Validation exploitation

| Quoi tester | Condition de réussite |
|---|---|
| Migration en environnement de staging avant production | Procédure testée et documentée |
| Restauration d'une sauvegarde | Testée au moins une fois avant le lancement public |
| Health/readiness | Endpoints opérationnels, supervision en place |

## 10. Principe général de validation

Aucune fonctionnalité P0 n'est considérée « terminée » sur la seule base de tests automatisés qui passent : elle doit franchir la validation fonctionnelle et, pour les parcours critiques, une validation en conditions terrain réelles. Le premier pilote avec de vrais utilisateurs reste le premier vrai test à grande échelle, pas une démonstration interne.
