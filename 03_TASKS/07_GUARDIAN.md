# Guardian

Le domaine Guardian est volontairement livré en deux temps pour respecter les dépendances :

- **Phase 6 — prérequis métier** : T-901 et T-901b (création/révocation des liens, policies).
- **Phase 10 — consultation** : T-902, car la lecture de Progress/Feedbacks dépend de T-307 et T-506.

Aucun module aval ne doit contourner le domaine Guardian pour satisfaire INV-08.

## Acceptance Phase 6
Guardian >=18, mineur distinct, rôle Guardian, lien unique et tracé, révocation non rétroactive.

## Acceptance Phase 10
Consultation lecture seule, uniquement pour les mineurs liés par un Guardian actif.
