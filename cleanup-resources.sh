#!/bin/bash
# ==============================================================================
# Script: cleanup-resources.sh
# Description: Deletes the EKS cluster and associated AWS resources.
# ==============================================================================

set -e

CLUSTER_NAME="dev-cluster"
REGION="ap-south-1"

echo "⚠️ WARNING: Deleting EKS cluster ${CLUSTER_NAME} in region ${REGION}..."
read -p "Are you sure you want to proceed? (y/n): " confirm

if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    eksctl delete cluster --name ${CLUSTER_NAME} --region ${REGION}
    echo "✅ Cluster cleanup completed!"
else
    echo "❌ Cleanup canceled."
fi