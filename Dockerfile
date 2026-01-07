FROM solr:9.10.0

# Root-Rechte für Installation
USER root

# ------------------------------------------------------------
# 1. Systempakete installieren (cron + jq)
# ------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y cron jq && \
    apt-get clean

# ------------------------------------------------------------
# 2. Backup-Verzeichnis + Log-Verzeichnis anlegen
# ------------------------------------------------------------
RUN mkdir -p /var/solr/backups && \
    mkdir -p /var/log && \
    touch /var/log/solr-backup.log && \
    chown -R solr:solr /var/solr/backups && \
    chown solr:solr /var/log/solr-backup.log

# ------------------------------------------------------------
# 3. Backup-/Restore-/Monitoring-Scripts integrieren
# ------------------------------------------------------------
COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

# ------------------------------------------------------------
# 4. Crontab integrieren
# ------------------------------------------------------------
COPY crontab /etc/cron.d/solr-backup
RUN chmod 0644 /etc/cron.d/solr-backup && \
    crontab /etc/cron.d/solr-backup

# ------------------------------------------------------------
# 5. Solr-Core vorbereiten
# ------------------------------------------------------------
USER solr
RUN mkdir -p /var/solr/collections

# ------------------------------------------------------------
# 6. Startkommando: Cron starten + Solr starten
# ------------------------------------------------------------
USER root
CMD cron && solr-precreate collections

# ------------------------------------------------------------
# 7. Healthcheck für Backup-Monitoring
# ------------------------------------------------------------
HEALTHCHECK --interval=60s --timeout=10s --retries=3 \
  CMD /scripts/healthcheck.sh || exit 1
