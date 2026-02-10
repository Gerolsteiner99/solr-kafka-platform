#!/bin/bash
echo "=== Kafka Test Script ==="

# Finde den richtigen Pod
if kubectl get pods -l app=kafka-kraft 2>/dev/null | grep -q Running; then
  POD=$(kubectl get pods -l app=kafka-kraft -o jsonpath='{.items[0].metadata.name}')
  echo "Verwende KRaft Kafka Pod: $POD"
elif kubectl get pods -l app=kafka 2>/dev/null | grep -q Running; then
  POD=$(kubectl get pods -l app=kafka -o jsonpath='{.items[0].metadata.name}')
  echo "Verwende normalen Kafka Pod: $POD"
else
  echo "Kein Kafka Pod gefunden!"
  exit 1
fi

echo "=== Teste Verbindung ==="
kubectl exec "$POD" -- timeout 5 bash -c "echo '' | nc -zv localhost 9092" && echo "✓ Port 9092 offen" || echo "✗ Port 9092 nicht erreichbar"

echo "=== Erstelle Test Topic ==="
kubectl exec "$POD" -- \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --create \
  --topic quick-test \
  --partitions 1 \
  --replication-factor 1 2>&1

echo "=== Schreibe Nachricht ==="
echo "Hello Kafka!" | kubectl exec -i "$POD" -- \
  /opt/kafka/bin/kafka-console-producer.sh \
  --bootstrap-server localhost:9092 \
  --topic quick-test

echo "=== Lese Nachricht ==="
kubectl exec "$POD" -- \
  /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic quick-test \
  --from-beginning \
  --max-messages 1 \
  --timeout-ms 5000 2>&1

echo "=== Liste Topics ==="
kubectl exec "$POD" -- \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --list 2>&1
