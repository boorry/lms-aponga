# Installation et configuration de l'environnement

## 1. Pré-requis machine

### Windows
Utiliser WSL2 avec Ubuntu récent et Docker Desktop avec intégration WSL activée.

### Linux
Docker Engine + Docker Compose v2, Git, curl et outils de build Node.

## 2. Node.js

Version obligatoire : **24.21.0**.

Installer via un gestionnaire de versions tel que `nvm` afin de rendre le changement de version reproductible. Le projet doit contenir `.nvmrc` avec :

```text
24.21.0
```

Puis :

```bash
nvm install 24.21.0
nvm use 24.21.0
corepack disable 2>/dev/null || true
npm install -g npm@11.19.0
node --version
npm --version
```

Le résultat attendu est Node `v24.21.0` et npm `11.19.0`.

## 3. NestJS

Ne pas installer Nest CLI globalement comme dépendance de production. Le projet utilise NestJS `12.0.1` dans `package.json` et peut utiliser `npx nest` à partir de la dépendance locale.

Le bootstrap doit vérifier :
```bash
npm ls @nestjs/core
```

## 4. TypeScript

Version obligatoire : `5.9.3`.

```bash
npm install --save-dev typescript@5.9.3
```

Une fois le projet initialisé, utiliser la version locale :
```bash
npx tsc --version
```

## 5. PostgreSQL

Version majeure obligatoire : PostgreSQL 17.x.

Le développement local utilise Docker, pas une installation PostgreSQL concurrente sur l'hôte.

Service : `postgres`.

Port local par défaut : `5432`, configurable dans `.env`.

## 6. Redis

Version de référence : Redis 8.2.x.

Le développement local utilise Docker.

Service : `redis`.

Port local par défaut : `6379`.

## 7. Prisma

Prisma `7.x`. La version exacte doit être choisie puis verrouillée dans le projet.

Après installation :
```bash
npx prisma validate
npx prisma generate
```

Les migrations sont appliquées localement avec :
```bash
npx prisma migrate dev
```

En staging/production :
```bash
npx prisma migrate deploy
```

Jamais `migrate dev` en production.

## 8. Docker

Le fichier `08_SCRIPTS/docker-compose.dev.yml` démarre uniquement les dépendances d'infrastructure : PostgreSQL et Redis. Le backend et le frontend peuvent être exécutés en mode développement avec hot reload depuis l'hôte/WSL.

Commandes :
```bash
docker compose -f 08_SCRIPTS/docker-compose.dev.yml up -d

docker compose -f 08_SCRIPTS/docker-compose.dev.yml ps
```

## 9. Variables d'environnement

Copier `.env.example` vers `.env` dans le workspace applicatif.

Ne jamais commit `.env`.

## 10. Cloudflare

R2 et Stream nécessitent des credentials fournis par l'environnement. Le bootstrap local ne doit pas créer de secrets fictifs valides. Pour les tests automatisés, utiliser des adaptateurs mock/fake conformément à la stratégie de test.

## 11. Frontend

Next.js est PWA-first. La version exacte doit être verrouillée au bootstrap frontend, puis inscrite dans `STACK_TECHNIQUE.md` et `package-lock.json`.

Ne pas utiliser `create-next-app@latest` une fois la version choisie. Utiliser la version exacte.

## 12. Vérification finale

Exécuter :
```bash
./08_SCRIPTS/verify-env.sh
```

Sous PowerShell :
```powershell
./08_SCRIPTS/verify-env.ps1
```

Le script doit échouer si une version obligatoire est incorrecte.
