#!/bin/bash

set -e

NAMESPACE="solr-kafka-ha"

echo "🚀 FINAL HA Platform Deployment..."
echo "📁 Namespace: $NAMESPACE"

# Clean and create namespace
kubectl delete namespace "$NAMESPACE" --ignore-not-found=true --wait=false
sleep 3
while kubectl get namespace "$NAMESPACE" &>/dev/null; do sleep 1; done
kubectl create namespace "$NAMESPACE"
kubectl config set-context --current --namespace="$NAMESPACE"

# 1. Deploy ZooKeeper (Standalone for testing)
echo "🦓 Deploying ZooKeeper (Standalone mode)..."
cat << 'EOF' | kubectl apply -n "$NAMESPACE" -f -
apiVersion: v1
kind: Service
metadata:
  name: zookeeper
  labels:
    app: zookeeper
spec:
  ports:
  - port: 2181
    targetPort: 2181
    name: client
  selector:
    app: zookeeper
---
apiVersion: v1
kind: Service
metadata:
  name: zookeeper-headless
  labels:
    app: zookeeper
spec:
  clusterIP: None
  ports:
  - port: 2181
    name: client
  selector:
    app: zookeeper
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: zookeeper
  labels:
    app: zookeeper
spec:
  serviceName: zookeeper-headless
  replicas: 1
  selector:
    matchLabels:
      app: zookeeper
  template:
    metadata:
      labels:
        app: zookeeper
    spec:
      initContainers:
      - name: init-myid
        image: busybox:1.35
        command: ["sh", "-c", "echo 1 > /data/myid"]
        volumeMounts:
        - name: data
          mountPath: /data
      containers:
      - name: zookeeper
        image: docker.io/library/zookeeper:3.9.4
        ports:
        - containerPort: 2181
          name: client
        env:
        - name: ZOO_MY_ID
          value: "1"
        - name: ZOO_STANDALONE_ENABLED
          value: "true"
        - name: ZOO_4LW_COMMANDS_WHITELIST
          value: "*"
        volumeMounts:
        - name: data
          mountPath: /data
        livenessProbe:
          tcpSocket:
            port: 2181
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          tcpSocket:
            port: 2181
          initialDelaySeconds: 20
          periodSeconds: 5
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
EOF

echo "⏳ Waiting for ZooKeeper..."
sleep 15

# Test ZooKeeper
echo "🔍 Testing ZooKeeper..."
for i in {1..10}; do
  if kubectl get pod zookeeper-0 -o jsonpath='{.status.phase}' 2>/dev/null | grep -q Running; then
    echo "✅ ZooKeeper pod is Running"
    
    # Simple test - just check if port is open
    if kubectl exec zookeeper-0 -- timeout 3 bash -c "echo > /dev/tcp/localhost/2181" 2>/dev/null; then
      echo "✅ ZooKeeper port 2181 is open"
      break
    fi
  fi
  sleep 3
done

# 2. Deploy Solr
echo ""
echo "🔍 Deploying Solr Cloud..."
cat << 'EOF' | kubectl apply -n "$NAMESPACE" -f -
apiVersion: v1
kind: Service
metadata:
  name: solr
  labels:
    app: solr
spec:
  ports:
  - port: 8983
    targetPort: 8983
    name: http
  selector:
    app: solr
---
apiVersion: v1
kind: Service
metadata:
  name: solr-headless
  labels:
    app: solr
spec:
  clusterIP: None
  ports:
  - port: 8983
    name: http
  selector:
    app: solr
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: solr
  labels:
    app: solr
spec:
  serviceName: solr-headless
  replicas: 1
  selector:
    matchLabels:
      app: solr
  template:
    metadata:
      labels:
        app: solr
    spec:
      initContainers:
      - name: init-chmod
        image: busybox:1.35
        command: ["sh", "-c", "chown -R 8983:8983 /var/solr"]
        securityContext:
          runAsUser: 0
        volumeMounts:
        - name: solr-data
          mountPath: /var/solr
      containers:
      - name: solr
        image: docker.io/library/solr:9.4.1
        ports:
        - containerPort: 8983
          name: http
        env:
        - name: ZK_HOST
          value: "zookeeper:2181"
        command:
        - bash
        - -c
        - |
          # Start Solr in cloud mode
          exec docker-entrypoint.sh solr start -f -c -z "$ZK_HOST" -p 8983
        volumeMounts:
        - name: solr-data
          mountPath: /var/solr
        livenessProbe:
          httpGet:
            path: /solr
            port: 8983
          initialDelaySeconds: 90
          periodSeconds: 30
          timeoutSeconds: 10
        readinessProbe:
          httpGet:
            path: /solr
            port: 8983
          initialDelaySeconds: 60
          periodSeconds: 10
          timeoutSeconds: 5
  volumeClaimTemplates:
  - metadata:
      name: solr-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
EOF

echo "⏳ Waiting for Solr (this takes 2-3 minutes)..."
sleep 30

# Monitor Solr startup
echo "📈 Monitoring Solr startup..."
for i in {1..40}; do
  if kubectl get pod solr-0 -o jsonpath='{.status.phase}' 2>/dev/null | grep -q Running; then
    echo "✅ Solr pod is Running"
    
    # Check logs for successful startup
    if kubectl logs solr-0 --tail=5 2>/dev/null | grep -q "Started Solr"; then
      echo "✅ Solr started successfully"
      break
    fi
  fi
  echo -n "."
  sleep 5
done

echo ""
echo "📊 Deployment Status:"
kubectl get all -n "$NAMESPACE"

echo ""
echo "📝 Checking logs..."
kubectl logs solr-0 --tail=20 2>/dev/null | grep -E "(Started|ERROR|WARN|INFO.*8983)" || echo "Waiting for Solr logs..."

echo ""
echo "🧪 Testing connectivity..."
if kubectl exec solr-0 -- timeout 5 curl -s http://localhost:8983/solr >/dev/null 2>&1; then
  echo "✅ Solr is responding!"
  echo "🔗 Solr Admin: http://solr.$NAMESPACE.svc.cluster.local:8983/solr"
else
  echo "⚠️  Solr not responding yet, checking..."
  kubectl logs solr-0 --tail=30 2>/dev/null || echo "No logs yet"
fi

echo ""
echo "🎉 Platform deployed!"
echo ""
echo "🚀 Next: Scale to HA with 3 replicas:"
echo "   kubectl scale statefulset zookeeper --replicas=3"
echo "   kubectl scale statefulset solr --replicas=3"
echo ""
echo "📋 Troubleshooting:"
echo "   kubectl describe pod zookeeper-0"
echo "   kubectl describe pod solr-0"
echo "   kubectl get events --sort-by='.lastTimestamp'"
