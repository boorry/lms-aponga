# Data Model

Références : `03_MODELE_DE_DONNEES.md`, `04_MACHINES_ETATS_ET_REGLES_METIER.md`.

Implémenter Prisma schema, migrations, indexes, contraintes et repositories.

Ce chantier précède Identity & Security : il doit livrer au minimum les tables `users`, `roles`, `user_roles`, `refresh_tokens`, `email_verification_tokens`, `password_reset_tokens`, `domain_events`, `idempotency_keys` avant que la phase suivante ne puisse persister un compte. Il ne correspond à aucune tâche `T-xxx` dédiée du backlog (travail transversal, prérequis à toutes les tâches suivantes) — sa complétude se mesure à la Gate P2, pas à une liste de tâches numérotées.

## Seed de développement — obligatoire

Le seed minimal doit créer :
- au moins un compte **Administrator** avec des identifiants issus des variables d'environnement `SEED_ADMIN_EMAIL` / `SEED_ADMIN_PASSWORD` (jamais une valeur en dur dans le code). Sans ce compte, personne ne peut attribuer de rôle après le bootstrap : `POST /auth/register` crée toujours un Learner (voir `00_REFERENCE/08_CONTRAT_API.md`), il n'existe aucun parcours d'auto-promotion en Administrator.
- les rôles de référence (`learner`, `teacher`, `content_author`, `academy_manager`, `administrator`, `guardian`) et un `email_verified_at` valide pour le compte Administrator seedé.

Le seed doit être idempotent (rejouable sans dupliquer le compte Administrator).

## Acceptance
Migration from scratch + seed + tests invariants passent. Le compte Administrator seedé est présent avec un mot de passe Argon2id dérivé de `SEED_ADMIN_PASSWORD`; la connexion HTTP est validée en P3.
