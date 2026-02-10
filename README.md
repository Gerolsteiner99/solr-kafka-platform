# 🚀 Solr-Kafka-ZooKeeper HA Platform

## 📋 Übersicht
Hochverfügbare Plattform mit Apache Solr, Apache Kafka und Apache ZooKeeper in Kubernetes. Diese Plattform bietet vollständige Redundanz, automatisches Failover und skalierbare Such- und Streaming-Fähigkeiten für Produktionsumgebungen.

## 🏗️ Architektur
┌─────────────────────────────────────────────────┐
│ HOCHVERFÜGBARE ARCHITEKTUR │
├─────────────────────────────────────────────────┤
│ │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ │
│ │ZOOKEEPER│ │ZOOKEEPER│ │ZOOKEEPER│ │
│ │ Node 0 │ │ Node 1 │ │ Node 2 │ │
│ └───┬─────┘ └───┬─────┘ └───┬─────┘ │
│ │ │ │ │
│ ┌───┴─────┐ ┌───┴─────┐ ┌───┴─────┐ │
│ │ KAFKA │ │ KAFKA │ │ KAFKA │ │
│ │ Broker 0│ │ Broker 1│ │ Broker 2│ │
│ └───┬─────┘ └───┬─────┘ └───┬─────┘ │
│ │ │ │ │
│ ┌───┴─────┐ ┌───┴─────┐ ┌───┴─────┐ │
│ │ SOLR │ │ SOLR │ │ SOLR │ │
│ │ Node 0 │ │ Node 1 │ │ Node 2 │ │
│ └─────────┘ └─────────┘ └─────────┘ │
│ │
│ ✅ Quorum-basiertes ZooKeeper Ensemble │
│ ✅ Kafka mit Replication Factor 3 │
│ ✅ Solr Cloud mit verteilten Collections │
└─────────────────────────────────────────────────┘


## ✨ Features
- ✅ **Hochverfügbarkeit**: 3-Node pro Komponente
- ✅ **Automatisches Failover**: Getestet und verifiziert
- ✅ **Horizontale Skalierung**: Einfache Erweiterung möglich
- ✅ **Production-Ready**: Vollständig getestete HA-Architektur
- ✅ **Überwachung**: Integrierte Health-Checks
- ✅ **Kubernetes-Native**: Optimiert für Container-Umgebungen

## 🚀 Schnellstart

### Voraussetzungen
- Kubernetes Cluster (v1.20+)
- kubectl konfiguriert
- 8+ GB RAM verfügbar
- Persistent Storage (optional)

### Installation
```bash
# 1. Repository klonen
git clone <repository-url>
cd solr-kafka-platform

# 2. Namespace erstellen
kubectl create namespace solr-kafka-ha

# 3. Plattform deployen
./scripts/deploy-ha-platform.sh

# 4. Status überprüfen
./scripts/test-ha-platform-complete.sh

📊 Komponenten-Status
Komponente	Version	Nodes	Status	HA
ZooKeeper	3.8.x	3	✅ Operational	✅
Kafka	3.5.x	3	✅ Operational	✅
Solr	9.x	3	✅ Operational	✅
🔧 Verwaltung

# Kompletten HA Test durchführen
./scripts/test-ha-platform-complete.sh

# Einfache Statusprüfung
./scripts/health-check.sh

# Komponenten-spezifische Checks
./scripts/check-zookeeper.sh
./scripts/check-kafka.sh
./scripts/check-solr.sh


# 5. Scalierung

# Solr Nodes erhöhen
kubectl scale deployment solr-standalone --replicas=5 -n solr-kafka-ha

# Kafka Brokers erhöhen (manuelle Konfiguration erforderlich)
# ZooKeeper erhöhen (nur ungerade Zahlen: 3,5,7...)

📈 Monitoring & Logging
Zugriff auf Services

# Solr UI (port-forward)
kubectl port-forward svc/solr 8983:8983 -n solr-kafka-ha
# Öffnen: http://localhost:8983/solr

# Kafka (externer Zugriff)
kubectl port-forward svc/kafka 9092:9092 -n solr-kafka-ha

# ZooKeeper CLI
kubectl exec -it zookeeper-0 -n solr-kafka-ha -- zkCli.sh


# 6. Logs anzeigen

# Alle Logs
kubectl logs -l app=solr -n solr-kafka-ha --tail=50

# Spezifische Komponente
kubectl logs -l app=kafka -n solr-kafka-ha
kubectl logs -l app=zookeeper -n solr-kafka-ha


🛠️ Troubleshooting
Siehe TROUBLESHOOTING.md für häufige Probleme und Lösungen.

📚 Weitere Dokumentation
CHEATSHEETS.md - Kommando-Referenz

TROUBLESHOOTING.md - Problembehandlung

PROJECT-HISTORY.md - Projektverlauf

RESOURCES.md - Weitere Ressourcen


🏆 Erfolgreich getestete HA-Features
✅ ZooKeeper Leader Failover (30s Recovery)

✅ Kafka Broker Failover (45s Recovery)

✅ Cross-Component Connectivity

✅ DNS & Service Discovery

✅ Data Replication (RF=3)
