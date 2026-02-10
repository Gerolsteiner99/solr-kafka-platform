#!/bin/bash

NAMESPACE="solr-kafka-platform"

echo "========================================="
echo "COMPLETE CLEAN AND FRESH DEPLOY"
echo "========================================="

echo "1. Lösche ALLE Ressourcen..."
helm uninstall zookeeper kafka solr -n $NAMESPACE 2>/dev/null || true

echo "2. Lösche ALLE PVCs..."
kubectl delete pvc -n $NAMESPACE --all --force --grace-period=0 2>/dev/null || true

echo "3. Lösche ConfigMaps..."
kubectl delete configmap -n $NAMESPACE --all 2>/dev/null || true

echo "4. Warte auf Bereinigung..."
sleep 10

echo "5. Temporär: Vereinfachtes Zookeeper mit nur 1 Replica testen..."
cat > simple-zookeeper.yaml <<EOF
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: zookeeper-simple
  namespace: $NAMESPACE
spec:
  serviceName: zookeeper-service
  replicas: 1
  selector:
    matchLabels:
      app: zookeeper
  template:
    metadata:
      labels:
        app: zookeeper
    spec:
      containers:
      - name: zookeeper
        image: zookeeper:3.9.1
        ports:
        - containerPort: 2181
        env:
        - name: ZOO_STANDALONE_ENABLED
          value: "true"
        - name: ZOO_4LW_COMMANDS_WHITELIST
          value: "*"
        volumeMounts:
        - name: data
          mountPath: /data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: zookeeper-service
  namespace: $NAMESPACE
spec:
  clusterIP: None
  ports:
  - port: 2181
    targetPort: 2181
  selector:
    app: zookeeper
EOF

echo "6. Installiere einfachen Zookeeper..."
kubectl apply -f simple-zookeeper.yaml

echo "7. Warte auf Zookeeper..."
sleep 15
kubectl get pods -n $NAMESPACE -l app=zookeeper

echo "8. Prüfe Logs..."
kubectl logs -n $NAMESPACE deployment/zookeeper-simple || \
kubectl logs -n $NAMESPACE -l app=zookeeper --tail=50

echo "9. Teste Verbindung..."
kubectl exec -n $NAMESPACE -it $(kubectl get pods -n $NAMESPACE -l app=zookeeper -o jsonpath='{.items[0].metadata.name}') \
  -- bash -c "echo ruok | nc localhost 2181"
