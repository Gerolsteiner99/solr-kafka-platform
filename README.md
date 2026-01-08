# solr-kafka-platform

Dieses Repository enthält:

- ein Docker-Image für Apache Solr mit automatischen Backups
- Skripte für Backup, Restore und Healthcheck
- ein Helm-Chart zur Installation im Kubernetes-/Minikube-Cluster
- eine GitHub Actions CI/CD-Pipeline für:
  - Build des Docker-Images
  - Push in GitHub Container Registry (GHCR)
  - Versionierung und Packaging des Helm-Charts

## 🚀 Voraussetzungen

- GitHub-Konto
- Git lokal installiert
- Minikube oder anderer Kubernetes-Cluster
- Helm installiert
- GHCR-Zugriff (GitHub Container Registry)

## 🧱 Projektstruktur

```text
solr-kafka-platform/
├── Dockerfile
├── scripts/
├── charts/
│   └── solr-kafka-platform/templates
├── .github/workflows/ci-cd.yml
└── README.md
└── crontab
└── docker-compose.yml

