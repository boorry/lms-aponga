#!/usr/bin/env bash
set -euo pipefail
FILE="$(dirname "$0")/docker-compose.dev.yml"
docker compose -f "$FILE" down -v
docker compose -f "$FILE" up -d
