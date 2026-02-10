#!/bin/bash
echo "=== Cleaning up Solr-Kafka Platform ==="

# Stop port forwarding
pkill -f "kubectl port-forward" 2>/dev/null || true

# Delete all resources
kubectl delete deployment solr kafka zookeeper health-dashboard kafka-solr-demo 2>/dev/null || true
kubectl delete service solr kafka zookeeper health-dashboard 2>/dev/null || true
kubectl delete job integration-test 2>/dev/null || true
kubectl delete configmap solr-dependencies health-dashboard kafka-solr-demo 2>/dev/null || true
kubectl delete pod network-tester 2>/dev/null || true
kubectl delete job solr-cloud-setup 2>/dev/null || true
kubectl delete configmap solr-cloud-config 2>/dev/null || true

echo "Cleanup completed!"
