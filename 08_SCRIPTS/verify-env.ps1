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
  Write-Host '[OK] Docker Compose'
}
if ($fail) { exit 1 }
Write-Host 'Environment base checks: PASS'
