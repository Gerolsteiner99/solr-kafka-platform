# Ressourcenübersicht – Solr‑Kafka Platform

Dieses Dokument listet alle relevanten Kubernetes‑Ressourcen der Solr‑Kafka‑Plattform auf.  
Alle Befehle beziehen sich auf den Namespace **solrkafka**.

---

## Pods

Erwartete Pods:

solrkafka-solr-0  
solrkafka-solr-1  
solrkafka-solr-2  
solrkafka-kafka-0  
solrkafka-zookeeper-0  
solrkafka-zookeeper-1  
solrkafka-zookeeper-2  

Befehl:

kubectl get pods -n solrkafka

---

## StatefulSets

Erwartete StatefulSets:

solrkafka-solr  
solrkafka-kafka  
solrkafka-zookeeper  

Befehl:

kubectl get statefulset -n solrkafka

---

## Services

Erwartete Services:

solrkafka-solr  
solrkafka-solr-headless  
solrkafka-kafka  
solrkafka-kafka-headless  
solrkafka-zookeeper  
solrkafka-zookeeper-headless  

Befehl:

kubectl get svc -n solrkafka

---

## PersistentVolumeClaims (PVCs)

Erwartete PVCs:

data-solrkafka-solr-0  
data-solrkafka-solr-1  
data-solrkafka-solr-2  
data-solrkafka-kafka-0  
data-solrkafka-zookeeper-0  
data-solrkafka-zookeeper-1  
data-solrkafka-zookeeper-2  

Befehl:

kubectl get pvc -n solrkafka

---

## ConfigMaps

Erwartete ConfigMaps:

solrkafka-zookeeper-config  

Befehl:

kubectl get configmap -n solrkafka

---

## CronJobs

Erwartete CronJobs:

solrkafka-solr-monthly-collection  

Befehl:

kubectl get cronjob -n solrkafka

---

## ServiceAccounts

Erwartete ServiceAccounts:

solrkafka-solr  
default  

Befehl:

kubectl get sa -n solrkafka

---

## Secrets

Typische Secrets:

default-token-xxxxx  
solrkafka-solr-token-xxxxx  

Befehl:

kubectl get secret -n solrkafka

---

## Namespace

Erwarteter Namespace:

solrkafka  

Befehl:

kubectl get ns solrkafka

---

## Hinweise

- Alle Ressourcen werden automatisch durch das Helm‑Umbrella‑Chart erzeugt.  
- Die Namen folgen dem Muster: `<release-name>-<chart-name>-<resource>`  
- Release‑Name ist: **solr-kafka**

