# Troubleshooting – Solr‑Kafka Platform

Dieses Dokument enthält alle relevanten Fehlerbilder und Lösungen für die Solr‑Kafka‑Plattform.  
Alle Befehle beziehen sich auf den Namespace **solrkafka**.

---

## Solr UI ist nicht erreichbar

Mögliche Ursachen:  
- Solr‑Pod nicht bereit  
- Port‑Forward nicht aktiv  
- Service nicht erreichbar  

Lösung:  
kubectl get pods -n solrkafka  
kubectl logs solrkafka-solr-0 -n solrkafka  
kubectl port-forward svc/solrkafka-solr 8983:8983 -n solrkafka  

---

## Collections werden nicht erstellt

Mögliche Ursachen:  
- CronJob schlägt fehl  
- Solr API nicht erreichbar  
- ZooKeeper instabil  

Lösung:  
kubectl logs job/<jobname> -n solrkafka  
kubectl logs solrkafka-solr-0 -n solrkafka  

Manueller Test:  
curl "http://localhost:8983/solr/admin/collections?action=CREATE&name=test&numShards=2&replicationFactor=3&collection.configName=_default"  

---

## Kafka startet nicht

Mögliche Ursachen:  
- ZooKeeper nicht erreichbar  
- Broker‑Konfiguration fehlerhaft  
- PVC beschädigt  

Lösung:  
kubectl logs solrkafka-kafka-0 -n solrkafka  
kubectl describe pod solrkafka-kafka-0 -n solrkafka  

---

## ZooKeeper‑Pods crashen

Mögliche Ursachen:  
- ConfigMap fehlerhaft  
- Ports blockiert  
- PVC beschädigt  

Lösung:  
kubectl logs solrkafka-zookeeper-0 -n solrkafka  
kubectl describe pod solrkafka-zookeeper-0 -n solrkafka  

---

## PVC‑Fehler

Mögliche Ursachen:  
- StorageClass fehlt  
- Volume nicht gebunden  
- Daten beschädigt  

Lösung:  
kubectl get pvc -n solrkafka  
kubectl describe pvc data-solrkafka-solr-0 -n solrkafka  

---

## CronJob läuft nicht

Mögliche Ursachen:  
- ServiceAccount fehlt  
- Solr API nicht erreichbar  
- CronJob Syntaxfehler  

Lösung:  
kubectl get cronjob -n solrkafka  
kubectl logs job/<jobname> -n solrkafka  

---

## Images werden nicht aktualisiert

Mögliche Ursachen:  
- Kubernetes cached Images  
- StatefulSet wurde nicht neu gestartet  

Lösung:  
kubectl get statefulset solrkafka-solr -n solrkafka -o yaml | grep image:  
kubectl delete pod solrkafka-solr-0 -n solrkafka  

---

## Helm‑Upgrade übernimmt Werte nicht

Mögliche Ursachen:  
- Immutable Fields  
- StatefulSets blockieren Updates  

Lösung:  
helm upgrade solr-kafka . -n solrkafka --force  
helm get values solr-kafka -n solrkafka  

