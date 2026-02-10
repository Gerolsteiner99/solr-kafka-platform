#!/bin/bash

set -e

NAMESPACE="solr-kafka-ha"

echo "🚀 Starting Complete HA Platform Deployment..."
echo "📁 Namespace: $NAMESPACE"

# Create namespace if not exists
kubectl create namespace "$NAMESPACE" 2>/dev/null || true
kubectl config set-context --current --namespace="$NAMESPACE"

# Clean up any existing resources
echo "🧹 Cleaning up existing resources..."
kubectl delete statefulset,deployment,service,pvc,configmap -l app=zookeeper -n "$NAMESPACE" --ignore-not-found=true
kubectl delete statefulset,deployment,service,pvc,configmap -l app=solr -n "$NAMESPACE" --ignore-not-found=true
sleep 3

# 1. Deploy ZooKeeper as StatefulSet with correct configuration
echo "🦓 Deploying ZooKeeper Ensemble..."
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
  publishNotReadyAddresses: true
  ports:
  - port: 2181
    name: client
  - port: 2888
    name: server
  - port: 3888
    name: leader-election
  selector:
    app: zookeeper
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: zookeeper-config
  labels:
    app: zookeeper
data:
  zoo.cfg: |
    tickTime=2000
    initLimit=10
    syncLimit=5
    dataDir=/data
    dataLogDir=/datalog
    maxClientCnxns=60
    standaloneEnabled=false
    admin.enableServer=false
    clientPort=2181
    quorumListenOnAllIPs=true
    4lw.commands.whitelist=*
    server.1=zookeeper-0.zookeeper-headless:2888:3888
    server.2=zookeeper-1.zookeeper-headless:2888:3888
    server.3=zookeeper-2.zookeeper-headless:2888:3888
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
      terminationGracePeriodSeconds: 60
      initContainers:
      - name: init-myid
        image: busybox:1.35
        command:
        - sh
        - -c
        - |
          # Create myid based on pod ordinal
          POD_ORDINAL=$(echo $HOSTNAME | sed 's/.*-//')
          MY_ID=$((POD_ORDINAL + 1))
          echo $MY_ID > /data/myid
          echo "Created myid: $MY_ID for pod $HOSTNAME"
        volumeMounts:
        - name: data
          mountPath: /data
      containers:
      - name: zookeeper
        image: docker.io/library/zookeeper:3.9.4
        ports:
        - containerPort: 2181
          name: client
        - containerPort: 2888
          name: server
        - containerPort: 3888
          name: leader-election
        env:
        - name: ZOO_MY_ID
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: ZOO_SERVERS
          value: "server.1=zookeeper-0.zookeeper-headless:2888:3888 server.2=zookeeper-1.zookeeper-headless:2888:3888 server.3=zookeeper-2.zookeeper-headless:2888:3888"
        - name: ZOO_TICK_TIME
          value: "2000"
        - name: ZOO_INIT_LIMIT
          value: "10"
        - name: ZOO_SYNC_LIMIT
          value: "5"
        - name: ZOO_MAX_CLIENT_CNXNS
          value: "60"
        - name: ZOO_STANDALONE_ENABLED
          value: "false"
        - name: ZOO_ADMINSERVER_ENABLED
          value: "false"
        - name: ZOO_4LW_COMMANDS_WHITELIST
          value: "*"
        volumeMounts:
        - name: data
          mountPath: /data
        - name: datalog
          mountPath: /datalog
        livenessProbe:
          exec:
            command:
            - sh
            - -c
            - "echo ruok | nc localhost 2181 | grep imok"
          initialDelaySeconds: 30
          periodSeconds: 15
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          exec:
            command:
            - sh
            - -c
            - "echo ruok | nc localhost 2181 | grep imok"
          initialDelaySeconds: 20
          periodSeconds: 10
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 3
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
  - metadata:
      name: datalog
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
EOF

echo "⏳ Waiting for ZooKeeper to start..."
sleep 20

# Check ZooKeeper
echo "🔍 Checking ZooKeeper..."
for i in {1..20}; do
  if kubectl get pod zookeeper-0 -o jsonpath='{.status.phase}' 2>/dev/null | grep -q Running; then
    echo "✅ ZooKeeper pod is Running"
    
    # Test ZooKeeper
    if kubectl exec zookeeper-0 -- sh -c "echo ruok | nc localhost 2181" 2>/dev/null | grep -q imok; then
      echo "✅ ZooKeeper is responding"
      break
    fi
  fi
  echo -n "."
  sleep 5
done

# Show ZooKeeper logs if not working
if ! kubectl exec zookeeper-0 -- sh -c "echo ruok | nc localhost 2181" 2>/dev/null | grep -q imok; then
  echo "⚠️  ZooKeeper not responding, checking logs..."
  kubectl logs zookeeper-0 --tail=20
fi

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
  publishNotReadyAddresses: true
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
      terminationGracePeriodSeconds: 120
      initContainers:
      - name: init-chmod
        image: busybox:1.35
        command: ["sh", "-c", "chown -R 8983:8983 /var/solr && chmod 755 /var/solr"]
        securityContext:
          runAsUser: 0
        volumeMounts:
        - name: solr-data
          mountPath: /var/solr
      - name: wait-for-zookeeper
        image: busybox:1.35
        command: ['sh', '-c', 'until nslookup zookeeper-headless; do echo waiting for ZooKeeper DNS; sleep 2; done']
      containers:
      - name: solr
        image: docker.io/library/solr:9.4.1
        ports:
        - containerPort: 8983
          name: http
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: SOLR_HOST
          value: "$(POD_NAME).solr-headless.$(NAMESPACE).svc.cluster.local"
        - name: SOLR_PORT
          value: "8983"
        - name: ZK_HOST
          value: "zookeeper-headless:2181/solr"
        - name: SOLR_JAVA_MEM
          value: "-Xms1g -Xmx2g"
        command:
        - docker-entrypoint.sh
        args:
        - solr
        - start
        - -f
        - -c
        - -z
        - "$(ZK_HOST)"
        - "-h"
        - "$(SOLR_HOST)"
        - "-p"
        - "8983"
        volumeMounts:
        - name: solr-data
          mountPath: /var/solr
        livenessProbe:
          httpGet:
            path: /solr/admin/info/system
            port: 8983
            scheme: HTTP
          initialDelaySeconds: 90
          periodSeconds: 30
          timeoutSeconds: 10
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /solr/admin/info/system
            port: 8983
            scheme: HTTP
          initialDelaySeconds: 60
          periodSeconds: 20
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 3
  volumeClaimTemplates:
  - metadata:
      name: solr-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
EOF

echo "⏳ Waiting for Solr to start..."
sleep 30

# Check Solr
echo "🔍 Checking Solr..."
for i in {1..30}; do
  if kubectl get pod solr-0 -o jsonpath='{.status.phase}' 2>/dev/null | grep -q Running; then
    echo "✅ Solr pod is Running"
    
    # Test Solr
    if kubectl exec solr-0 -- curl -s http://localhost:8983/solr 2>/dev/null | grep -q "Solr Admin"; then
      echo "✅ Solr is responding"
      break
    fi
  fi
  echo -n "."
  sleep 5
done

# Show Solr logs if not working
if ! kubectl exec solr-0 -- curl -s http://localhost:8983/solr 2>/dev/null | grep -q "Solr Admin"; then
  echo "⚠️  Solr not responding, checking logs..."
  kubectl logs solr-0 --tail=30
fi

echo ""
echo "🎉 Single-node platform deployed!"
echo ""
echo "📊 Status:"
kubectl get all -n "$NAMESPACE"

echo ""
echo "🔗 Access URLs:"
echo "  Solr: http://solr.$NAMESPACE.svc.cluster.local:8983/solr"
echo "  ZooKeeper: zookeeper.$NAMESPACE.svc.cluster.local:2181"

echo ""
echo "🚀 To scale to HA (3 replicas), run:"
echo "   kubectl scale statefulset zookeeper --replicas=3 -n $NAMESPACE"
echo "   kubectl scale statefulset solr --replicas=3 -n $NAMESPACE"
echo ""
echo "🧪 Test commands:"
echo "   kubectl exec -n $NAMESPACE zookeeper-0 -- sh -c 'echo ruok | nc localhost 2181'"
echo "   kubectl exec -n $NAMESPACE solr-0 -- curl -s http://localhost:8983/solr/admin/cores"
