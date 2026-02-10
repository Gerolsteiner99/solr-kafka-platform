#!/bin/bash
echo "=== Quick Platform Test ==="
echo ""

echo "1. Current Status:"
kubectl get pods -l 'app in (solr,kafka,zookeeper)'

echo ""
echo "2. Quick Connectivity Check:"
echo -n "  Zookeeper (2181): "
kubectl run quick-test-zk-$(date +%s) --image=busybox:1.35 --restart=Never --rm -i --command -- \
  sh -c 'timeout 3 nc -z zookeeper 2181 && echo "✅ OK" || echo "❌ Failed"' 2>/dev/null || echo "Test failed"

echo -n "  Kafka (9092): "
kubectl run quick-test-kafka-$(date +%s) --image=busybox:1.35 --restart=Never --rm -i --command -- \
  sh -c 'timeout 3 nc -z kafka 9092 && echo "✅ OK" || echo "❌ Failed"' 2>/dev/null || echo "Test failed"

echo -n "  Solr (8983): "
kubectl run quick-test-solr-$(date +%s) --image=busybox:1.35 --restart=Never --rm -i --command -- \
  sh -c 'timeout 3 nc -z solr 8983 && echo "✅ OK" || echo "❌ Failed"' 2>/dev/null || echo "Test failed"

echo ""
echo "3. Component Logs (last line):"
echo -n "  Zookeeper: "
kubectl logs -l app=zookeeper --tail=1 2>/dev/null | tail -1 || echo "No logs"

echo -n "  Kafka: "
kubectl logs -l app=kafka --tail=1 2>/dev/null | tail -1 || echo "No logs"

echo -n "  Solr: "
kubectl logs -l app=solr --tail=1 2>/dev/null | tail -1 || echo "No logs"

echo ""
echo "=== Test Complete ==="
echo ""
echo "If all services show '✅ OK', the platform is ready!"
echo "Run './test-final-platform.sh' for detailed test."
