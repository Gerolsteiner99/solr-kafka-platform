# solr-kafka-platform

# Solr‑Kafka‑Platform (Umbrella Helm Chart)

Dieses Projekt stellt eine vollständige Plattform aus **Solr**, **Kafka** und **Zookeeper** bereit.  
Die Architektur basiert auf einem **Helm‑Umbrella‑Chart**, das drei Subcharts bündelt:

- `solr`
- `kafka`
- `zookeeper`

Alle Komponenten laufen als **StatefulSets** in Kubernetes und sind vollständig konfigurierbar.

---

## 🚀 Features

- Vollständig parametrisiertes Helm‑Umbrella‑Chart  
- Saubere Trennung der Subcharts (`charts/solr`, `charts/kafka`, `charts/zookeeper`)  
- Dynamische Image‑Konfiguration (keine hart codierten Images)  
- Persistente Volumes für alle StatefulSets  
- Zookeeper‑basierte Kafka‑Cluster‑Konfiguration  
- SolrCloud‑fähige Struktur (optional erweiterbar)

---

## 🏗 Architektur

+-------------------------------------------------------------+ | Solr-Kafka-Platform | | (Umbrella Helm Chart) | +---------------------------+---------------------------------+ | | +-------------------+-------------------+ | | | v v v +---------------+ +---------------+ +---------------+ | Solr | | Kafka | | Zookeeper | | StatefulSet | | StatefulSet | | StatefulSet | +---------------+ +---------------+ +---------------+ | | | | | | | +---------+---------+ | | 
+-----------------------------+


---

## 📦 Struktur

├── charts
│   ├── kafka
│   │   ├── charts
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   ├── headless-service.yaml
│   │   │   ├── _helpers.tpl
│   │   │   ├── service.yaml
│   │   │   └── statefulset.yaml
│   │   └── values.yaml
│   ├── solr
│   │   ├── charts
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   ├── headless-service.yaml
│   │   │   ├── _helpers.tpl
│   │   │   ├── ingress.yaml
│   │   │   ├── NOTES.txt
│   │   │   ├── service.yaml
│   │   │   └── statefulset.yaml
│   │   └── values.yaml
│   └── zookeeper
│       ├── charts
│       ├── Chart.yaml
│       ├── templates
│       │   ├── headless-service.yaml
│       │   ├── _helpers.tpl
│       │   └── statefulset.yaml
│       └── values.yaml
├── Chart.yaml
├── full.yaml
├── ns.json
├── README.md
├── rendered.yaml
├── server.0=solrkafka-zookeeper-0.solrkafka-zookeeper-headless:2888:3888
├── templates
│   ├── _helpers.tpl
│   └── placeholder.yaml
└── values.yaml



---

## 🔧 Installation

Namespace anlegen:

bash
kubectl create namespace solrkafka



Deployment:

bash
helm upgrade --install solr-kafka . -n solrkafka


🔄 Upgrade

bash
helm upgrade solr-kafka . -n solrkafka --force


🧹 Deinstallation
bash
helm uninstall solr-kafka -n solrkafka

📄 Lizenz
Privates Projekt von Gerolsteiner99.


# 🧩 **2. Architektur‑Diagramm (ASCII, sofort nutzbar)**

Du kannst es in die README übernehmen oder als eigene Datei `ARCHITECTURE.md` speichern.

# Architekturübersicht

+-------------------------------------------------------------+
|                     Solr-Kafka-Platform                     |
|                     (Umbrella Helm Chart)                   |
+---------------------------+---------------------------------+
|
|
+-------------------+-------------------+
|                   |                   |
v                   v                   v
+---------------+   +---------------+   +---------------+
|    Solr       |   |    Kafka      |   |  Zookeeper    |
|  StatefulSet  |   |  StatefulSet  |   |  StatefulSet  |
+---------------+   +---------------+   +---------------+
|                   |                   |
|                   |                   |
|                   +---------+---------+
|                             |
+-----------------------------+


# Helm & kubectl Cheatsheet

## 🟦 Helm Befehle

### Installation / Upgrade
- `helm upgrade --install <release> <chart> -n <ns>`
- `helm upgrade <release> <chart> -n <ns> --force`

### Analyse & Debugging
- `helm template <chart>`
- `helm get values <release> -n <ns>`
- `helm get manifest <release> -n <ns>`
- `helm list -n <ns>`

### Chart Management
- `helm create <chartname>`
- `helm lint <chart>`
- `helm package <chart>`

### Entfernen
- `helm uninstall <release> -n <ns>`

---

## 🟩 kubectl Befehle

### Anzeigen
- `kubectl get pods -n <ns>`
- `kubectl get statefulset -n <ns>`
- `kubectl get all -n <ns>`
- `kubectl get pvc -n <ns>`

### Details
- `kubectl describe pod <pod> -n <ns>`
- `kubectl logs <pod> -n <ns>`
- `kubectl logs -f <pod> -n <ns>`

### Neustart
- `kubectl delete pod <pod> -n <ns>`

### Exec
- `kubectl exec -it <pod> -n <ns> -- bash`

### YAML anzeigen
- `kubectl get statefulset <name> -n <ns> -o yaml | grep image:`
