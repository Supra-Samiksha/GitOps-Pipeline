#!/bin/bash
# ==============================================================================
# Script: setup-jenkins.sh
# Description: Installs Java OpenJDK 17, Jenkins, and configures Docker execution permissions.
# ==============================================================================

set -e

echo "🚀 Starting Jenkins Installation..."

# Install OpenJDK 17
echo "☕ Installing Java 17..."
sudo apt-get update -y
sudo apt-get install -y openjdk-17-jdk wget gnupg

# Add Jenkins Repository
echo "🔑 Adding Jenkins GPG Key & Repository..."
sudo mkdir -p /usr/share/keyrings
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins & Docker
sudo apt-get update -y
sudo apt-get install -y jenkins docker.io

# Enable Docker for Jenkins
sudo usermod -aG docker jenkins
sudo usermod -aG docker $USER

# Start Jenkins
sudo systemctl enable jenkins
sudo systemctl restart jenkins
sudo systemctl restart docker

echo "✅ Jenkins installation complete!"
echo "🔑 Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword