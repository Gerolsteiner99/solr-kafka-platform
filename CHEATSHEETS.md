### **2. CHEATSHEETS.md - Kommando-Referenz**

# 🚀 Solr-Kafka-HA Platform Cheatsheets

## 📋 QUICK COMMANDS

### Namespace Management
```bash
# Namespace erstellen
kubectl create namespace solr-kafka-ha

# Aktuellen Namespace setzen
kubectl config set-context --current --namespace=solr-kafka-ha

# Alle Ressourcen im Namespace anzeigen
kubectl get all -n solr-kafka-ha

🐘 ZOOKEEPER COMMANDS

# ZooKeeper Status prüfen
kubectl exec -n solr-kafka-ha zookeeper-0 -- echo ruok | nc localhost 2181
# Erwartet: "imok"

# ZooKeeper Mode anzeigen
kubectl exec -n solr-kafka-ha zookeeper-0 -- echo stat | nc localhost 2181 | grep Mode

# Alle ZooKeeper Nodes prüfen
for i in {0..2}; do
  echo "zookeeper-$i:" $(kubectl exec -n solr-kafka-ha zookeeper-$i -- echo ruok | nc localhost 2181)
done

# ZooKeeper CLI starten
kubectl exec -it zookeeper-0 -n solr-kafka-ha -- zkCli.sh

# In zkCli.sh:
ls /                    # Root-Verzeichnis auflisten
ls /brokers            # Kafka Broker anzeigen
ls /solr               # Solr Konfiguration anzeigen
get /zookeeper/quota   # Quota anzeigen anzeigen



🚀 KAFKA COMMANDS

# Topics auflisten
kubectl exec -n solr-kafka-ha kafka-0 -- \
  kafka-topics --bootstrap-server localhost:9092 --list

# Topic erstellen (HA-konform)
kubectl exec -n solr-kafka-ha kafka-0 -- \
  kafka-topics --bootstrap-server localhost:9092 \
  --create --topic test-topic \
  --partitions 3 --replication-factor 3

# Topic Details anzeigen
kubectl exec -n solr-kafka-ha kafka-0 -- \
  kafka-topics --bootstrap-server localhost:9092 \
  --describe --topic test-topic

# Nachrichten schreiben
kubectl exec -n solr-kafka-ha kafka-0 -- \
  kafka-console-producer --bootstrap-server localhost:9092 \
  --topic test-topic

# Nachrichten lesen
kubectl exec -n solr-kafka-ha kafka-0 -- \
  kafka-console-consumer --bootstrap-server localhost:9092 \
  --topic test-topic --from-beginning

# Broker API Version
kubectl exec -n solr-kafka-ha kafka-0 -- \
  kafka-broker-api-versions --bootstrap-server localhost:9092

# Consumer Groups
kubectl exec -n solr-kafka-ha kafka-0 -- \
  kafka-consumer-groups --bootstrap-server localhost:9092 --list

# Partitions Reassignment
kubectl exec -n solr-kafka-ha kafka-0 -- \
  kafka-reassign-partitions --bootstrap-server localhost:9092 \
  --reassignment-json-file reassign.json --execute



execute
🔍 SOLR COMMANDS
# Collection erstellen
kubectl exec -n solr-kafka-ha deployment/solr-standalone -- \
  solr create_collection -c test-collection -shards 2 -replicationFactor 3

# Collections auflisten
kubectl exec -n solr-kafka-ha deployment/solr-standalone -- \
  curl -s "http://localhost:8983/solr/admin/collections?action=LIST"

# Collection löschen
kubectl exec -n solr-kafka-ha deployment/solr-standalone -- \
  solr delete -c test-collection

# Cluster Status
curl "http://localhost:8983/solr/admin/collections?action=CLUSTERSTATUS"

# Node Health
curl "http://localhost:8983/solr/admin/cores?action=STATUS"

# System Info
curl "http://localhost:8983/solr/admin/info/system"

# Dokument indexieren
curl -X POST -H 'Content-Type: application/json' \
  'http://localhost:8983/solr/test-collection/update' \
  -d '[{"id":"1","title":"Test Document"}]'

# Suche durchführen
curl "http://localhost:8983/solr/test-collection/select?q=*:*"

# Commit durchführen
curl "http://localhost:8983/solr/test-collection/update?commit=true"

🔧 MAINTENANCE COMMANDS
# Komplette HA Prüfung
./scripts/test-ha-platform-complete.sh

# Einzelne Komponenten
./scripts/check-zookeeper.sh
./scripts/check-kafka.sh
./scripts/check-solr.sh

# Netzwerk Connectivity
./scripts/check-connectivity.sh

# ZooKeeper Backup
kubectl exec -n solr-kafka-ha zookeeper-0 -- zkServer.sh dump

# Kafka Topics exportieren
kubectl exec -n solr-kafka-ha kafka-0 -- \
  kafka-console-consumer --bootstrap-server localhost:9092 \
  --topic test-topic --from-beginning > backup.txt

# Solr Collection Backup
curl "http://localhost:8983/solr/admin/collections?action=BACKUP&name=backup1&collection=test-collection"

# Ressourcenverbrauch
kubectl top pods -n solr-kafka-ha

# Logs mit Filter
kubectl logs -l app=solr -n solr-kafka-ha --tail=100 | grep ERROR

# Events anzeigen
kubectl get events -n solr-kafka-ha --sort-by='.lastTimestamp'

# Solr skalieren
kubectl scale deployment solr-standalone --replicas=5 -n solr-kafka-ha

# HPA konfigurieren (wenn installiert)
kubectl autoscale deployment solr-standalone --cpu-percent=80 --min=3 --max=10 -n solr-kafka-ha



🐛 DEBUGGING COMMANDS
# DNS Resolution testen
kubectl run test-dns --image=busybox -it --rm --restart=Never \
  -- nslookup kafka-headless.solr-kafka-ha.svc.cluster.local

# Port Connectivity
kubectl exec -n solr-kafka-ha zookeeper-0 -- nc -zv kafka-0.kafka-headless 9092

# Service Discovery
kubectl get svc -n solr-kafka-ha
kubectl get endpoints -n solr-kafka-ha

# Kafka Performance
kubectl exec -n solr-kafka-ha kafka-0 -- \
  kafka-producer-perf-test --topic test-topic \
  --num-records 1000 --record-size 1000 \
  --throughput 100 --producer-props bootstrap.servers=localhost:9092

# Solr Performance
ab -n 1000 -c 10 "http://localhost:8983/solr/test-collection/select?q=*:*"



📊 STATUS COMMANDS
# All-in-One Status
echo "=== Cluster Status ==="
echo "Pods:" $(kubectl get pods -n solr-kafka-ha | grep -c Running)/9
echo "ZooKeeper:" $(kubectl exec -n solr-kafka-ha zookeeper-0 -- echo ruok | nc localhost 2181)
echo "Kafka:" $(kubectl exec -n solr-kafka-ha kafka-0 -- kafka-topics --bootstrap-server localhost:9092 --list 2>&1 | head -1)
echo "Solr:" $(curl -s http://localhost:8983/solr/admin/collections?action=CLUSTERSTATUS | jq -r '.cluster.live_nodes | length' 2>/dev/null || echo "?")

# Live Monitoring
watch -n 5 'kubectl get pods -n solr-kafka-ha'

# Log Monitoring
kubectl logs -f deployment/solr-standalone -n solr-kafka-ha

# Event Monitoring
kubectl get events -n solr-kafka-ha -w



🎯 PRODUCTION COMMANDS
# ZooKeeper Leader Failover
kubectl delete pod $(kubectl get pods -n solr-kafka-ha -l app=zookeeper | grep leader | awk '{print $1}')

# Kafka Broker Failover
kubectl delete pod kafka-1 -n solr-kafka-ha

# Recovery überwachen
watch -n 1 './scripts/health-check.sh'

# Complete Restart
kubectl delete pods --all -n solr-kafka-ha

# Namespace Reset (Achtung!)
kubectl delete namespace solr-kafka-ha
kubectl create namespace solr-kafka-ha
./scripts/deploy-ha-platform.sh



🔐 SECURITY COMMANDS
# Service Accounts
kubectl get serviceaccounts -n solr-kafka-ha

# RBAC Checks
kubectl auth can-i create pods --namespace solr-kafka-ha

# Secrets Management
kubectl get secrets -n solr-kafka-ha



💾 EXPORT/IMPORT
# All ConfigMaps
kubectl get configmaps -n solr-kafka-ha -o yaml > config-backup.yaml

# All Deployments
kubectl get deployments -n solr-kafka-ha -o yaml > deployments-backup.yaml

# Full Namespace Backup
kubectl get all -n solr-kafka-ha -o yaml > full-backup.yaml
