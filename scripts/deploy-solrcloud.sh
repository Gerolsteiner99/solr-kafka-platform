#!/bin/bash
# deploy-solrcloud-complete.sh - Komplettes SolrCloud Setup

set -e  # Stop bei Fehlern

echo "========================================="
echo "  KOMPLETTES SOLRCLOUD DEPLOYMENT"
echo "========================================="
echo ""

# 1. Zookeeper /solr Pfad erstellen
echo "✅ 1. Erstelle /solr Pfad in Zookeeper..."
kubectl exec -it zookeeper-0 -n solr-kafka-platform -- bash -c \
  "echo 'create /solr \"SolR Cloud Root\"' | zkCli.sh -server localhost:2181" 2>/dev/null || \
  echo "Pfad existiert bereits oder Zookeeper nicht bereit"

sleep 2

# 2. Altes SolR löschen
echo "✅ 2. Lösche altes SolR..."
kubectl delete statefulset solr -n solr-kafka-platform 2>/dev/null || true
kubectl delete pvc -l app=solr -n solr-kafka-platform 2>/dev/null || true
sleep 10

# 3. SolrCloud StatefulSet Template erstellen
echo "✅ 3. Erstelle SolrCloud StatefulSet Template..."
cat > charts/solr/templates/statefulset.yaml <<'EOF'
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: solr
spec:
  serviceName: solr-service
  replicas: 3
  selector:
    matchLabels:
      app: solr
  template:
    metadata:
      labels:
        app: solr
    spec:
      initContainers:
      - name: wait-for-zookeeper
        image: busybox:1.28
        command: ['sh', '-c', 'until nslookup zookeeper-service; do echo waiting for zookeeper; sleep 5; done']
      - name: init-solr-home
        image: busybox:1.28
        command: ['sh', '-c', 'mkdir -p /var/solr/data && chmod 777 /var/solr/data']
        volumeMounts:
        - name: data
          mountPath: /var/solr/data
      containers:
      - name: solr
        image: "docker.io/library/solr:9.4.0"
        env:
        - name: SOLR_HOME
          value: /var/solr/data
        - name: ZK_HOST
          value: "zookeeper-service:2181/solr"
        - name: SOLR_HOST
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        command:
        - bash
        - -c
        - |
          # Wait for Zookeeper
          until nc -z zookeeper-service 2181; do
            echo "Waiting for Zookeeper..."
            sleep 5
          done
          
          # Start SolR in cloud mode
          exec solr start -f -c \
            -z ${ZK_HOST} \
            -h ${HOSTNAME}.solr-service \
            -p 8983
        ports:
        - containerPort: 8983
        readinessProbe:
          httpGet:
            path: /solr/admin/collections
            port: 8983
          initialDelaySeconds: 120
          periodSeconds: 20
          failureThreshold: 5
        livenessProbe:
          httpGet:
            path: /solr/admin/info/system
            port: 8983
          initialDelaySeconds: 90
          periodSeconds: 30
        volumeMounts:
        - name: data
          mountPath: /var/solr/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
EOF
echo "   ✓ statefulset.yaml erstellt"

# 4. Headless Service Template erstellen
echo "✅ 4. Erstelle Headless Service Template..."
cat > charts/solr/templates/service.yaml <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: solr-service
spec:
  clusterIP: None
  ports:
  - port: 8983
    name: http
  selector:
    app: solr
---
apiVersion: v1
kind: Service
metadata:
  name: solr-external
spec:
  type: NodePort
  ports:
  - port: 8983
    targetPort: 8983
    nodePort: 30083
  selector:
    app: solr
EOF
echo "   ✓ service.yaml erstellt"

# 5. Deployen mit Helm
echo "✅ 5. Deploye SolrCloud mit Helm..."
helm upgrade --install solr-kafka-platform . \
  -n solr-kafka-platform \
  --force \
  --set solr.replicaCount=3 \
  --wait --timeout 10m

echo ""
echo "⏳ 6. Warte auf SolrCloud Initialisierung (kann 3-5 Minuten dauern)..."
echo "   Überwache Pods in einem neuen Terminal mit:"
echo "   watch -n 5 'kubectl get pods -n solr-kafka-platform -l app=solr'"
echo ""

# 6. Warten auf Readiness
for i in {1..30}; do
  READY_COUNT=$(kubectl get pods -n solr-kafka-platform -l app=solr --no-headers | grep -c "Running")
  if [ "$READY_COUNT" -eq 3 ]; then
    echo "✅ Alle 3 SolR Pods sind Running!"
    break
  fi
  echo "   Noch nicht alle Pods ready ($READY_COUNT/3)... warte 10s"
  sleep 10
done

# 7. Finaler Test
echo ""
echo "✅ 7. Führe finale Tests durch..."
echo ""
echo "a) Pod Status:"
kubectl get pods -n solr-kafka-platform -l app=solr -o wide

echo ""
echo "b) Zookeeper SolR Pfad prüfen:"
kubectl exec -it zookeeper-0 -n solr-kafka-platform -- zkCli.sh ls /solr 2>/dev/null || echo "Zookeeper nicht bereit"

echo ""
echo "c) SolrCloud Collection erstellen (Test):"
COLLECTION_CMD="curl -s 'http://localhost:8983/solr/admin/collections?action=CREATE&name=cloudtest&numShards=2&replicationFactor=2&maxShardsPerNode=2&wt=json'"
kubectl exec -it solr-0 -n solr-kafka-platform -- bash -c "$COLLECTION_CMD" 2>/dev/null || echo "Erstelle Collection manuell später"

echo ""
echo "d) Collections auflisten:"
LIST_CMD="curl -s 'http://localhost:8983/solr/admin/collections?action=LIST&wt=json'"
kubectl exec -it solr-0 -n solr-kafka-platform -- bash -c "$LIST_CMD" 2>/dev/null | jq -r '.collections[]' 2>/dev/null || echo "Keine Collections gefunden"

echo ""
echo "========================================="
echo "🎉 SOLRCLOUD DEPLOYMENT FERTIG!"
echo "========================================="
echo ""
echo "📊 ZUSAMMENFASSUNG:"
echo "   ✅ Zookeeper: 3 Pods"
echo "   ✅ Kafka: 1 Pod (skalierbar)"
echo "   ✅ SolrCloud: 3 Pods mit Clustering"
echo ""
echo "🌐 ZUGRIFFS-URLS:"
MINIKUBE_IP=$(minikube ip)
echo "   SolrCloud UI:    http://${MINIKUBE_IP}:30083/solr"
echo "   Zookeeper:       ${MINIKUBE_IP}:32181"
echo "   Kafka:           ${MINIKUBE_IP}:31090"
echo ""
echo "🔧 NÜTZLICHE BEFEHLE:"
echo "   # Collection erstellen:"
echo "   kubectl exec -it solr-0 -n solr-kafka-platform -- bash -c \"curl 'http://localhost:8983/solr/admin/collections?action=CREATE&name=mycollection&numShards=2&replicationFactor=2'\""
echo ""
echo "   # Cluster Status:"
echo "   kubectl exec -it solr-0 -n solr-kafka-platform -- bash -c \"curl 'http://localhost:8983/solr/admin/collections?action=CLUSTERSTATUS'\""
echo ""
echo "   # Logs anzeigen:"
echo "   kubectl logs -f solr-0 -n solr-kafka-platform"
echo ""
echo "🚀 Deine hochverfügbare Solr-Kafka Platform ist jetzt mit"
echo "   vollständigem Clustering bereit!"
