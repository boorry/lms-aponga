# Workflow Claude Code

## Avant chaque tâche

- Identifier l'ID de tâche.
- Lire ses dépendances dans `13_BACKLOG_V1.md`.
- Lire les documents référencés.
- Inspecter le code réellement présent.
- Vérifier l'état Git.
- Ne pas supposer qu'une fonctionnalité existe parce qu'elle est documentée.

## Pendant

- Travailler par petits commits logiques.
- Ne pas modifier les fichiers hors périmètre sans justification.
- Préserver les contrats déjà validés.
- Écrire les tests avec le code.
- Exécuter les checks dès qu'un incrément cohérent est disponible.

## Après

Exécuter au minimum selon la phase :
```bash
npm run lint
npm run typecheck
npm test
npm run build
```

Pour l'API :
```bash
npm run test:e2e
```

Pour le frontend :
```bash
npm run build
npx playwright test
```

Les scripts exacts peuvent être adaptés au monorepo mais doivent conserver ces gates.

## Compte rendu obligatoire

Chaque tâche terminée doit ajouter à `07_TRACKING/DONE.md` :
- ID ;
- date ;
- résumé ;
- fichiers principaux ;
- tests exécutés ;
- résultat ;
- éventuel risque restant.
