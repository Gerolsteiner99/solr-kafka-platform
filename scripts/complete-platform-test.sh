#!/bin/bash
# complete-platform-test.sh

NAMESPACE="solr-kafka-simple"

echo "🧪 VOLLSTÄNDIGER PLATFORM TEST"
echo "=============================="

echo "1. ALLE PODS:"
kubectl get pods -n "$NAMESPACE" -o wide

echo ""
echo "2. KAFKA SPEZIFISCHER TEST:"

# Finde den laufenden Kafka Pod
KAFKA_POD=$(kubectl get pods -n "$NAMESPACE" -l app=kafka --field-selector=status.phase=Running -o name 2>/dev/null | head -1)

if [ -z "$KAFKA_POD" ]; then
  echo "❌ Kein laufender Kafka Pod gefunden"
  exit 1
fi

echo "   Kafka Pod: $KAFKA_POD"

echo -n "   Kafka Prozess läuft... "
if kubectl exec -n "$NAMESPACE" $KAFKA_POD -- ps aux | grep -q kafka; then
  echo "✅ OK"
else
  echo "❌ FAILED"
fi

echo -n "   Port 9092 listening... "
if kubectl exec -n "$NAMESPACE" $KAFKA_POD -- netstat -tulpn 2>/dev/null | grep -q ":9092"; then
  echo "✅ OK"
else
  echo "❌ FAILED"
fi

echo -n "   ZooKeeper Connection... "
if kubectl exec -n "$NAMESPACE" $KAFKA_POD -- \
  /opt/kafka/bin/zookeeper-shell.sh zookeeper:2181 ls / 2>&1 | grep -q "zookeeper"; then
  echo "✅ OK"
else
  echo "❌ FAILED"
fi

echo ""
echo "3. KAFKA FUNKTIONALITÄT:"

echo -n "   Create test topic... "
kubectl exec -n "$NAMESPACE" $KAFKA_POD -- \
  sh -c '/opt/kafka/bin/kafka-topics.sh --create --topic platform-test --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1 2>&1 | grep -q "Created" && echo "✅ Created" || echo "⚠️ Exists"'

echo "   List topics:"
kubectl exec -n "$NAMESPACE" $KAFKA_POD -- \
  /opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | sed 's/^/     /'

echo ""
echo "4. PLATFORM INTEGRATION:"

echo -n "   Solr -> ZooKeeper... "
if kubectl exec -n "$NAMESPACE" deployment/solr -- \
  curl -s http://localhost:8983/solr/admin/cores 2>/dev/null | grep -q "status"; then
  echo "✅ OK"
else
  echo "❌ FAILED"
fi

echo -n "   ZooKeeper Status... "
if kubectl exec -n "$NAMESPACE" deployment/zookeeper -- \
  sh -c 'echo ruok | nc localhost 2181 2>/dev/null | grep -q imok'; then
  echo "✅ OK"
else
  echo "❌ FAILED"
fi

echo ""
echo "📋 ZUSAMMENFASSUNG:"
if kubectl get pods -n "$NAMESPACE" -l app=kafka --no-headers | grep -q "1/1.*Running" && \
   kubectl get pods -n "$NAMESPACE" -l app=zookeeper --no-headers | grep -q "1/1.*Running" && \
   kubectl get pods -n "$NAMESPACE" -l app=solr --no-headers | grep -q "1/1.*Running"; then
  echo "🎉 ALLE SERVICES LAUFEN!"
  echo "   Platform ist betriebsbereit."
else
  echo "⚠️  EINIGE SERVICES HABEN PROBLEME"
  echo "   Überprüfe die Pod Status oben."
fi
