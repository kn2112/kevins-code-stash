#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <backup-archive.tar.gz>"
  exit 1
fi

ARCHIVE="$1"
WORK="/tmp/restore-bookstack"
rm -rf "$WORK"; mkdir -p "$WORK"
tar -xzf "$ARCHIVE" -C "$WORK"

# Adjust these as needed
APP_DIR="/var/www/bookstack"
STORAGE_DIR="/var/www/bookstack/storage"
DB_NAME="bookstack"
DB_USER="bookstack"
DB_HOST="localhost"

# Restore files
cp "$WORK/var/www/bookstack/.env" "$APP_DIR/.env"
rsync -a "$WORK/$STORAGE_DIR/" "$STORAGE_DIR/"

# Restore DB (you will be prompted for the password)
SQL_FILE=$(ls "$WORK"/tmp/bookstack-*.sql | head -n1)
mysql -h "$DB_HOST" -u "$DB_USER" -p "$DB_NAME" < "$SQL_FILE"

echo "Restore complete."
