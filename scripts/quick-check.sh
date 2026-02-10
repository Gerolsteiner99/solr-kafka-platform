#!/bin/bash
# quick-check.sh

echo "=== Quick Status Check ==="
echo ""
echo "1. All pods:"
kubectl get pods -n solr-kafka-platform
echo ""
echo "2. SolR logs (last 5 lines):"
kubectl logs solr-0 -n solr-kafka-platform --tail=5 2>/dev/null || echo "No logs"
echo ""
echo "3. Container processes:"
kubectl exec -it solr-0 -n solr-kafka-platform -- ps aux 2>/dev/null || echo "Cannot exec into container"
echo ""
echo "4. Events:"
kubectl get events -n solr-kafka-platform --field-selector involvedObject.name=solr-0 --sort-by=.lastTimestamp 2>/dev/null | tail -5
EOF

chmod +x quick-check.sh
./quick-check.sh
