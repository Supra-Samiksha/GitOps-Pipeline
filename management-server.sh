#!/bin/bash
# ==============================================================================
# Script: setup-management-server.sh
# Description: Installs AWS CLI, kubectl, eksctl, Helm, and Docker on Ubuntu/Amazon Linux.
# ==============================================================================

set -e

echo "🚀 Starting Management Server Setup..."

# Update system
sudo apt-get update -y || sudo yum update -y

# Install Docker
echo "📦 Installing Docker..."
if command -v apt-get &> /dev/null; then
    sudo apt-get install -y docker.io
else
    sudo yum install -y docker
fi

sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Install AWS CLI v2
echo "☁️ Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install --update
rm -rf aws awscliv2.zip

# Install kubectl
echo "☸️ Installing kubectl..."
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Install eksctl
echo "🛠️ Installing eksctl..."
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Install Helm
echo "⛵ Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "✅ Management Server Setup Complete! Log out and log back in for Docker group changes to take effect."