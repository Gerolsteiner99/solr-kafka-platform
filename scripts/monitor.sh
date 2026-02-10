#!/bin/bash
# monitor.sh - Monitor platform

while true; do
    clear
    echo "$(date) - solr-kafka-platform"
    echo "================================="
    kubectl get pods -n solr-kafka-platform
    echo ""
    kubectl get svc -n solr-kafka-platform
    sleep 5
done
