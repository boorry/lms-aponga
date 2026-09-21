# Repository Layout Target

Après Foundation, le dépôt applicatif peut adopter :

```text
apps/
  api/                 # NestJS
  web/                 # Next.js
packages/
  config/              # config partagée si nécessaire
  contracts/           # types générés/contrats si retenus
  ui/                  # UI production réutilisable
prisma/                # schema/migrations si centralisés
infra/
  docker/
  nginx/
docs/                  # documentation projet si nécessaire
```

Le choix monorepo doit rester simple. Ne pas créer des packages artificiels avant qu'un partage réel le justifie.
