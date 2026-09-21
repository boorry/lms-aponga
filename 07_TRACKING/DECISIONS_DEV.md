# Décisions de développement

Aucune décision ne doit être prise implicitement dans le code.

## Décisions de verrouillage — 2026-09-21

| ID | Décision | Statut |
|---|---|---|
| LOCK-01 | `09_ENVIRONMENT/STACK_TECHNIQUE.md` est la source normative détaillée du stack. Aucune substitution automatique. | CLOSED |
| LOCK-02 | Une version exacte obligatoire indisponible est un BLOCKER ; aucune version de remplacement n'est choisie automatiquement. | CLOSED |
| LOCK-03 | Le workflow Claude AI → validation humaine → Claude Code est obligatoire avant implémentation significative. | CLOSED |
| LOCK-04 | `main` reçoit les changements applicatifs par Pull Request après CI/revue. | CLOSED |
| LOCK-05 | GitHub Actions constitue la CI de référence. | CLOSED |
| LOCK-06 | Les rôles sont historisés dans `user_roles`; seules les affectations actives donnent une autorisation. | CLOSED |
| LOCK-07 | Les tokens d'authentification persistants nécessaires à la rotation/révocation sont stockés sous forme hachée ; les tokens email/reset ont également une persistance dédiée. | CLOSED |
| LOCK-08 | `Course` suit DRAFT → IN_REVIEW → PUBLISHED, avec retour explicite PUBLISHED → IN_REVIEW ; aucune archive n'est dans le V1. | CLOSED |
| LOCK-09 | Feedback et revue de Submission ont des transitions API explicites ; aucun changement d'état ne doit être implicite dans une simple lecture. | CLOSED |
| LOCK-10 | Les Learning Delivery UI/PWA sont livrés dans la phase Frontend ; la phase Media ne valide que les capacités backend/média nécessaires. | CLOSED |
| LOCK-11 | Les sources pédagogiques référencées par des versions/progress/submissions ne sont pas supprimées physiquement en V1 ; elles sont retirées du brouillon par soft-delete. | CLOSED |
| LOCK-12 | Les soumissions sont rattachées à un Enrollment précis en plus de `course_version_id`. | CLOSED |
| LOCK-14 | Les timestamps sont stockés en UTC ; `birth_date` est une date civile sans fuseau ; les durées de signed URL V1 sont 60 min vidéo et 30 min fichier par défaut. | CLOSED |
| LOCK-13 | Les opérations avec `Idempotency-Key` utilisent une persistance dédiée pour rejouer proprement une réponse après redémarrage. | CLOSED |

## Règle

Une décision `OPEN` ou `BLOCKED` qui touche une source normative doit être résolue avant l'implémentation de la partie concernée.
