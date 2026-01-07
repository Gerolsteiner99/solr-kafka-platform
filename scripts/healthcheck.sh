#!/bin/bash

LOGFILE="/var/log/solr-backup.log"
BACKUP_DIR="/var/solr/backups"

# Prüfen, ob Logfile existiert
if [ ! -f "$LOGFILE" ]; then
    echo "Backup-Logfile fehlt"
    exit 1
fi

# Prüfen, ob in den letzten 24h ein Backup erstellt wurde
if ! find "$BACKUP_DIR" -type d -mtime -1 | grep -q .; then
    echo "Kein Backup in den letzten 24 Stunden"
    exit 1
fi

# Prüfen auf Fehler im Log
if grep -qi "error" "$LOGFILE"; then
    echo "Fehler im Backup-Log gefunden"
    exit 1
fi

echo "Backup-Status OK"
exit 0
