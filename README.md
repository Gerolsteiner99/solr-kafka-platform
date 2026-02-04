# Solr‑Kafka Platform

Diese Plattform stellt eine vollständige, produktionsnahe Installation von **SolrCloud**, **Kafka** und **ZooKeeper** auf Kubernetes bereit.  
Sie basiert vollständig auf Helm‑Charts und ist modular aufgebaut, sodass jede Komponente unabhängig konfiguriert und erweitert werden kann.

---

## 🚀 Features

- SolrCloud (3 Nodes) mit Headless‑Service, externem Service und automatischer Collection‑Erstellung
- ZooKeeper Ensemble (3 Nodes) für SolrCloud und Kafka
- Kafka Broker (1–3 Nodes, je nach Values)
- CronJob zur monatlichen Collection‑Erstellung (`coll-MM-YY`)
- Umbrella‑Chart, das alle Module orchestriert
- Vollständig Helm‑basiert, reproduzierbar und erweiterbar

---

## 🧩 Modulübersicht

### SolrCloud‑Modul (`charts/solr/`)
- StatefulSet (3 Nodes)
- Headless Service
- Externer Service
- CronJob zur monatlichen Collection‑Erstellung
- ServiceAccount
- Optionaler Ingress

### Kafka‑Modul (`charts/kafka/`)
- StatefulSet
- Headless Service
- Externer Service
- Broker‑Konfiguration über Values

### ZooKeeper‑Modul (`charts/zookeeper/`)
- StatefulSet
- Headless Service
- ConfigMap
- Service‑Definitionen

### Umbrella‑Chart (`./`)
- Chart.yaml
- values.yaml
- Platzhalter‑Templates
- Namespace‑Definition (`ns.json`)

---

# 📂 Projektstruktur (kompletter Tree)

```text
.
├── Chart.lock
├── charts
│   ├── kafka
│   │   ├── charts
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   ├── headless-service.yaml
│   │   │   ├── _helpers.tpl
│   │   │   ├── service.yaml
│   │   │   └── statefulset.yaml
│   │   └── values.yaml
│   ├── kafka-0.1.0.tgz
│   ├── solr
│   │   ├── charts
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   ├── cronjob-monthly-collection.yaml
│   │   │   ├── headless-service.yaml
│   │   │   ├── _helpers.tpl
│   │   │   ├── ingress.yaml
│   │   │   ├── NOTES.txt
│   │   │   ├── serviceaccount.yaml
│   │   │   ├── service.yaml
│   │   │   └── statefulset.yaml
│   │   └── values.yaml
│   ├── solr-0.1.0.tgz
│   ├── zookeeper
│   │   ├── charts
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   ├── configmap.yaml
│   │   │   ├── headless-service.yaml
│   │   │   ├── _helpers.tpl
│   │   │   ├── service-headless.yaml
│   │   │   └── statefulset.yaml
│   │   └── values.yaml
│   └── zookeeper-0.1.0.tgz
├── Chart.yaml
├── full.yaml.disabled
├── ns.json
├── README.md
├── rendered.yaml
├── running-pod.yaml
├── solr-kafka-working.tar.gz
├── templates
│   ├── _helpers.tpl
│   └── placeholder.yaml
└── values.yaml

