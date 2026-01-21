# solr-kafka-platform

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
