# APONGA LMS — Architecture de réalisation

> Résumé opérationnel, sans autorité propre. En cas de divergence avec `00_REFERENCE/`, ce dernier fait foi.

## Architecture cible

```text
Next.js PWA
     |
     | REST/OpenAPI
     v
NestJS modular monolith
     |
     +---- Prisma ---- PostgreSQL 17
     |
     +---- Redis ---- BullMQ
     |
     +---- Cloudflare R2
     |
     +---- Cloudflare Stream
```

## Modules NestJS
Identity & Access, Learning Design, Content & Media, Enrollment, Learning Delivery, Assessment, Progression, Communication, Reporting, Administration, Localization.

Les modules restent dans un monolithe ; les dépendances croisées doivent passer par des interfaces/services explicites et éviter les accès directs aux tables d'un autre module.

## Frontend
Next.js PWA-first. Les composants de production sont distincts de la source du template.
