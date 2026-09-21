# Identity & Security

Références : `07_SECURITE_ET_AUTORISATION.md`, modèle, états, API.

Prérequis : `01_DATA_MODEL.md` (tables `users`/`roles`/`user_roles` et seed Administrator déjà en place).

Implémenter explicitement T-101, T-102, T-103, T-104, T-105, T-106, T-107, T-108, ainsi que T-1001 et T-1002 s'ils n'ont pas déjà été couverts par `00_FOUNDATION.md`. Tester access/refresh rotation, vérification email via `POST /auth/verify-email`, reset password, rate limiting, rôles historisés, permissions et policies objet. Le mot de passe V1 utilise Argon2id.

`POST /auth/register` crée toujours un compte avec le seul rôle `learner`. Les autres rôles sont attribués via `PATCH /admin/users/:id`, selon la matrice de `07_SECURITE_ET_AUTORISATION.md` ; seul Administrator peut attribuer/révoquer le rôle `administrator`.

## Acceptance
Access/refresh rotation, vérification email, rate limiting, permissions par rôle et policies objet démontrés par des tests. CORS et en-têtes de sécurité vérifiés (T-1001, T-1002) s'ils n'ont pas déjà été validés en phase Foundation.
