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
docker info >/dev/null 2>&1 && echo "[OK] Docker daemon" || { echo "[FAIL] Docker daemon unavailable"; fail=1; }

echo "Checking Docker services..."
docker compose -f "$(dirname "$0")/docker-compose.dev.yml" ps >/dev/null 2>&1 || true

if [[ -f package.json ]]; then
  echo "Checking project dependencies..."
  node <<'NODE'
const p=require('./package.json');
const all={...(p.dependencies||{}),...(p.devDependencies||{})};
const exact={ '@nestjs/core':'12.0.1', 'typescript':'5.9.3' };
let fail=0;
for (const [name,want] of Object.entries(exact)) {
  if (all[name] !== want) { console.error(`[FAIL] ${name} expected ${want}, got ${all[name]||'MISSING'}`); fail=1; }
  else console.log(`[OK] ${name} ${want}`);
}
if (!/^7\./.test(all.prisma||'')) { console.error(`[FAIL] prisma expected 7.x, got ${all.prisma||'MISSING'}`); fail=1; }
else console.log(`[OK] prisma ${all.prisma}`);
if (!all['@prisma/client']) { console.error('[FAIL] @prisma/client missing'); fail=1; }
if (!all.argon2) { console.error('[FAIL] argon2 missing'); fail=1; }
process.exit(fail);
NODE
  [[ -f package-lock.json ]] || { echo "[FAIL] package-lock.json missing after bootstrap"; fail=1; }
fi

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "Environment base checks: PASS"
