#!/bin/bash
echo "=== FINAL PLATFORM TEST ==="
echo ""

echo "1. Pod Status:"
echo "----------------"
kubectl get pods -l 'app in (solr,kafka,zookeeper)' --no-headers | while read line; do
  POD=$(echo $line | awk '{print $1}')
  STATUS=$(echo $line | awk '{print $3}')
  READY=$(echo $line | awk '{print $2}')
  echo "  $POD: $STATUS ($READY)"
done

echo ""
echo "2. Service Discovery:"
echo "---------------------"
kubectl run test-dns-$(date +%s) --image=busybox:1.35 --restart=Never --rm -i --command -- \
  sh -c 'nslookup zookeeper && nslookup kafka && nslookup solr && echo "✅ All DNS records found"'

echo ""
echo "3. Port Connectivity:"
echo "---------------------"
echo -n "  Zookeeper 2181: "
kubectl run test-port-zk-$(date +%s) --image=busybox:1.35 --restart=Never --rm -i --command -- \
  sh -c 'timeout 3 nc -z zookeeper 2181 && echo "✅ OK" || echo "❌ Failed"'

echo -n "  Kafka 9092: "
kubectl run test-port-kafka-$(date +%s) --image=busybox:1.35 --restart=Never --rm -i --command -- \
  sh -c 'timeout 3 nc -z kafka 9092 && echo "✅ OK" || echo "❌ Failed"'

echo -n "  Solr 8983: "
kubectl run test-port-solr-$(date +%s) --image=busybox:1.35 --restart=Never --rm -i --command -- \
  sh -c 'timeout 3 nc -z solr 8983 && echo "✅ OK" || echo "❌ Failed"'

echo ""
echo "4. Component Health:"
echo "--------------------"
echo -n "  Zookeeper: "
kubectl logs -l app=zookeeper --tail=1 2>/dev/null | grep -i "started\|ready" && echo "✅ Healthy" || echo "⚠️  Starting..."

echo -n "  Kafka: "
kubectl logs -l app=kafka --tail=1 2>/dev/null | grep -i "started\|ready" && echo "✅ Healthy" || echo "⚠️  Starting..."

echo -n "  Solr: "
SOLR_POD=$(kubectl get pod -l app=solr -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [[ -n "$SOLR_POD" ]]; then
  kubectl exec $SOLR_POD -- curl -s http://localhost:8983/solr/admin/cores 2>/dev/null | grep -q "status" && echo "✅ Healthy" || echo "⚠️  Starting..."
else
  echo "❌ Pod not found"
fi

echo ""
echo "=== TEST COMPLETE ==="
echo ""
echo "✅ If all services show 'OK', platform is ready!"
echo "🌐 Access:"
echo "   Solr UI:    kubectl port-forward service/solr 8983:8983"
echo "   Dashboard:  kubectl port-forward service/health-dashboard 8080:80"
