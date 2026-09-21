#!/usr/bin/env bash
set -euo pipefail
fail=0
need() { command -v "$1" >/dev/null 2>&1 || { echo "[FAIL] missing: $1"; fail=1; }; }
need node
need npm
need docker

node_v="$(node -v 2>/dev/null || true)"
npm_v="$(npm -v 2>/dev/null || true)"
[[ "$node_v" == "v24.21.0" ]] && echo "[OK] Node $node_v" || { echo "[FAIL] Node expected v24.21.0, got $node_v"; fail=1; }
[[ "$npm_v" == "11.19.0" ]] && echo "[OK] npm $npm_v" || { echo "[FAIL] npm expected 11.19.0, got $npm_v"; fail=1; }
docker compose version >/dev/null 2>&1 && echo "[OK] Docker Compose" || { echo "[FAIL] Docker Compose v2 unavailable"; fail=1; }

echo "Checking Docker services..."
docker compose -f "$(dirname "$0")/docker-compose.dev.yml" ps >/dev/null 2>&1 || true

if [[ -f package.json ]]; then
  echo "Checking project dependencies..."
  node -e "const p=require('./package.json'); const c=p.dependencies||{}; const d=p.devDependencies||{}; const all={...d,...c}; console.log('@nestjs/core=',all['@nestjs/core']||'MISSING'); console.log('typescript=',all['typescript']||'MISSING'); console.log('prisma=',all['prisma']||'MISSING');"
fi

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "Environment base checks: PASS"
