#!/bin/bash
echo "=== Comprehensive Zookeeper Test ==="

# Test 1: Direkter Zugriff auf den Pod
ZK_POD=$(kubectl get pod -l app=zookeeper -o jsonpath='{.items[0].metadata.name}')
if [ -z "$ZK_POD" ]; then
  echo "❌ No Zookeeper pod found"
  exit 1
fi

echo "1. Testing Zookeeper from inside its own pod:"
kubectl exec $ZK_POD -- zkServer.sh status
ZK_STATUS=$?

echo ""
echo "2. Testing if port 2181 is listening inside the pod:"
kubectl exec $ZK_POD -- netstat -tlnp | grep 2181

echo ""
echo "3. Testing connection from another pod:"
kubectl run zk-client-test --image=busybox:1.35 --restart=Never --rm -i --command -- \
  sh -c '
    echo "Testing connection to zookeeper service..."
    if nslookup zookeeper >/dev/null 2>&1; then
      echo "✓ DNS resolution works"
      echo "Trying to connect to zookeeper:2181..."
      if echo "stat" | timeout 5 nc zookeeper 2181 2>/dev/null | grep -q "Zookeeper"; then
        echo "✓ Zookeeper is responding to commands"
        exit 0
      else
        echo "✗ Zookeeper not responding to commands"
        exit 1
      fi
    else
      echo "✗ DNS resolution failed"
      exit 1
    fi
  '
CLIENT_TEST=$?

echo ""
echo "=== TEST RESULTS ==="
if [ $ZK_STATUS -eq 0 ] && [ $CLIENT_TEST -eq 0 ]; then
  echo "✅ Zookeeper is fully functional"
  exit 0
else
  echo "❌ Zookeeper has issues"
  echo "   Zookeeper internal status: $ZK_STATUS"
  echo "   Client connection test: $CLIENT_TEST"
  exit 1
fi
