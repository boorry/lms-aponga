#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

"$ROOT/08_SCRIPTS/verify-env.sh"

echo '[1/4] Starting infrastructure...'
docker compose -f "$ROOT/08_SCRIPTS/docker-compose.dev.yml" up -d

echo '[2/4] Waiting for PostgreSQL and Redis...'
for i in {1..30}; do
  pg="$(docker inspect --format='{{.State.Health.Status}}' aponga-lms-postgres 2>/dev/null || true)"
  rd="$(docker inspect --format='{{.State.Health.Status}}' aponga-lms-redis 2>/dev/null || true)"
  [[ "$pg" == healthy && "$rd" == healthy ]] && break
  sleep 2
done
[[ "$(docker inspect --format='{{.State.Health.Status}}' aponga-lms-postgres)" == healthy ]]
[[ "$(docker inspect --format='{{.State.Health.Status}}' aponga-lms-redis)" == healthy ]]

echo '[3/4] Installing workspace dependencies if package.json exists...'
if [[ -f package.json ]]; then npm ci; else echo 'No root package.json yet; Foundation task must create it.'; fi

echo '[4/4] Infrastructure ready.'
