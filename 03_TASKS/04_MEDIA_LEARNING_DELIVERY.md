# Media & Learning Delivery

Références : `06_MEDIA_LIFECYCLE.md`, sécurité, API, `02_ARCHITECTURE_CONCEPTION.md` (contraintes terrain, mode économie de données, cache PWA).

Cette tâche couvre les capacités backend média et les exigences Learning Delivery. Les capacités backend sont validées en Phase 5 ; les éléments UI/PWA sont explicitement reportés à la Phase 11 Frontend afin de ne pas créer une dépendance inverse.

## Volet 1 — Cycle de vie technique des médias
Implémenter T-301, T-301b, T-311 : `media_assets`, upload présigné, complete, vérifications (taille, type, existence réelle chez le provider), nettoyage des uploads abandonnés (`INITIATED`/`UPLOADING` > 24h).

**Règle de routage provider** (non ambiguë) : `provider = stream` uniquement pour `resource_kind = VIDEO` ; `provider = r2` pour `AUDIO`, `PDF` et `IMAGE`. Aucune vidéo n'est stockée sur R2, aucun autre type de fichier n'est envoyé à Stream.

Implémenter également T-1003 : l'endpoint de génération d'URL signée applique systématiquement la même vérification d'autorisation que l'accès direct à la ressource protégée (voir `07_SECURITE_ET_AUTORISATION.md` §5).

## Volet 2 — Expérience de consommation d'une leçon (Learning Delivery)
Préparer en Phase 5 T-302 et T-304 : endpoints d'accès vidéo/PDF et contrôles backend. Livrer en Phase 11 T-302b, T-305 et T-310 : contrôles du lecteur, mode économie de données et cache PWA.

**Rappel de choix fermé** : le cache PWA ne contient jamais de vidéo (URLs signées à courte durée de vie, incompatibles avec un cache hors-ligne permanent) — voir `06_MEDIA_LIFECYCLE.md` et `02_ARCHITECTURE_CONCEPTION.md` §8.

## Acceptance Phase 5
Cycle backend upload → complete → access → expiration testé et permissions vérifiées. Les endpoints vidéo/PDF nécessaires au frontend existent et sont conformes au contrat.

## Acceptance Phase 11
Les contrôles du lecteur, le mode économie de données et le cache PWA sont fonctionnels et testés, sans mise en cache vidéo hors-ligne.
