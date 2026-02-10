#!/bin/bash
# cleanup-and-restart.sh

NAMESPACE="solr-kafka-simple"

echo "🧹 COMPLETE CLEANUP AND RESTART"
echo "================================"

# 1. ALLE Kafka Ressourcen löschen
echo "1. Lösche ALLE Kafka Ressourcen..."
kubectl delete statefulset kafka -n "$NAMESPACE" --ignore-not-found
kubectl delete deployment kafka -n "$NAMESPACE" --ignore-not-found
kubectl delete service kafka -n "$NAMESPACE" --ignore-not-found
kubectl delete service kafka-headless -n "$NAMESPACE" --ignore-not-found

# 2. Warte bis alles gelöscht ist
echo ""
echo "2. Warte auf Cleanup..."
sleep 10

# 3. Nur die funktionierenden Teile behalten
echo ""
echo "3. Prüfe verbleibende Ressourcen:"
kubectl get all -n "$NAMESPACE"

# 4. Vereinfachtes Kafka Deployment
echo ""
echo "4. Erstelle vereinfachtes Kafka..."
cat <<EOF | kubectl apply -n "$NAMESPACE" -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kafka
  labels:
    app: kafka
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kafka
  template:
    metadata:
      labels:
        app: kafka
    spec:
      containers:
      - name: kafka
        image: docker.io/apache/kafka:3.7.0
        ports:
        - containerPort: 9092
        
        # SEHR EINFACHE Konfiguration
        env:
        - name: KAFKA_BROKER_ID
          value: "1"
        - name: KAFKA_ZOOKEEPER_CONNECT
          value: "zookeeper:2181"
        - name: KAFKA_LISTENERS
          value: "PLAINTEXT://:9092"
        - name: KAFKA_ADVERTISED_LISTENERS
          value: "PLAINTEXT://localhost:9092"  # WICHTIG: localhost statt kafka
        
        # Debug Command
        command:
        - sh
        - -c
        - |
          echo "=== DEBUG MODE ==="
          echo "Testing ZooKeeper connection..."
          
          # Test ZooKeeper connection first
          timeout 30 /opt/kafka/bin/zookeeper-shell.sh zookeeper:2181 ls / 2>&1 | grep -q "zookeeper" && echo "ZooKeeper OK" || echo "ZooKeeper FAILED"
          
          echo "Starting Kafka in foreground..."
          exec /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
EOF

# 5. Service
echo ""
echo "5. Erstelle Service..."
cat <<EOF | kubectl apply -n "$NAMESPACE" -f -
apiVersion: v1
kind: Service
metadata:
  name: kafka
  labels:
    app: kafka
spec:
  selector:
    app: kafka
  ports:
  - port: 9092
    targetPort: 9092
EOF

echo ""
echo "6. Warte 15 Sekunden..."
sleep 15

# 6. Logs zeigen
echo ""
echo "7. Kafka Logs:"
kubectl logs -n "$NAMESPACE" -l app=kafka --tail=20 2>/dev/null || echo "Noch keine Logs verfügbar"

echo ""
echo "8. Finaler Status:"
kubectl get pods -n "$NAMESPACE" -l app=kafka
