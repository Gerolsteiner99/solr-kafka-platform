#!/bin/bash

SOLR_URL="http://localhost:8983/solr"
BACKUP_DIR="/var/solr/backups"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

collections=$(curl -s "$SOLR_URL/admin/collections?action=LIST" | jq -r '.collections[]')

echo "[$TIMESTAMP] Starte Backup für Collections: $collections"

for col in $collections; do
    backup_name="${col}-${TIMESTAMP}"
    echo "[$TIMESTAMP] Sichere $col nach $backup_name"

    curl -s "$SOLR_URL/admin/collections?action=BACKUP&collection=$col&name=$backup_name&location=$BACKUP_DIR" \
        >> /var/log/solr-backup.log 2>&1
done

echo "[$TIMESTAMP] Backup abgeschlossen." >> /var/log/solr-backup.log
