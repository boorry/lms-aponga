#!/usr/bin/env bash
set -euo pipefail
node -v
npm -v
printf 'Expected Node: 24.21.0\nExpected npm: 11.19.0\n'
if [[ -f package.json ]]; then
  node - <<'NODE'
const p=require('./package.json');
const all={...(p.dependencies||{}),...(p.devDependencies||{})};
for (const k of ['@nestjs/core','typescript','prisma','@prisma/client','bullmq']) console.log(`${k}: ${all[k]||'NOT_DECLARED'}`);
NODE
fi
