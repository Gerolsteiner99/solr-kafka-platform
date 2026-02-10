#!/bin/bash

NAMESPACE="solr-kafka-platform"

echo "========================================="
echo "CLEAN DEPLOY - Starting Fresh"
echo "========================================="

echo "1. Removing ALL existing resources..."
helm uninstall solr-kafka-platform -n $NAMESPACE 2>/dev/null || echo "No umbrella release found"
helm uninstall zookeeper -n $NAMESPACE 2>/dev/null || echo "No zookeeper release found"
helm uninstall kafka -n $NAMESPACE 2>/dev/null || echo "No kafka release found"
helm uninstall solr -n $NAMESPACE 2>/dev/null || echo "No solr release found"

echo "2. Deleting orphaned resources..."
kubectl delete statefulset,deployment,service,configmap,pvc -l "app in (zookeeper,kafka,solr)" -n $NAMESPACE 2>/dev/null || true

# Einzelne Services löschen (falls ohne Labels)
kubectl delete service zookeeper-service kafka-service solr-service -n $NAMESPACE 2>/dev/null || true

echo "3. Deleting all PVCs..."
kubectl delete pvc -n $NAMESPACE --all 2>/dev/null || true

echo "4. Waiting for cleanup..."
sleep 10

echo "5. Creating fresh namespace..."
kubectl delete namespace $NAMESPACE 2>/dev/null || true
kubectl create namespace $NAMESPACE

echo "6. Installing Zookeeper Cluster..."
helm upgrade --install zookeeper ./charts/zookeeper -n $NAMESPACE --wait --timeout 5m

echo "7. Checking Zookeeper..."
kubectl get pods -n $NAMESPACE -l app=zookeeper
echo "Waiting for Zookeeper to form cluster..."
for i in {1..30}; do
  READY=$(kubectl get pods -n $NAMESPACE -l app=zookeeper -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' | grep -c True)
  if [ "$READY" -eq 3 ]; then
    echo "✓ All Zookeeper pods ready"
    kubectl exec zookeeper-0 -n $NAMESPACE -- zkServer.sh status
    break
  fi
  echo "Waiting... ($READY/3 ready)"
  sleep 10
done

echo "8. Installing Kafka Cluster..."
helm upgrade --install kafka ./charts/kafka -n $NAMESPACE --wait --timeout 5m

echo "9. Checking Kafka..."
kubectl get pods -n $NAMESPACE -l app=kafka
for i in {1..30}; do
  READY=$(kubectl get pods -n $NAMESPACE -l app=kafka -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' | grep -c True)
  if [ "$READY" -eq 3 ]; then
    echo "✓ All Kafka pods ready"
    break
  fi
  echo "Waiting... ($READY/3 ready)"
  sleep 10
done

echo "10. Installing Solr Cluster..."
helm upgrade --install solr ./charts/solr -n $NAMESPACE --wait --timeout 5m

echo "11. Checking Solr..."
kubectl get pods -n $NAMESPACE -l app=solr
for i in {1..30}; do
  READY=$(kubectl get pods -n $NAMESPACE -l app=solr -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' | grep -c True)
  if [ "$READY" -eq 3 ]; then
    echo "✓ All Solr pods ready"
    break
  fi
  echo "Waiting... ($READY/3 ready)"
  sleep 10
done

echo "========================================="
echo "DEPLOYMENT COMPLETE!"
echo "========================================="
kubectl get all -n $NAMESPACE
