# Media & Learning Delivery

Références : `06_MEDIA_LIFECYCLE.md`, sécurité, API, `02_ARCHITECTURE_CONCEPTION.md` (contraintes terrain, mode économie de données, cache PWA).

Cette tâche regroupe deux volets indissociables — comme dans l'EPIC 4 du backlog — après correction lors de l'audit final (l'ancienne version de ce fichier ne couvrait que le premier volet ; le second n'était rattaché à aucune tâche, voir `FINAL_AUDIT.md`).

## Volet 1 — Cycle de vie technique des médias
Implémenter T-301, T-301b, T-311 : `media_assets`, upload présigné, complete, vérifications (taille, type, existence réelle chez le provider), nettoyage des uploads abandonnés (`INITIATED`/`UPLOADING` > 24h).

**Règle de routage provider** (non ambiguë) : `provider = stream` uniquement pour `resource_kind = VIDEO` ; `provider = r2` pour `AUDIO`, `PDF` et `IMAGE`. Aucune vidéo n'est stockée sur R2, aucun autre type de fichier n'est envoyé à Stream.

Implémenter également T-1003 : l'endpoint de génération d'URL signée applique systématiquement la même vérification d'autorisation que l'accès direct à la ressource protégée (voir `07_SECURITE_ET_AUTORISATION.md` §4).

## Volet 2 — Expérience de consommation d'une leçon (Learning Delivery)
Implémenter T-302, T-302b, T-304, T-305, T-310 : lecteur vidéo en streaming sécurisé avec contrôles qualité/vitesse/boucle A-B, lecture PDF, mode économie de données (masque la vidéo, priorise audio + PDF), cache PWA du shell applicatif et des métadonnées/PDF déjà consultés.

**Rappel de choix fermé** : le cache PWA ne contient jamais de vidéo (URLs signées à courte durée de vie, incompatibles avec un cache hors-ligne permanent) — voir `06_MEDIA_LIFECYCLE.md` et `02_ARCHITECTURE_CONCEPTION.md` §8.

## Acceptance
Cycle complet upload → complete → access → expiration testé et permissions vérifiées (volet 1). Lecture vidéo/PDF, mode économie de données et cache PWA fonctionnels et testés, sans mise en cache vidéo hors-ligne (volet 2).
