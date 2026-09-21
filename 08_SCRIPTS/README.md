# Scripts d'environnement

- `verify-env.sh` / `verify-env.ps1` : vérifient Node, npm et Docker.
- `docker-compose.dev.yml` : PostgreSQL 17 + Redis 8.2.
- `bootstrap.sh` : vérification + démarrage infrastructure + npm ci si workspace déjà créé.
- `stop-dev.sh` : arrête les services sans supprimer les volumes.
- `reset-dev.sh` : détruit les volumes et recrée les services. **Données locales perdues.**

Les scripts ne contiennent aucun secret Cloudflare.
