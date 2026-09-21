# Identity & Security

Références : `07_SECURITE_ET_AUTORISATION.md`, modèle, états, API.

Prérequis : `01_DATA_MODEL.md` (tables `users`/`roles`/`user_roles` et seed Administrator déjà en place).

Implémenter T-101 à T-108, ainsi que T-1001 et T-1002 s'ils n'ont pas déjà été couverts par `00_FOUNDATION.md`. Tester access/refresh rotation, email verification, rate limiting, rôles, permissions et policies objet.

`POST /auth/register` crée toujours un compte avec le seul rôle `learner`. Aucun autre rôle ne peut être obtenu par auto-inscription : Teacher, Content Author, Academy Manager, Administrator et Guardian sont attribués par un Administrator via `GET/PATCH /admin/users` (voir `00_REFERENCE/08_CONTRAT_API.md`).

## Acceptance
Access/refresh rotation, vérification email, rate limiting, permissions par rôle et policies objet démontrés par des tests. CORS et en-têtes de sécurité vérifiés (T-1001, T-1002) s'ils n'ont pas déjà été validés en phase Foundation.
