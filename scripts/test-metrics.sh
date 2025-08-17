#!/bin/bash

# scripts/test-metrics.sh

NAMESPACE="monitoring"
RELEASE_NAME="kube-state-metrics"
LOCAL_PORT=8080

echo "Setting up port-forward to kube-state-metrics..."
kubectl port-forward -n $NAMESPACE service/$RELEASE_NAME-kube-state-metrics $LOCAL_PORT:8080 &
PF_PID=$!

# Wait for port-forward
sleep 5

echo "Testing metrics endpoint..."
curl -s http://localhost:$LOCAL_PORT/metrics | head -20

echo ""
echo "Testing specific metric types:"
echo "- Deployments: $(curl -s http://localhost:$LOCAL_PORT/metrics | grep -c 'kube_deployment_')"
echo "- Pods: $(curl -s http://localhost:$LOCAL_PORT/metrics | grep -c 'kube_pod_')"
echo "- Nodes: $(curl -s http://localhost:$LOCAL_PORT/metrics | grep -c 'kube_node_')"
echo "- Services: $(curl -s http://localhost:$LOCAL_PORT/metrics | grep -c 'kube_service_')"

# Clean up
kill $PF_PID
echo "Port-forward stopped. Test completed."