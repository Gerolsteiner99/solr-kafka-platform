#!/bin/bash
echo "=== Quick Platform Test ==="
echo ""

# Check pods
echo "1. Checking Pods:"
kubectl get pods -l 'app in (solr,kafka,zookeeper,health-dashboard)' --no-headers | while read line; do
  POD=$(echo $line | awk '{print $1}')
  STATUS=$(echo $line | awk '{print $3}')
  READY=$(echo $line | awk '{print $2}')
  echo "   $POD: $STATUS ($READY)"
done

echo ""
echo "2. Testing Network:"
TEST_POD=$(kubectl run quick-test-$(date +%s) --image=busybox:1.35 --restart=Never --rm -i --command -- sh -c "
  echo -n 'Solr:8983 -> '; timeout 2 nc -z solr 8983 && echo 'OK' || echo 'FAIL'
  echo -n 'Kafka:9092 -> '; timeout 2 nc -z kafka 9092 && echo 'OK' || echo 'FAIL'
  echo -n 'Zookeeper:2181 -> '; timeout 2 nc -z zookeeper 2181 && echo 'OK' || echo 'FAIL'
" 2>/dev/null)
echo "$TEST_POD"

echo ""
echo "3. Local Access:"
echo "   Dashboard: http://localhost:8080"
echo "   Solr:      http://localhost:8983"
echo ""
echo "✅ Platform test completed"
