#!/bin/bash

NAMESPACE="solr-kafka-platform"

echo "1. Creating namespace if not exists..."
kubectl create namespace $NAMESPACE 2>/dev/null || true

echo "2. Installing Zookeeper Cluster..."
helm upgrade --install zookeeper ./charts/zookeeper -n $NAMESPACE

echo "3. Waiting for Zookeeper to be ready..."
sleep 10
kubectl wait --for=condition=ready pod -l app=zookeeper -n $NAMESPACE --timeout=300s

echo "4. Checking Zookeeper cluster status..."
kubectl exec zookeeper-0 -n $NAMESPACE -- zkServer.sh status

echo "5. Installing Kafka Cluster..."
helm upgrade --install kafka ./charts/kafka -n $NAMESPACE

echo "6. Waiting for Kafka to be ready..."
sleep 10
kubectl wait --for=condition=ready pod -l app=kafka -n $NAMESPACE --timeout=300s

echo "7. Installing Solr Cluster..."
helm upgrade --install solr ./charts/solr -n $NAMESPACE

echo "8. Waiting for Solr to be ready..."
sleep 10
kubectl wait --for=condition=ready pod -l app=solr -n $NAMESPACE --timeout=300s

echo "9. Deployment complete!"
echo ""
echo "Services:"
kubectl get svc -n $NAMESPACE
echo ""
echo "Pods:"
kubectl get pods -n $NAMESPACE
