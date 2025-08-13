#!/usr/bin/env bash
set -euo pipefail

# Simple BookStack backup; adjust for your environment
TS=$(date +%Y%m%d-%H%M%S)
OUT="bookstack-backup-$TS.tar.gz"

# Example paths
APP_DIR="/var/www/bookstack"
STORAGE_DIR="/var/www/bookstack/storage"
DB_NAME="bookstack"
DB_USER="bookstack"
DB_HOST="localhost"

TMP_SQL="/tmp/bookstack-$TS.sql"
mysqldump -h "$DB_HOST" -u "$DB_USER" -p "$DB_NAME" > "$TMP_SQL"

tar -czf "$OUT" "$APP_DIR/.env" "$STORAGE_DIR" "$TMP_SQL"

echo "Backup written: $OUT"
