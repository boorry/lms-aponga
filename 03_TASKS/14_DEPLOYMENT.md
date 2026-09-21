# Deployment

Référence : `00_REFERENCE/11_DEPLOIEMENT_ET_EXPLOITATION.md`.

Implémenter T-1101, T-1102 : pipeline de migration Prisma revue avant application en production (T-1101), sauvegarde PostgreSQL automatisée et restauration testée au moins une fois avant le lancement public (T-1102).

Préparer staging puis production : build reproductible, migrations Prisma revues, secrets externes, Nginx, health/readiness, logs JSON, backup PostgreSQL et rollback.

Ne jamais appliquer une migration destructive directement en production.

## Acceptance
Migration appliquée avec succès en staging avant toute application en production. Sauvegarde restaurée avec succès au moins une fois. Rollback documenté et testable.
