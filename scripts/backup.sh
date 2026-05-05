#!/bin/bash

set -euo pipefail

BACKUP_DIR="/backups"
DATA_DIR="/data"
DB_FILE="${DATA_DIR}/db.sqlite3"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/vaultwarden_backup_${TIMESTAMP}.sqlite3"

echo "[$(date)] Starting backup..."

mkdir -p "${BACKUP_DIR}"

if [ ! -f "${DB_FILE}" ]; then
    echo "[$(date)] ERROR: Database file not found at ${DB_FILE}"
    exit 1
fi

cp "${DB_FILE}" "${BACKUP_FILE}"
echo "[$(date)] Backup created: ${BACKUP_FILE}"

find "${BACKUP_DIR}" -name "vaultwarden_backup_*.sqlite3" -type f -mtime +30 -delete
echo "[$(date)] Backups older than 30 days cleaned up."

echo "[$(date)] Backup complete. Size: $(du -h "${BACKUP_FILE}" | cut -f1)"
