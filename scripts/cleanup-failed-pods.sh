#!/bin/bash
# cleanup-and-fix-properly.sh

NAMESPACE="solr-kafka-simple"

echo "🔧 KORREKTE BEREINIGUNG UND REPARATUR"
echo "===================================="

echo "1. Identifiziere laufenden Kafka Pod..."
# Korrekte Filterung: Nur Running Pods mit READY=1/1
LAUFENDER_POD=$(kubectl get pods -n "$NAMESPACE" -l app=kafka -o json | \
  jq -r '.items[] | select(.status.phase == "Running") | select(.status.containerStatuses[0].ready == true) | .metadata.name' | head -1)

FEHLERHAFTER_POD=$(kubectl get pods -n "$NAMESPACE" -l app=kafka -o json | \
  jq -r '.items[] | select(.status.phase != "Running" or .status.containerStatuses[0].ready == false) | .metadata.name' | head -1)

echo "   ✅ Laufender Pod: $LAUFENDER_POD"
echo "   ❌ Fehlerhafter Pod: $FEHLERHAFTER_POD"

echo ""
echo "2. Lösche NUR den fehlerhaften Pod..."
if [ -n "$FEHLERHAFTER_POD" ]; then
  kubectl delete pod "$FEHLERHAFTER_POD" -n "$NAMESPACE" --grace-period=0 --force
  echo "   Gelöscht: $FEHLERHAFTER_POD"
else
  echo "   Kein fehlerhafter Pod gefunden"
fi

echo ""
echo "3. Lösche das fehlerhafte Deployment..."
# Finde das Deployment das den fehlerhaften Pod erstellt
kubectl get deployments -n "$NAMESPACE" -l app=kafka -o name | while read DEPLOY; do
  DEPLOY_NAME=${DEPLOY#deployment.apps/}
  
  # Prüfe ob dieses Deployment einen fehlerhaften Pod hat
  PODS_FROM_DEPLOY=$(kubectl get pods -n "$NAMESPACE" -l app=kafka --show-labels | grep "$DEPLOY_NAME" | awk '{print $1}')
  
  ALL_RUNNING=true
  for POD in $PODS_FROM_DEPLOY; do
    STATUS=$(kubectl get pod "$POD" -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null)
    READY=$(kubectl get pod "$POD" -n "$NAMESPACE" -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null)
    
    if [ "$STATUS" != "Running" ] || [ "$READY" != "true" ]; then
      ALL_RUNNING=false
      echo "   🗑️  Lösche fehlerhaftes Deployment: $DEPLOY_NAME"
      kubectl delete deployment "$DEPLOY_NAME" -n "$NAMESPACE" --ignore-not-found
      break
    fi
  done
done

echo ""
echo "4. Warte 3 Sekunden..."
sleep 3

echo ""
echo "5. Finaler Status aller Kafka Ressourcen:"
echo "   📦 Deployments:"
kubectl get deployments -n "$NAMESPACE" -l app=kafka

echo ""
echo "   🐳 Pods:"
kubectl get pods -n "$NAMESPACE" -l app=kafka -o wide

echo ""
echo "   🔗 Services:"
kubectl get svc -n "$NAMESPACE" -l app=kafka

echo ""
echo "6. Teste den laufenden Kafka Pod..."
if [ -n "$LAUFENDER_POD" ]; then
  echo "   Testing: $LAUFENDER_POD"
  echo ""
  echo "   🧪 Kafka Prozesse:"
  kubectl exec -n "$NAMESPACE" "$LAUFENDER_POD" -- ps aux | grep -E "(kafka|java)" | head -5 || echo "   Keine Prozesse gefunden"
  
  echo ""
  echo "   🔌 Port 9092:"
  kubectl exec -n "$NAMESPACE" "$LAUFENDER_POD" -- netstat -tulpn 2>/dev/null | grep 9092 || echo "   Port nicht listening"
  
  echo ""
  echo "   📊 Topics:"
  kubectl exec -n "$NAMESPACE" "$LAUFENDER_POD" -- \
    timeout 5 /opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null | \
    while read topic; do echo "     • $topic"; done || echo "   Keine Topics oder nicht erreichbar"
else
  echo "   ❌ Kein laufender Kafka Pod gefunden"
fi
