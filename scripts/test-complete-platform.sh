#!/bin/bash
# test-complete-platform.sh

NAMESPACE="solr-kafka-simple"

echo "🧪 VOLLSTÄNDIGER PLATFORM TEST"
echo "=============================="

# 1. Alle Services testen
echo ""
echo "1️⃣  SERVICE CONNECTIVITY:"

services=(
  "zookeeper:2181"
  "kafka:9092" 
  "solr:8983"
)

for svc in "${services[@]}"; do
  name=${svc%:*}
  port=${svc#*:}
  
  echo -n "   $name:$port ... "
  if kubectl run netcheck --namespace "$NAMESPACE" \
    --image=busybox:1.35 --restart=Never --rm -i --quiet -- \
    timeout 2 nc -zv $name $port 2>&1 | grep -q "succeeded"; then
    echo "✅ OK"
  else
    echo "❌ FAILED"
  fi
done

# 2. Kafka Funktionalität testen
echo ""
echo "2️⃣  KAFKA FUNCTIONALITY:"

echo -n "   Create test topic ... "
kubectl exec -n "$NAMESPACE" deployment/kafka -- \
  sh -c '/opt/kafka/bin/kafka-topics.sh --create --topic platform-test --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1 2>/dev/null && echo "✅ Created" || echo "⚠️ May exist"'

echo -n "   List topics ... "
kubectl exec -n "$NAMESPACE" deployment/kafka -- \
  sh -c '/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null'

# 3. ZooKeeper Status
echo ""
echo "3️⃣  ZOOKEEPER STATUS:"
kubectl exec -n "$NAMESPACE" deployment/zookeeper -- \
  sh -c 'echo stat | nc localhost 2181 2>/dev/null | grep -E "(Mode|Clients|Received|Sent)" | head -5'

# 4. Solr Status
echo ""
echo "4️⃣  SOLR STATUS:"
echo -n "   HTTP API ... "
if kubectl exec -n "$NAMESPACE" deployment/solr -- \
  curl -s http://localhost:8983/solr/admin/cores 2>/dev/null | grep -q "status"; then
  echo "✅ OK"
else
  echo "❌ FAILED"
fi

# 5. Kafka Logs prüfen (keine Fehler)
echo ""
echo "5️⃣  KAFKA HEALTH CHECK:"
echo -n "   Recent logs (errors?) ... "
if kubectl logs -n "$NAMESPACE" -l app=kafka --tail=5 2>/dev/null | grep -q -i "error\|exception\|failed"; then
  echo "⚠️  Warnings found"
  kubectl logs -n "$NAMESPACE" -l app=kafka --tail=3
else
  echo "✅ No errors"
fi

# 6. Finaler Status
echo ""
echo "📊 FINALER PLATTFORM STATUS:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
kubectl get pods -n "$NAMESPACE" -o custom-columns="NAME:.metadata.name,STATUS:.status.phase,READY:.status.containerStatuses[*].ready,RESTARTS:.status.containerStatuses[*].restartCount,AGE:.metadata.creationTimestamp"
