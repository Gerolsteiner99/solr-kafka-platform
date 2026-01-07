#!/bin/bash

SOLR_URL="http://localhost:8983/solr"
BACKUP_DIR="/var/solr/backups"

if [ $# -ne 2 ]; then
    echo "Usage: restore.sh <collection> <backup-name>"
    exit 1
fi

COLLECTION=$1
BACKUP_NAME=$2

echo "Stelle Collection $COLLECTION aus Backup $BACKUP_NAME wieder her..."

curl "$SOLR_URL/admin/collections?action=RESTORE&collection=$COLLECTION&name=$BACKUP_NAME&location=$BACKUP_DIR"

echo "Restore abgeschlossen."
