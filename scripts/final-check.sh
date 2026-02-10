#!/bin/bash
echo "=== FINAL PLATFORM CHECK ==="
echo ""

echo "1. All Pods:"
kubectl get pods -l 'app in (solr,kafka,zookeeper)'

echo ""
echo "2. Testing Services:"
echo "   Zookeeper:"
kubectl exec deployment/zookeeper -- zkServer.sh status 2>/dev/null && echo "   ✅ Zookeeper healthy" || echo "   ❌ Zookeeper issue"

echo ""
echo "   Kafka:"
KAFKA_POD=$(kubectl get pod -l app=kafka -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [[ -n "$KAFKA_POD" ]]; then
  kubectl exec $KAFKA_POD -- kafka-topics.sh --bootstrap-server localhost:9092 --list 2>/dev/null && echo "   ✅ Kafka responding" || echo "   ⏳ Kafka starting..."
fi

echo ""
echo "   Solr:"
SOLR_POD=$(kubectl get pod -l app=solr -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [[ -n "$SOLR_POD" ]]; then
  kubectl exec $SOLR_POD -- curl -s http://localhost:8983/solr/admin/cores 2>/dev/null | grep -q "status" && echo "   ✅ Solr responding" || echo "   ⏳ Solr starting..."
fi

echo ""
echo "3. Quick Network Test:"
kubectl run network-test-$(date +%s) --image=busybox:1.35 --restart=Never --rm -i --command -- \
  sh -c 'for svc in zookeeper:2181 kafka:9092 solr:8983; do name=${svc%:*}; port=${svc#*:}; echo -n "$name:$port -> "; timeout 2 nc -z $name $port && echo "OK" || echo "FAIL"; done'

echo ""
echo "=== CHECK COMPLETE ==="
echo ""
echo "If Kafka and Solr show '✅ responding', platform is READY!"
echo "Otherwise, wait 1-2 more minutes and run this script again."
