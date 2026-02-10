# 📚 Resources - Solr-Kafka-HA Platform

## 📖 OFFIZIELLE DOKUMENTATION

### Apache ZooKeeper
- **Offizielle Docs:** https://zookeeper.apache.org/doc/current/
- **Quorum Konfiguration:** https://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_zkMulitServerSetup
- **4 Letter Words:** https://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_4lw
- **Best Practices:** https://zookeeper.apache.org/doc/current/recipes.html

### Apache Kafka
- **Offizielle Docs:** https://kafka.apache.org/documentation/
- **Kafka in Kubernetes:** https://kafka.apache.org/documentation/#kubernetes
- **Replication:** https://kafka.apache.org/documentation/#replication
- **Topic Configuration:** https://kafka.apache.org/documentation/#topicconfigs
- **Performance Tuning:** https://kafka.apache.org/documentation/#performance

### Apache Solr
- **Offizielle Docs:** https://solr.apache.org/guide/
- **Solr Cloud:** https://solr.apache.org/guide/solr-tutorial.html
- **Collection Management:** https://solr.apache.org/guide/collections-api.html
- **ZooKeeper Integration:** https://solr.apache.org/guide/using-zookeeper-to-manage-configuration-files.html

### Kubernetes
- **Offizielle Docs:** https://kubernetes.io/docs/home/
- **StatefulSets:** https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/
- **Services & Networking:** https://kubernetes.io/docs/concepts/services-networking/
- **Storage:** https://kubernetes.io/docs/concepts/storage/
- **Resource Management:** https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

---

## 🛠️ TOOLS & UTILITIES

### Kommandozeilen-Tools
```bash
# Kubernetes
kubectl                   # Kubernetes CLI
helm                     # Package Manager
kubens                   # Switch Namespace
kubectx                  # Switch Context

# Kafka
kafkacat                 # Generic Kafka CLI
kafka-tools             # Kafka utilities
kafka-ui               # Web UI für Kafka

# ZooKeeper
zkCli.sh                # ZooKeeper Client
zkServer.sh             # ZooKeeper Server
zkCleanup.sh            # ZooKeeper Cleanup

# Solr
solr                    # Solr CLI
post.jar               # Solr Post Tool


Monitoring Tools
Prometheus: https://prometheus.io/

Grafana: https://grafana.com/

kube-prometheus: https://github.com/prometheus-operator/kube-prometheus

JMX Exporter: https://github.com/prometheus/jmx_exporter

Testing Tools
k6: https://k6.io/ - Load Testing

JMeter: https://jmeter.apache.org/ - Performance Testing

Chaos Mesh: https://chaos-mesh.org/ - Chaos Engineering

Litmus: https://litmuschaos.io/ - Chaos Engineering for Kubernetes

📦 DOCKER IMAGES & VERSIONEN
Produktiv-Images (Getestet ✅)


ZooKeeper:
  repository: bitnami/zookeeper
  tag: 3.8.1
  digest: sha256:123... (validiert)

Kafka:
  repository: bitnami/kafka
  tag: 3.5.1
  digest: sha256:456... (validiert)

Solr:
  repository: solr
  tag: 9.4.1
  digest: sha256:789... (validiert)

# ZooKeeper Alternativen
- confluentinc/cp-zookeeper:7.5.0
- zookeeper:3.8.1

# Kafka Alternativen
- confluentinc/cp-kafka:7.5.0
- wurstmeister/kafka:latest

# Solr Alternativen
- bitnami/solr:9.4.1

# Images auf Sicherheitslücken prüfen
trivy image bitnami/zookeeper:3.8.1
grype bitnami/kafka:3.5.1
clair solr:9.4.1


🎓 TUTORIALS & GUIDES
Kubernetes Grundlagen
Kubernetes Basics - https://kubernetes.io/docs/tutorials/kubernetes-basics/

Stateful Applications - https://kubernetes.io/docs/tutorials/stateful-application/

Services & Networking - https://kubernetes.io/docs/tutorials/services/

Storage - https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/

Kafka Tutorials
Kafka in 5 Minutes - https://kafka.apache.org/quickstart

Kafka with ZooKeeper - https://kafka.apache.org/documentation/#quickstart

Kafka Streams - https://kafka.apache.org/30/documentation/streams/tutorial

Kafka Connect - https://kafka.apache.org/documentation/#connect

Solr Tutorials
Solr Quick Start - https://solr.apache.org/guide/solr-tutorial.html

Solr Cloud - https://solr.apache.org/guide/solrcloud.html

Solr with ZooKeeper - https://solr.apache.org/guide/using-zookeeper-to-manage-configuration-files.html

Solr Schemas - https://solr.apache.org/guide/schema-api.html

🔧 KUBERNETES MANIFESTS REFERENZEN
Best Practices für StatefulSets

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: example
spec:
  serviceName: "example-headless"
  replicas: 3
  podManagementPolicy: OrderedReady
  updateStrategy:
    type: RollingUpdate

Service Types
# Headless Service (für StatefulSets)
clusterIP: None

# ClusterIP (interne Kommunikation)
type: ClusterIP

# LoadBalancer (externer Zugriff)
type: LoadBalancer

# NodePort (Port-Forwarding)
type: NodePort


Resource Limits Empfehlungen
# ZooKeeper
resources:
  requests:
    memory: "512Mi"
    cpu: "250m"
  limits:
    memory: "1Gi"
    cpu: "500m"

# Kafka
resources:
  requests:
    memory: "1Gi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "1000m"

# Solr
resources:
  requests:
    memory: "1Gi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "1000m"


📊 MONITORING & METRICS
Prometheus Exporters

# ZooKeeper Exporter
https://github.com/dabealu/zookeeper-exporter

# Kafka Exporter
https://github.com/danielqsj/kafka-exporter

# Solr Exporter
https://github.com/prometheus/jmx_exporter



Wichtige Metriken

ZooKeeper:
- zk_znode_count
- zk_outstanding_requests
- zk_leader_elections

Kafka:
- kafka_server_broker_topic_metrics_messages_in_total
- kafka_consumer_lag
- kafka_partition_leader

Solr:
- solr_metrics_core_query_requests_per_second
- solr_metrics_cache_hits_total
- solr_metrics_index_size_bytes
