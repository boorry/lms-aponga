# Prompt de mission Claude Code

Tu travailles sur APONGA LMS.

## Mission
**ID : `<TASK_ID>`**

## Références obligatoires
- `CLAUDE.md`
- `00_REFERENCE/<...>`
- `03_TASKS/<...>`

## Avant de coder
1. Vérifie l'état du dépôt.
2. Vérifie les dépendances.
3. Vérifie que l'environnement respecte le stack.
4. Inspecte l'implémentation existante.
5. Signale toute contradiction dans `07_TRACKING/BLOCKERS.md`.

## Implémentation
- Respecte strictement les invariants.
- Ne change pas le contrat API sans mise à jour préalable de la référence.
- Ne remplace aucun composant du stack.
- Ajoute les tests nécessaires.

## Validation
Exécute les checks pertinents, puis indique précisément :
- ce qui a été réalisé ;
- les tests exécutés ;
- les résultats ;
- les fichiers modifiés ;
- les risques ou décisions restantes.

Ne déclare pas la tâche terminée si son critère d'acceptation n'est pas démontré.
