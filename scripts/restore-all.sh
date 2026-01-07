#!/bin/bash

SOLR_URL="http://localhost:8983/solr"
BACKUP_DIR="/var/solr/backups"
MANIFEST="restore-manifest.txt"

while IFS='=' read -r collection backup; do
    echo "Stelle $collection aus $backup wieder her..."
    curl "$SOLR_URL/admin/collections?action=RESTORE&collection=$collection&name=$backup&location=$BACKUP_DIR"
done < "$MANIFEST"

echo "Alle Restores abgeschlossen."
