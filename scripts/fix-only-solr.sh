#!/bin/bash
# fix-only-solr.sh

echo "=== Fixing only SolR ==="

echo "1. Lösche SolR StatefulSet und PVCs..."
kubectl delete statefulset solr -n solr-kafka-platform 2>/dev/null || true
kubectl delete pvc -l app=solr -n solr-kafka-platform 2>/dev/null || true
sleep 5

echo "2. Erstelle korrigiertes SolR Template..."
cat > charts/solr/templates/statefulset.yaml <<'EOF'
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: solr
spec:
  serviceName: solr-service
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
        command:
        - bash
        - -c
        - |
          echo "Starting SolR Cloud with ZK_HOST: ${ZK_HOST}"
          solr start -f -c -z ${ZK_HOST}
          tail -f /dev/null
        ports:
        - containerPort: 8983
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

echo "3. Deploye SolR neu..."
helm upgrade --install solr-kafka-platform . \
  -n solr-kafka-platform \
  --force

echo "4. Warte 2 Minuten..."
sleep 120

echo "5. Teste SolR..."
kubectl exec -it solr-0 -n solr-kafka-platform -- curl -s http://localhost:8983/solr | grep -i solr && echo "✅ SolR läuft!" || echo "❌ SolR nicht erreichbar"
