# APONGA LMS — Stack technique normatif

## Versions verrouillées

| Élément | Valeur | Règle |
|---|---|---|
| Node.js | 24.21.0 | obligatoire |
| npm | 11.19.0 | obligatoire |
| TypeScript | 5.9.3 | obligatoire côté backend/projet TS |
| NestJS | 12.0.1 | obligatoire |
| Prisma | 7.x | version exacte choisie avant bootstrap, puis obligatoire dans package.json/lockfile |
| PostgreSQL | 17.x | version majeure obligatoire |
| Redis | 8.2.x | version majeure/minor de référence |
| BullMQ | version compatible avec Redis 8.2 et Node 24 | version exacte choisie et lockfile |
| Next.js | Next.js PWA-first | version exacte choisie avant bootstrap frontend, puis obligatoire dans package.json/lockfile |
| Jest | version compatible avec NestJS 12 / Node 24 | version exacte choisie et lockfile |
| Supertest | version compatible avec NestJS | version exacte choisie et lockfile |
| Playwright | version compatible avec Node 24 | version exacte choisie et lockfile |
| Docker | Docker Engine + Compose v2 | version hôte contrôlée par script |
| R2 | Cloudflare R2 | provider obligatoire |
| Stream | Cloudflare Stream | provider obligatoire pour vidéo |
| Nginx | reverse proxy production | version fournie par OS/hébergement, à documenter au déploiement |

## Architecture

```text
Next.js PWA
      ↓ REST/OpenAPI
NestJS 12.0.1
      ↓ Prisma 7.x
PostgreSQL 17.x
      ↘ Redis 8.2.x ↔ BullMQ
      ↘ Cloudflare R2
      ↘ Cloudflare Stream
```

## Règle de verrouillage

Après bootstrap, toutes les dépendances sont verrouillées par lockfile. Les installations avec `@latest`, `*`, `^` ou `~` ne doivent pas être utilisées pour introduire une nouvelle dépendance critique sans revue. Les plages éventuellement présentes dans les manifests doivent être résolues par le lockfile et vérifiées en CI.

## Procédure de verrouillage des versions non encore fixées

Avant le bootstrap d'une dépendance dont la version exacte n'est pas déjà imposée :

1. identifier la dernière version compatible avec le stack verrouillé ;
2. vérifier sa compatibilité et ses peerDependencies ;
3. consigner le choix dans `07_TRACKING/ENVIRONMENT_LOG.md` et `07_TRACKING/DECISIONS_DEV.md` ;
4. faire valider ce choix humainement si la version introduit une décision majeure ;
5. installer une version exacte ;
6. committer `package-lock.json`.

Si une version obligatoire déjà fixée (Node, npm, TypeScript, NestJS) est indisponible, **STOP : BLOCKER**. Aucune version de remplacement n'est choisie automatiquement.

## Ce qui n'est pas autorisé

- SQLite en remplacement de PostgreSQL ;
- TypeORM/Drizzle en remplacement de Prisma ;
- MongoDB ;
- RabbitMQ/Kafka en remplacement de Redis/BullMQ ;
- Express standalone hors NestJS ;
- microservices V1 ;
- GraphQL sans décision ;
- stockage local de production pour les médias ;
- vidéo stockée dans R2 si le besoin relève de Cloudflare Stream.
