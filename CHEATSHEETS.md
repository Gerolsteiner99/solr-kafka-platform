# Cheatsheets – Solr‑Kafka Platform

Dieses Dokument enthält die wichtigsten Befehle für Helm und kubectl, um die Solr‑Kafka‑Plattform effizient zu verwalten.

---

# 🟦 Helm Befehle

## Installation / Upgrade
- `helm upgrade --install <release> <chart> -n <ns>`
- `helm upgrade <release> <chart> -n <ns> --force`

## Analyse & Debugging
- `helm template <chart>`
- `helm get values <release> -n <ns>`
- `helm get manifest <release> -n <ns>`
- `helm list -n <ns>`

## Chart Management
- `helm create <chartname>`
- `helm lint <chart>`
- `helm package <chart>`

## Entfernen
- `helm uninstall <release> -n <ns>`

---

# 🟩 kubectl Befehle

## Anzeigen
- `kubectl get pods -n solrkafka`
- `kubectl get statefulset -n solrkafka`
- `kubectl get all -n solrkafka`
- `kubectl get pvc -n solrkafka`

## Details
- `kubectl describe pod <pod> -n solrkafka`
- `kubectl logs <pod> -n solrkafka`
- `kubectl logs -f <pod> -n solrkafka`

## Neustart
- `kubectl delete pod <pod> -n solrkafka`

## Exec
- `kubectl exec -it <pod> -n solrkafka -- bash`

## YAML anzeigen
- `kubectl get statefulset <name> -n solrkafka -o yaml | grep image:`

