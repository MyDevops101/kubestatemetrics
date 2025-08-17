#!/bin/bash

# scripts/deploy-local.sh

set -e

# Configuration
NAMESPACE="monitoring"
RELEASE_NAME="kube-state-metrics"
CHART_REPOSITORY="oci://ghcr.io/prometheus-community/charts"
CHART_NAME="kube-state-metrics"
VALUES_FILE="helm/kube-state-metrics/values.yaml"
ENV_VALUES_FILE="helm/kube-state-metrics/values-dev.yaml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting kube-state-metrics deployment...${NC}"

# Check prerequisites
command -v helm >/dev/null 2>&1 || { echo -e "${RED}Helm is required but not installed.${NC}" >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo -e "${RED}Kubectl is required but not installed.${NC}" >&2; exit 1; }

# Check cluster connection
echo -e "${YELLOW}Checking cluster connection...${NC}"
kubectl cluster-info || { echo -e "${RED}Cannot connect to Kubernetes cluster${NC}"; exit 1; }

# Create namespace if it doesn't exist
echo -e "${YELLOW}Creating namespace if needed...${NC}"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Show chart information
echo -e "${YELLOW}Fetching chart information...${NC}"
helm show chart $CHART_REPOSITORY/$CHART_NAME

# Deploy or upgrade
echo -e "${YELLOW}Deploying kube-state-metrics...${NC}"
helm upgrade --install $RELEASE_NAME \
  $CHART_REPOSITORY/$CHART_NAME \
  --namespace $NAMESPACE \
  --values $VALUES_FILE \
  --values $ENV_VALUES_FILE \
  --wait \
  --timeout 10m

# Verify deployment
echo -e "${YELLOW}Verifying deployment...${NC}"
kubectl rollout status deployment/$RELEASE_NAME-kube-state-metrics -n $NAMESPACE

echo -e "${GREEN}Deployment completed successfully!${NC}"

# Show deployed resources
echo -e "${YELLOW}Deployed resources:${NC}"
kubectl get all -n $NAMESPACE -l app.kubernetes.io/name=kube-state-metrics
