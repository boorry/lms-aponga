# PRD UI de production

> Résumé opérationnel, sans autorité propre. En cas de divergence avec `00_REFERENCE/`, ce dernier fait foi.

## Principes
- PWA-first.
- Mobile-first.
- FR/EN.
- Accessibilité de base : navigation clavier, labels, contrastes, états d'erreur explicites.
- Économie de données : ne pas précharger la vidéo.
- Offline : shell, métadonnées et PDF déjà ouverts ; jamais la vidéo.

## Source design
Le template est placé dans `05_FRONTEND/template-source/`.

## Production
Les composants adaptés vivent dans `05_FRONTEND/production-ui/` et doivent être découplés du template original.
