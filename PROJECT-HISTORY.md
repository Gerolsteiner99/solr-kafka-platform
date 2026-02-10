# Projektchronik – Solr‑Kafka‑Platform

Dieses Dokument beschreibt vollständig und chronologisch alle Schritte, Befehle, Fehler, Ursachen und Lösungen, die während der Entwicklung und Inbetriebnahme der Solr‑Kafka‑Plattform auf Kubernetes durchgeführt wurden. Es dient als technisches Logbuch und ermöglicht jederzeit eine vollständige Nachvollziehbarkeit des Projektverlaufs.

---

## Ausgangssituation

Ziel war der Aufbau einer vollständigen Solr‑Kafka‑Plattform auf Kubernetes, bestehend aus:

- SolrCloud (3 Nodes)
- Kafka Broker
- ZooKeeper Ensemble
- CronJob zur monatlichen Collection‑Erstellung
- Umbrella‑Helm‑Chart zur Orchestrierung

Die Arbeit erfolgte auf einem Kubernetes‑Cluster, gesteuert über Helm und kubectl. Das Projekt wurde parallel auf einem Server, einem Mac und GitHub verwaltet.

---

## Erstellung und Anpassung der Helm‑Charts

Zu Beginn wurden die drei Hauptkomponenten als eigene Helm‑Charts angelegt:

- charts/solr
- charts/kafka
- charts/zookeeper

Dabei wurden folgende Dateien erstellt oder angepasst:

- statefulset.yaml für Solr, Kafka und ZooKeeper
- headless‑services
- externe Services
- ConfigMaps für ZooKeeper
- CronJob für Solr‑Collections
- ServiceAccount für Solr
- Ingress‑Definitionen (optional)

Während der Entwicklung wurden mehrere Probleme identifiziert und behoben:

1. **Fehlerhafte ENV‑Variablen in Solr**
   Ursache: Werte wurden nicht korrekt in das Template übernommen.  
   Lösung: Anpassung der Helm‑Templates und Values.

2. **ZooKeeper‑Konfiguration wurde nicht geladen**
   Ursache: Fehlende oder falsch referenzierte ConfigMap.  
   Lösung: Erstellung einer vollständigen configmap.yaml.

3. **Kafka konnte nicht starten**
   Ursache: ZooKeeper‑Ensemble nicht erreichbar.  
   Lösung: Ports und Headless‑Service korrigiert.

4. **Solr Collections wurden nicht automatisch erstellt**
   Ursache: CronJob fehlte oder war fehlerhaft.  
   Lösung: Erstellung von cronjob-monthly-collection.yaml.

---

## Debugging und Analyse

Während der Entwicklung wurden zahlreiche Debugging‑Schritte durchgeführt:

- Anzeigen laufender Pods:
  kubectl get pods -n solrkafka

- Logs prüfen:
  kubectl logs <pod> -n solrkafka

- StatefulSets inspizieren:
  kubectl get statefulset -n solrkafka

- PVC‑Probleme analysieren:
  kubectl get pvc -n solrkafka

- Manuelles Testen der Solr‑API:
  curl "http://localhost:8983/solr/admin/collections?action=CREATE&name=test..."

- Neustart einzelner Pods:
  kubectl delete pod <pod> -n solrkafka

- Rendern der Helm‑Templates:
  helm template .

- Überprüfung der finalen Manifeste:
  helm get manifest solr-kafka -n solrkafka

Diese Schritte führten zur schrittweisen Stabilisierung der Plattform.

---

## Erstellung zusätzlicher Dateien

Im Verlauf wurden weitere Dateien erzeugt:

- full.yaml.disabled (ehemals full.yaml)
- running-pod.yaml (Analyse eines laufenden Pods)
- solr-kafka-working.tar.gz (Backup/Export)
- GitHub Actions Workflow: .github/workflows/helm-lint.yaml

Diese Dateien dienten der Dokumentation, Analyse und Automatisierung.

---

## Erstellung der vollständigen Dokumentation

Es wurden mehrere neue Dokumentationsdateien erstellt:

- README.md (mit vollständigem Projektbaum)
- CHEATSHEETS.md (Helm & kubectl)
- RESOURCES.md (alle Kubernetes‑Ressourcen)
- TROUBLESHOOTING.md (Fehleranalyse)
- GIT-CHEATSHEET.md (Git‑Befehle)
- GIT-WORKFLOW.md (Git‑Arbeitsablauf)

Diese Dateien wurden direkt auf dem Server im Projektverzeichnis angelegt.

---

## Commit der neuen Dateien

Nach Abschluss der Dokumentation wurden alle Dateien in Git übernommen:

git add .
git commit -m "Add full documentation set"

Git meldete:

29 files changed, 1252 insertions(+), 458 deletions(-)
create mode 100644 CHEATSHEETS.md
create mode 100644 GIT-CHEATSHEETS.md
create mode 100644 GIT-WORKFLOW.md
create mode 100644 RESOURCES.md
create mode 100644 TROUBLESHOOTING.md
create mode 100644 charts/kafka-0.1.0.tgz
create mode 100644 charts/solr-0.1.0.tgz
create mode 100644 charts/zookeeper-0.1.0.tgz
rename full.yaml => full.yaml.disabled
create mode 100644 solr-kafka-platform/.github/workflows/helm-lint.yaml
create mode 100644 solr-kafka-working.tar.gz

Damit waren alle Änderungen lokal versioniert.

---

## Fehler beim Push nach GitHub

Beim Versuch, die Änderungen hochzuladen:

git push

trat folgender Fehler auf:

Updates were rejected because the remote contains work that you do not have locally.

Ursache:

- GitHub enthält Commits, die lokal auf dem Server fehlen.
- Git verhindert, dass diese überschrieben werden.

Dies passiert typischerweise, wenn:

- Dateien direkt auf GitHub erstellt wurden
- ein anderer Rechner (Mac) gepusht hat
- GitHub automatisch Dateien angelegt hat (z. B. Workflow)

---

## Geplanter Lösungsweg

Um die Änderungen erfolgreich zu pushen, muss zuerst der Remote‑Stand integriert werden:

git pull --rebase origin main

Danach:

git push

Anschließend muss der Mac synchronisiert werden:

git pull

Damit sind Server, GitHub und Mac wieder identisch.

---

## Aktueller Status

- Die Solr‑Kafka‑Plattform ist vollständig aufgebaut.
- Alle Helm‑Charts sind funktionsfähig.
- Die Dokumentation ist vollständig erstellt.
- Git‑Commit ist lokal vorhanden.
- Push nach GitHub steht unmittelbar bevor (nach rebase).
- Das Projekt ist bereit für weitere Entwicklung oder Deployment.

---

## Fazit

Dieses Dokument fasst alle technischen Schritte, Befehle, Fehler, Ursachen und Lösungen zusammen, die während der Entwicklung der Solr‑Kafka‑Plattform durchgeführt wurden. Es bildet eine vollständige Chronik des Projekts und ermöglicht jederzeit eine lückenlose Nachvollziehbarkeit.

