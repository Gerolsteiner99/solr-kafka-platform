#!/bin/bash

NAMESPACE="solr-kafka-platform"

echo "========================================="
echo "STEPWISE DEPLOYMENT - Mit Debug"
echo "========================================="

echo "1. Namespace erstellen..."
kubectl create namespace $NAMESPACE 2>/dev/null || echo "Namespace existiert bereits"

echo "2. Alte Installationen bereinigen..."
helm uninstall zookeeper -n $NAMESPACE 2>/dev/null || echo "Kein Zookeeper Release gefunden"
kubectl delete pvc -n $NAMESPACE -l app=zookeeper 2>/dev/null || true
sleep 5

echo "3. Zookeeper Cluster installieren (3 Nodes)..."
helm upgrade --install zookeeper ./charts/zookeeper -n $NAMESPACE

echo "4. Warte auf Zookeeper Pods..."
for i in {1..60}; do
  POD_COUNT=$(kubectl get pods -n $NAMESPACE -l app=zookeeper --no-headers | wc -l)
  READY_COUNT=$(kubectl get pods -n $NAMESPACE -l app=zookeeper -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' | grep -c True)
  
  echo "Zookeeper Pods: $POD_COUNT vorhanden, $READY_COUNT ready"
  
  if [ "$POD_COUNT" -eq 3 ] && [ "$READY_COUNT" -eq 3 ]; then
    echo "✓ Alle Zookeeper Pods sind ready!"
    break
  fi
  
  if [ $i -eq 10 ]; then
    echo "Debug nach 10 Versuchen:"
    kubectl get pods -n $NAMESPACE -l app=zookeeper
    kubectl describe pod zookeeper-0 -n $NAMESPACE | tail -20
  fi
  
  if [ $i -eq 20 ]; then
    echo "Zeige Logs von zookeeper-0:"
    kubectl logs zookeeper-0 -n $NAMESPACE --tail=30
  fi
  
  sleep 10
done

echo "5. Zookeeper Cluster Status prüfen..."
kubectl exec zookeeper-0 -n $NAMESPACE -- zkServer.sh status 2>/dev/null || {
  echo "Zookeeper noch nicht bereit, warte weiter..."
  sleep 30
  kubectl exec zookeeper-0 -n $NAMESPACE -- zkServer.sh status 2>/dev/null || echo "Status check fehlgeschlagen"
}

echo "6. Test Zookeeper Verbindung..."
kubectl exec zookeeper-0 -n $NAMESPACE -- bash -c "echo ruok | nc localhost 2181" && echo "✓ Zookeeper antwortet!"

echo "7. Kafka installieren..."
helm upgrade --install kafka ./charts/kafka -n $NAMESPACE

echo "8. Warte auf Kafka Pods..."
for i in {1..30}; do
  READY=$(kubectl get pods -n $NAMESPACE -l app=kafka -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' | grep -c True)
  if [ "$READY" -eq 3 ]; then
    echo "✓ Alle Kafka pods ready"
    break
  fi
  echo "Warte auf Kafka... ($READY/3 ready)"
  sleep 10
done

echo "9. Solr installieren..."
helm upgrade --install solr ./charts/solr -n $NAMESPACE

echo "10. Warte auf Solr Pods..."
for i in {1..30}; do
  READY=$(kubectl get pods -n $NAMESPACE -l app=solr -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' | grep -c True)
  if [ "$READY" -eq 3 ]; then
    echo "✓ Alle Solr pods ready"
    break
  fi
  echo "Warte auf Solr... ($READY/3 ready)"
  sleep 10
done

echo "========================================="
echo "DEPLOYMENT STATUS"
echo "========================================="
kubectl get all -n $NAMESPACE

echo ""
echo "Zookeeper Cluster Status:"
kubectl exec zookeeper-0 -n $NAMESPACE -- zkServer.sh status 2>/dev/null || echo "Status nicht verfügbar"

echo ""
echo "Test-Commands:"
echo "  Zookeeper testen: kubectl exec zookeeper-0 -n $NAMESPACE -- bash -c \"echo ruok | nc localhost 2181\""
echo "  Solr UI:          kubectl port-forward svc/solr-service 8983:8983 -n $NAMESPACE"
echo "  Kafka testen:     kubectl exec kafka-0 -n $NAMESPACE -- kafka-topics.sh --list --bootstrap-server localhost:9092"
