$ErrorActionPreference = 'Stop'
$fail = $false
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { Write-Host '[FAIL] missing: node'; $fail=$true }
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) { Write-Host '[FAIL] missing: npm'; $fail=$true }
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { Write-Host '[FAIL] missing: docker'; $fail=$true }
if (-not $fail) {
  $node = node -v
  $npm = npm -v
  if ($node -ne 'v24.21.0') { Write-Host "[FAIL] Node expected v24.21.0, got $node"; $fail=$true } else { Write-Host "[OK] Node $node" }
  if ($npm -ne '11.19.0') { Write-Host "[FAIL] npm expected 11.19.0, got $npm"; $fail=$true } else { Write-Host "[OK] npm $npm" }
  docker compose version | Out-Null
  docker info | Out-Null
  Write-Host '[OK] Docker Compose and Docker daemon'
}
if ($fail) { exit 1 }
Write-Host 'Environment base checks: PASS'

if (Test-Path package.json) {
  $pkg = Get-Content package.json -Raw | ConvertFrom-Json
  $all = @{}
  if ($pkg.dependencies) { $pkg.dependencies.psobject.Properties | ForEach-Object { $all[$_.Name]=$_.Value } }
  if ($pkg.devDependencies) { $pkg.devDependencies.psobject.Properties | ForEach-Object { $all[$_.Name]=$_.Value } }
  $checks = @{
    '@nestjs/core'='12.0.1'
    'typescript'='5.9.3'
  }
  foreach ($name in $checks.Keys) {
    if ($all[$name] -ne $checks[$name]) { Write-Host "[FAIL] $name expected $($checks[$name]), got $($all[$name])"; $fail=$true }
  }
  if (-not $all['prisma'] -or -not $all['prisma'].StartsWith('7.')) { Write-Host "[FAIL] prisma expected 7.x"; $fail=$true }
  if (-not $all['@prisma/client']) { Write-Host '[FAIL] @prisma/client missing'; $fail=$true }
  if (-not $all['argon2']) { Write-Host '[FAIL] argon2 missing'; $fail=$true }
  if (-not (Test-Path package-lock.json)) { Write-Host '[FAIL] package-lock.json missing'; $fail=$true }
}
if ($fail) { exit 1 }
