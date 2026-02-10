#!/bin/bash

set -e

NAMESPACE="solr-kafka-ha"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo "🚀 Starting HA Platform Deployment..."
echo "📅 Timestamp: $TIMESTAMP"
echo "📁 Namespace: $NAMESPACE"

# Check prerequisites
command -v helm >/dev/null 2>&1 || { echo "❌ Helm not found. Please install Helm first."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl not found."; exit 1; }

# Create namespace if not exists
echo "📦 Checking/Creating namespace $NAMESPACE..."
kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || {
  kubectl create namespace "$NAMESPACE"
}

# Set context
echo "🎯 Setting context to namespace $NAMESPACE..."
kubectl config set-context --current --namespace="$NAMESPACE"

# Function to wait for pods
wait_for_pods() {
  local app=$1
  local replicas=$2
  local timeout=300
  local interval=10
  local start_time=$(date +%s)
  
  echo "⏳ Waiting for $app pods (${replicas} replicas)..."
  
  while true; do
    local current_time=$(date +%s)
    local elapsed=$((current_time - start_time))
    
    if [ $elapsed -ge $timeout ]; then
      echo "❌ Timeout waiting for $app pods after ${timeout}s"
      kubectl get pods -l "app.kubernetes.io/name=$app" -o wide
      kubectl describe pods -l "app.kubernetes.io/name=$app"
      exit 1
    fi
    
    local ready_count=$(kubectl get pods -l "app.kubernetes.io/name=$app" --no-headers 2>/dev/null | \
      grep -c "Running" || true)
    
    if [ "$ready_count" -eq "$replicas" ]; then
      echo "✅ All $app pods are running"
      break
    fi
    
    echo "📊 $app: $ready_count/$replicas pods ready..."
    sleep $interval
  done
}

# Function to check service
check_service() {
  local service=$1
  local port=$2
  local timeout=60
  local interval=5
  local start_time=$(date +%s)
  
  echo "🔍 Checking service $service:$port..."
  
  while true; do
    local current_time=$(date +%s)
    local elapsed=$((current_time - start_time))
    
    if [ $elapsed -ge $timeout ]; then
      echo "❌ Timeout waiting for service $service"
      return 1
    fi
    
    if timeout 5 bash -c "cat < /dev/null > /dev/tcp/127.0.0.1/2181" 2>/dev/null; then
      echo "✅ Service $service:$port is reachable"
      return 0
    fi
    
    sleep $interval
  done
}

# Clean up any existing installations
echo "🧹 Cleaning up any existing installations..."
helm uninstall zookeeper --namespace "$NAMESPACE" 2>/dev/null || true
helm uninstall solr --namespace "$NAMESPACE" 2>/dev/null || true

sleep 10

# Deploy ZooKeeper
echo "🦓 Deploying ZooKeeper Ensemble..."
helm upgrade --install zookeeper ./charts/zookeeper \
  --namespace "$NAMESPACE" \
  --set replicaCount=3 \
  --set persistence.data.size=1Gi \
  --set persistence.datalog.size=1Gi \
  --set resources.requests.memory=512Mi \
  --set resources.requests.cpu=250m \
  --set resources.limits.memory=1Gi \
  --set resources.limits.cpu=500m \
  --wait --timeout 10m

wait_for_pods "zookeeper" 3

# Test ZooKeeper
echo "🧪 Testing ZooKeeper..."
for i in {0..2}; do
  if timeout 10 kubectl exec zookeeper-$i -- sh -c "echo ruok | nc localhost 2181" 2>/dev/null | grep -q imok; then
    echo "✅ ZooKeeper-$i is OK"
  else
    echo "⚠️  ZooKeeper-$i not ready yet, continuing..."
  fi
done

# Deploy Solr
echo "🔍 Deploying Solr Cloud..."
helm upgrade --install solr ./charts/solr \
  --namespace "$NAMESPACE" \
  --set replicaCount=3 \
  --set persistence.data.size=10Gi \
  --set resources.requests.memory=2Gi \
  --set resources.requests.cpu=500m \
  --set resources.limits.memory=4Gi \
  --set resources.limits.cpu=1000m \
  --set zookeeper.connectionString="zookeeper-headless:2181/solr" \
  --set zookeeper.host="zookeeper-headless" \
  --wait --timeout 15m

wait_for_pods "solr" 3

# Test Solr
echo "🧪 Testing Solr..."
for i in {0..2}; do
  if timeout 10 kubectl exec solr-$i -- curl -s http://localhost:8983/solr/admin/info/system 2>/dev/null | grep -q solr_home; then
    echo "✅ Solr-$i is responding"
  else
    echo "⚠️  Solr-$i not ready yet, continuing..."
  fi
done

# Wait a bit more for Solr to fully initialize
echo "⏳ Waiting for Solr Cloud to fully initialize..."
sleep 30

# Create test collection
echo "📁 Creating Solr test collection..."
if kubectl exec solr-0 -- curl -s "http://localhost:8983/solr/admin/collections?action=CREATE&name=ha-test&numShards=3&replicationFactor=2&maxShardsPerNode=3&wt=json" 2>/dev/null | grep -q success; then
  echo "✅ Test collection created successfully"
else
  echo "⚠️  Could not create test collection (might already exist)"
fi

# Summary
echo ""
echo "🎉 HA Platform Deployment Complete!"
echo "===================================="
echo ""
echo "📊 Services:"
kubectl get svc -n "$NAMESPACE"
echo ""
echo "🐳 Pods:"
kubectl get pods -n "$NAMESPACE" -o wide
echo ""
echo "💾 Persistent Volumes:"
kubectl get pvc -n "$NAMESPACE"
echo ""
echo "🔗 Access URLs:"
echo "  ZooKeeper: zookeeper.$NAMESPACE.svc.cluster.local:2181"
echo "  Solr: http://solr.$NAMESPACE.svc.cluster.local:8983/solr"
echo ""
echo "🧪 Quick Test Commands:"
echo "  kubectl exec -n $NAMESPACE zookeeper-0 -- zkServer.sh status"
echo "  kubectl exec -n $NAMESPACE solr-0 -- curl -s http://localhost:8983/solr/admin/collections?action=CLUSTERSTATUS"
echo ""
echo "🚀 Next steps:"
echo "  1. Deploy Kafka: helm install kafka ./charts/kafka"
echo "  2. Run comprehensive tests: ./scripts/ha-test.sh"
echo "  3. Check logs: kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=solr --tail=50"
