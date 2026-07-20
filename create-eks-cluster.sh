#!/bin/bash
# ==============================================================================
# Script: create-eks-cluster.sh
# Description: Provisions the Amazon EKS cluster and worker node group.
# ==============================================================================

set -e

CLUSTER_NAME="dev-cluster"
REGION="ap-south-1"
NODE_TYPE="t3.medium"

echo "🚀 Provisioning EKS Cluster: ${CLUSTER_NAME} in ${REGION}..."

eksctl create cluster \
  --name ${CLUSTER_NAME} \
  --region ${REGION} \
  --nodegroup-name worker-nodes \
  --node-type ${NODE_TYPE} \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3 \
  --managed

# Update local kubeconfig
aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${REGION}

echo "✅ EKS Cluster ${CLUSTER_NAME} successfully created and configured!"
kubectl get nodes