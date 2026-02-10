#!/bin/bash
# clean-update.sh

echo "=== Clean Update ==="

# Keep PVCs but delete StatefulSets
echo "Deleting StatefulSets..."
kubectl delete statefulset kafka -n solr-kafka-platform 2>/dev/null || true
kubectl delete statefulset solr -n solr-kafka-platform 2>/dev/null || true
kubectl delete statefulset zookeeper -n solr-kafka-platform 2>/dev/null || true

# Wait for pods to terminate
echo "Waiting for pods to terminate..."
sleep 10

# Now do helm upgrade
echo "Running helm upgrade..."
helm upgrade --install solr-kafka-platform . \
  -n solr-kafka-platform \
  --force  # Force recreation

echo "Checking status..."
kubectl get pods -n solr-kafka-platform -w
