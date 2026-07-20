# AWS GitOps Infrastructure & Automated CI/CD Pipeline Suite

## 📋 Project Overview

A **production-ready, fully automated CI/CD pipeline** that orchestrates containerized application deployment on Amazon EKS (Elastic Kubernetes Service) using a **GitOps-first architecture**. This suite automates the entire workflow from source code commit to live Kubernetes rollout, eliminating manual deployment steps and reducing infrastructure provisioning time.

**Key Capabilities:**
- Automated Docker image builds and ECR registry management
- Jenkins-driven CI/CD orchestration with webhook triggers
- GitOps-driven deployment synchronization via ArgoCD
- Complete EKS cluster provisioning and lifecycle management
- Declarative infrastructure-as-code approach with Bash automation
- Health-aware rolling updates with graceful pod transitions
- Comprehensive monitoring and troubleshooting commands

---

## 🏗️ Architecture Overview

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        AWS GitOps CI/CD Deployment Flow                      │
└──────────────────────────────────────────────────────────────────────────────┘

                              ┌─────────────────┐
                              │ Developer Push  │
                              │   to GitHub     │
                              └────────┬────────┘
                                       │
                                       ▼
                         ┌─────────────────────────┐
                         │   GitHub Webhook        │
                         │  (Trigger Event)        │
                         └────────────┬────────────┘
                                      │
                                      ▼
                    ┌─────────────────────────────────┐
                    │  Jenkins CI Pipeline             │
                    │  (node-app-ci Job)              │
                    │  ├─ Git Checkout               │
                    │  ├─ Docker Build               │
                    │  └─ ECR Registry Push          │
                    └────────────┬────────────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────┐
                    │  Amazon ECR Registry     │
                    │  (Docker Image Storage)  │
                    └────────────┬─────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────────────┐
                    │  Jenkins Update-Manifest Job     │
                    │  ├─ Checkout Manifest Repo      │
                    │  ├─ Update Deployment YAML      │
                    │  └─ Commit & Push to GitHub     │
                    └────────────┬─────────────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────────┐
                    │  Kubernetes Manifest Repo    │
                    │  (GitOps Source of Truth)    │
                    └────────────┬─────────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────────┐
                    │  ArgoCD Auto-Sync            │
                    │  (Continuous Deployment)    │
                    └────────────┬─────────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────────┐
                    │  Amazon EKS Cluster          │
                    │  ├─ Pod Deployment           │
                    │  ├─ Service Rollout          │
                    │  └─ Load Balancer Sync       │
                    └────────────┬─────────────────┘
                                 │
                                 ▼
                    ┌──────────────────────────────┐
                    │  AWS Load Balancer           │
                    │  (External Access)           │
                    └──────────────────────────────┘

Timeline: ~2-5 minutes from push to production rollout
Availability: Blue-green rolling updates with zero downtime
```

---

## 📂 Directory Structure

```
aws-gitops-infrastructure/
│
├── 📄 README.md                              # Project documentation (this file)
│
├── 📁 scripts/                               # Infrastructure provisioning & management
│   ├── setup-management-server.sh            # Install AWS CLI, kubectl, eksctl, Docker, Helm
│   ├── setup-jenkins.sh                      # Configure Jenkins, Java 17, Docker integration
│   ├── create-eks-cluster.sh                 # Provision EKS cluster with auto-scaling workers
│   └── cleanup-resources.sh                  # Teardown cluster & AWS resources
│
├── 📁 pipelines/                             # Jenkins pipeline definitions
│   ├── Jenkinsfile.ci                        # CI Stage: Git → Docker Build → ECR Push
│   │   Environment: AWS_ACCOUNT_ID, AWS_REGION, ECR_REPO_NAME
│   │   Stages: Checkout, Build, ECR Auth, Push, Trigger Manifest Update
│   │
│   └── Jenkinsfile.update-manifest           # CD Stage: Manifest Update → Git Commit
│       Environment: MANIFEST_REPO_URL, GIT_CREDENTIALS_ID
│       Stages: Checkout, YAML Update, Git Push
│
└── 📁 manifests/                             # Kubernetes declarative YAML files
    ├── deployment.yaml                       # Pod deployment spec with image tag reference
    ├── service.yaml                          # LoadBalancer/ClusterIP service configuration
    └── [namespace.yaml]                      # (Optional) Namespace isolation
```

**Key Configuration Points:**
- **scripts/**: All shell scripts require `chmod +x` before execution
- **pipelines/**: Jenkins jobs pull these files; configure credentials in Jenkins before running
- **manifests/**: ArgoCD monitors this repository for changes; image tags auto-update via Jenkins

---

## 🚀 Quick Start Guide

### Prerequisites

Before starting, ensure you have:
- AWS account with appropriate IAM permissions (EC2, EKS, ECR)
- Two GitHub repositories: one for application code, one for Kubernetes manifests
- Jenkins server infrastructure (EC2 instance or self-managed)
- Management machine for `kubectl` and `eksctl` operations

### Step 1: Make Scripts Executable

```bash
# Clone or download this repository
git clone https://github.com/your-org/aws-gitops-infrastructure.git
cd aws-gitops-infrastructure

# Grant execute permissions to all shell scripts
chmod +x scripts/*.sh

# Verify permissions
ls -la scripts/
```

### Step 2: Setup Management Server

The management server is your command-and-control node for cluster provisioning and monitoring.

```bash
# SSH into your management EC2 instance
ssh -i your-key.pem ubuntu@<management-server-ip>

# Navigate to the scripts directory
cd /path/to/scripts

# Run the management server setup script
# Installs: Docker, AWS CLI v2, kubectl, eksctl, Helm
./setup-management-server.sh

# Verify installations
docker --version
aws --version
kubectl version --client
eksctl version
helm version
```

**Expected Output:**
```
Docker version 24.x.x, build xxxxxx
aws-cli/2.x.x Python/x.x.x Linux/x.x.x
Client Version: v1.28.x
eksctl 0.x.x
version.BuildInfo{Version:"v3.x.x", ...}
```

### Step 3: Provision Jenkins Server

The Jenkins server orchestrates your CI/CD workflows.

```bash
# SSH into your Jenkins EC2 instance
ssh -i your-key.pem ubuntu@<jenkins-server-ip>

# Navigate to the scripts directory
cd /path/to/scripts

# Run the Jenkins setup script
# Installs: Java 17 OpenJDK, Jenkins, Docker integration
./setup-jenkins.sh

# Retrieve Jenkins initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Access Jenkins UI (wait 2-3 minutes for startup)
# Open browser: http://<jenkins-server-ip>:8080
# Use initial admin password to login and configure
```

**Post-Installation Configuration in Jenkins Web UI:**
1. Install recommended plugins (Maven, Git, Pipeline, Docker, EC2, AWS plugins)
2. Configure GitHub credentials in **Manage Jenkins → Credentials**
3. Add AWS IAM credentials for ECR access
4. Create GitHub Personal Access Token and store in Jenkins credentials manager
5. Set up webhook in GitHub repository: `http://<jenkins-ip>:8080/github-webhook/`

### Step 4: Create EKS Cluster

The EKS cluster is your Kubernetes control plane and worker nodes.

```bash
# SSH into your management server
ssh -i your-key.pem ubuntu@<management-server-ip>

cd /path/to/scripts

# Before running, edit the cluster configuration (optional)
# Defaults: cluster-name=dev-cluster, region=ap-south-1, node-type=t3.medium
cat create-eks-cluster.sh

# Provision the EKS cluster (takes ~15-20 minutes)
./create-eks-cluster.sh

# Verify cluster status and retrieve kubeconfig
kubectl get nodes
kubectl get pods -A
```

**Output Example:**
```
NAME                          STATUS   ROLES    AGE   VERSION
ip-192-168-x-x.ec2.internal   Ready    <none>   5m    v1.28.x
ip-192-168-x-x.ec2.internal   Ready    <none>   5m    v1.28.x
```

### Step 5: Deploy ArgoCD

ArgoCD continuously synchronizes your Kubernetes cluster with the manifest repository.

```bash
# From your management server with kubectl access

# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD using official Helm chart
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd -n argocd --values argocd-values.yaml

# Forward ArgoCD server port to local machine
kubectl port-forward svc/argocd-server -n argocd 8443:443

# Retrieve ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Access ArgoCD UI
# Open browser: https://localhost:8443
# Username: admin
# Password: (from above command)

# Add your Kubernetes manifest repository to ArgoCD
# Credentials → Repositories → Connect using HTTPS (GitHub URL)
# Create Application pointing to your manifest repository path
```

### Step 6: Configure Jenkins Pipelines

Create two Jenkins jobs that reference your Jenkinsfile scripts.

**Job 1: node-app-ci (CI Pipeline)**
```
New Item → Pipeline
Name: node-app-ci
Definition: Pipeline script from SCM
SCM: Git
Repository URL: https://github.com/your-org/node-app.git
Branch: */main
Script Path: Jenkinsfile.ci
Build Triggers: GitHub hook trigger for GITScm polling
```

**Job 2: update-manifest (CD Pipeline)**
```
New Item → Pipeline
Name: update-manifest
Definition: Pipeline script from SCM
SCM: Git
Repository URL: https://github.com/your-org/aws-gitops-infrastructure.git
Branch: */main
Script Path: Jenkinsfile.update-manifest
Parameters: IMAGE_TAG (string, default: latest)
```

### Step 7: Validate End-to-End Flow

```bash
# 1. Trigger the CI pipeline manually (or via GitHub push)
# Navigate to Jenkins → node-app-ci → Build Now

# 2. Monitor build logs
# Jenkins → node-app-ci → Build #X → Console Output

# 3. Verify Docker image in ECR
aws ecr describe-images \
  --repository-name node-app \
  --region ap-south-1

# 4. Check manifest repository for updated deployment.yaml
# GitHub → Commits (verify IMAGE_TAG was updated)

# 5. Monitor ArgoCD sync
# ArgoCD UI → Applications → Check sync status
# kubectl get pods -l app=node-app

# 6. Test application via load balancer
kubectl get service -l app=node-app
# Note the EXTERNAL-IP and curl it
curl http://<EXTERNAL-IP>
```

---

## 🔄 Rolling Updates & Health Check Behavior

This section explains the deployment lifecycle and timing expectations when a new Docker image is pushed.

### Pod Lifecycle Timeline

```
Stage                              Duration       Action
────────────────────────────────────────────────────────────────────
1. ArgoCD Sync Detection           ~5-10s         ArgoCD polls Git repository
2. Manifest Fetch & Parse          ~3-5s          ArgoCD retrieves updated deployment.yaml
3. Kubernetes Patch Request        ~2s            API server applies deployment patch
4. New Pod Initialization          ~5-15s         Scheduler assigns pod to node
5. Container Pull & Start          ~10-30s        Docker pulls ECR image, starts container
6. Application Startup             ~5-10s         Node.js/app initialization
7. Readiness Probe Check           ~5-10s         K8s verifies app is ready for traffic
8. LoadBalancer De-register Old    ~10-15s        AWS LB removes old pod from rotation
9. Grace Period (Old Pod Drain)    ~30s default   Old pod completes existing requests
10. New Pod Traffic Routing        ~5s            LB starts sending traffic to new pod
────────────────────────────────────────────────────────────────────
Total End-to-End Time              ~1-3 minutes
```

### Readiness & Liveness Probes

Ensure your deployment.yaml includes proper health checks:

```yaml
spec:
  containers:
  - name: node-app
    image: <ECR-URL>/node-app:latest
    
    # Readiness: Is app ready to serve traffic?
    readinessProbe:
      httpGet:
        path: /health
        port: 3000
      initialDelaySeconds: 10
      periodSeconds: 5
      timeoutSeconds: 3
      successThreshold: 1
      failureThreshold: 3
    
    # Liveness: Is pod still alive?
    livenessProbe:
      httpGet:
        path: /health
        port: 3000
      initialDelaySeconds: 15
      periodSeconds: 10
      timeoutSeconds: 3
      failureThreshold: 3
    
    # Graceful shutdown
    lifecycle:
      preStop:
        exec:
          command: ["/bin/sh", "-c", "sleep 15"]
```

### AWS Load Balancer Registration Delay

After your pod becomes ready, the AWS Load Balancer requires additional time to register and health-check the new target:

1. **Target Registration** (~5s): Pod added to target group
2. **Initial Health Checks** (~10-20s): LB sends health check requests
3. **Traffic Routing** (~5-10s): LB moves pod to "healthy" state and starts routing traffic

**Total LB Delay: ~20-40 seconds** (in addition to pod initialization time)

### Avoiding Service Disruption

To minimize downtime during deployments:

- Set `maxSurge: 1` and `maxUnavailable: 0` in your deployment spec
- Configure proper readiness probes with short initial delays
- Use pod disruption budgets to prevent forced terminations
- Monitor metrics before and after deployments

---

## 📊 Useful kubectl Monitoring Commands

### Cluster & Node Health

```bash
# Cluster info and API server health
kubectl cluster-info
kubectl get nodes -o wide

# Detailed node status (CPU, memory, disk pressure)
kubectl describe node <node-name>

# Top resource consumers across cluster
kubectl top nodes
kubectl top pods -A --sort-by=memory
```

### Pod Monitoring & Troubleshooting

```bash
# List all pods across namespaces
kubectl get pods -A

# Get detailed pod information with age
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,AGE:.metadata.creationTimestamp,READY:.status.conditions[?(@.type=="Ready")].status

# Watch pod status in real-time
kubectl get pods -w

# Describe pod for events and conditions
kubectl describe pod <pod-name> -n <namespace>

# Get pod logs
kubectl logs <pod-name> -n <namespace>

# Stream live logs
kubectl logs -f <pod-name> -n <namespace>

# View logs from previous pod (if crashed)
kubectl logs <pod-name> -n <namespace> --previous

# Execute command inside pod
kubectl exec -it <pod-name> -n <namespace> -- /bin/bash
```

### Deployment & Rollout Status

```bash
# Check deployment status
kubectl get deployment -n <namespace>

# Monitor rollout progress in real-time
kubectl rollout status deployment/<deployment-name> -n <namespace>

# View rollout history
kubectl rollout history deployment/<deployment-name> -n <namespace>

# Check specific rollout revision
kubectl rollout history deployment/<deployment-name> --revision=2 -n <namespace>

# Rollback to previous version (if needed)
kubectl rollout undo deployment/<deployment-name> -n <namespace>
kubectl rollout undo deployment/<deployment-name> --to-revision=2 -n <namespace>
```

### Service & Load Balancer Status

```bash
# List all services and their endpoints
kubectl get svc -A -o wide

# Get LoadBalancer external IP (may take 1-2 minutes)
kubectl get svc <service-name> -n <namespace> -w

# Describe service to see endpoint mapping
kubectl describe svc <service-name> -n <namespace>

# Test connectivity to service (create debug pod)
kubectl run -it --rm debug --image=busybox --restart=Never -- wget -O- http://<service-name>:<port>
```

### ArgoCD Monitoring

```bash
# Check ArgoCD Application status
kubectl get applications -n argocd

# Describe ArgoCD Application (shows sync status, health)
kubectl describe application <app-name> -n argocd

# View ArgoCD Application logs
kubectl logs -f deployment/argocd-application-controller -n argocd

# Check ArgoCD Repo Server status
kubectl get deployment -n argocd
kubectl logs -f deployment/argocd-repo-server -n argocd
```

### Resource Quotas & Limits

```bash
# View resource requests and limits
kubectl describe node <node-name>

# Check pod resource usage
kubectl top pod <pod-name> -n <namespace>

# View resource quotas in namespace
kubectl describe resourcequota -n <namespace>
```

### Event Monitoring

```bash
# Watch cluster events in real-time
kubectl get events -A -w

# Filter events by namespace
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# Get events for specific pod
kubectl get events --field-selector involvedObject.name=<pod-name> -n <namespace>
```

### Common Debugging Scenarios

```bash
# CrashLoopBackOff: Check pod logs and previous logs
kubectl logs <pod-name> -n <namespace> --previous
kubectl describe pod <pod-name> -n <namespace>

# Pending pod: Check node resources and scheduling
kubectl describe pod <pod-name> -n <namespace>
kubectl top nodes

# ImagePullBackOff: Verify ECR credentials and image availability
kubectl get secrets -n <namespace>
aws ecr describe-images --repository-name node-app --region ap-south-1

# Connection timeout: Test DNS and network policies
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup <service-name>
```

---

## 🧹 Resource Cleanup & Cost Management

**⚠️ WARNING:** Running AWS resources incur charges. Perform cleanup when development is complete.

### Cleanup Process

```bash
# Step 1: Delete all Kubernetes applications and services
# This will tear down LoadBalancers and associated AWS resources
kubectl delete all --all -A

# Step 2: Remove ArgoCD
kubectl delete namespace argocd

# Step 3: Execute cleanup script (deletes EKS cluster)
# SSH into management server
ssh -i your-key.pem ubuntu@<management-server-ip>
cd /path/to/scripts

# This script will prompt for confirmation before deletion
./cleanup-resources.sh

# Enter 'y' when prompted
```

### What Gets Deleted

```
✓ EKS Cluster (control plane)
✓ Worker Node Groups
✓ Auto-Scaling Groups
✓ Load Balancers (AWS ELB)
✓ ENI (Elastic Network Interfaces)
✓ VPC & Subnets (if created by eksctl)
✓ Security Groups (if created by eksctl)
✓ IAM Roles (if created by eksctl)
```

**Resources NOT automatically deleted (delete manually):**
- EC2 instances (Management and Jenkins servers) → Use AWS Console or AWS CLI
- ECR Repository → `aws ecr delete-repository --repository-name node-app`
- CloudWatch Logs → `aws logs delete-log-group --log-group-name /aws/eks/...`
- S3 buckets (if any) → AWS Console
- IAM roles/policies (if not created by eksctl) → AWS Console

### Estimated AWS Costs

| Resource | Instance Type | Hourly Cost | Monthly (730h) |
|----------|---------------|------------|----------------|
| EKS Control Plane | - | $0.10 | $73 |
| Worker Nodes | t3.medium × 2 | $0.0416 × 2 | $60 |
| Load Balancer | Classic/NLB | $0.025 | $18 |
| Data Transfer | Egress | Variable | $5-50 |
| **Total Estimated** | | | **$156-200** |

To minimize costs:
- Delete cluster when not in use
- Use `t3.small` instances for dev environments
- Set auto-scaling to scale down during off-hours
- Use spot instances for non-critical workloads

### Cost Cleanup Verification

```bash
# Verify no resources remain
aws ec2 describe-instances --region ap-south-1
aws eks list-clusters --region ap-south-1
aws ecr list-repositories --region ap-south-1
aws elbv2 describe-load-balancers --region ap-south-1
```

---

## 🔐 Security Best Practices

### GitHub Credentials Management

**Never commit credentials to repository.** Store in Jenkins Credentials Manager:

```bash
# Jenkins UI: Manage Jenkins → Credentials → System → Global Credentials
# Store GitHub PAT and AWS credentials here, not in code
```

### ECR Access Control

```bash
# Restrict ECR repository access via IAM policy
aws ecr set-repository-policy \
  --repository-name node-app \
  --policy-text file://ecr-policy.json
```

### Jenkins Server Hardening

- Enable SSL/TLS on Jenkins UI
- Use strong authentication (LDAP/OAuth preferred over local)
- Limit SSH access to Jenkins server via Security Group
- Run Jenkins with least-privilege IAM role

### EKS Network Security

```bash
# Restrict API server access
eksctl utils describe-addon-versions --cluster=dev-cluster --region=ap-south-1

# Use network policies to limit pod-to-pod communication
kubectl apply -f network-policy.yaml
```

---

## 📖 Additional Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Jenkins Official Documentation](https://www.jenkins.io/doc/)
- [ArgoCD User Guide](https://argo-cd.readthedocs.io/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Docker Registry Documentation](https://docs.docker.com/registry/)

---

## Quick Command Reference

```bash
# Infrastructure Setup
chmod +x scripts/*.sh
./scripts/setup-management-server.sh
./scripts/setup-jenkins.sh
./scripts/create-eks-cluster.sh

# Cluster Access
aws eks update-kubeconfig --name dev-cluster --region ap-south-1
kubectl get nodes
kubectl get pods -A

# Pipeline Monitoring
kubectl logs -f deployment/jenkins -n jenkins
kubectl get pods -w
kubectl rollout status deployment/node-app

# Cleanup
./scripts/cleanup-resources.sh
```
