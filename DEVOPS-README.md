# Complete DevOps Pipeline Setup Guide

This guide provides step-by-step instructions for setting up and running the complete DevOps pipeline for the TasklistApp using GitHub Actions, self-hosted runners, MicroK8s, ArgoCD, and JMeter with **zero SSH deployment**.

## 🏗️ Architecture Overview

```
VS Code → GitHub → CI/CD (GitHub Actions) → GHCR → Self-hosted Runner → MicroK8s → ArgoCD → Application
                                            ↓
                                         JMeter (Load Testing)
```

### Key Features:
- **Zero SSH Deployment**: Uses self-hosted runner and local kubectl access
- **Automated CI/CD**: Sequential pipeline with tests, builds, and deployment
- **GitOps**: ArgoCD manages Kubernetes deployments automatically
- **Performance Testing**: Integrated JMeter load testing
- **Container Registry**: GitHub Container Registry (GHCR) for images

## 📋 Prerequisites

### Windows Host:
- Windows 10/11 with WSL2
- GitHub account with repository access
- Administrator privileges (for runner service)

### WSL Ubuntu:
- Ubuntu 20.04/22.04 LTS
- sudo privileges

## 🚀 Setup Instructions

### 1. WSL Ubuntu Environment Setup

#### 1.1 Install WSL Ubuntu
```powershell
# In PowerShell as Administrator
wsl --install -d Ubuntu
```

#### 1.2 Automated MicroK8s + ArgoCD Setup
```bash
# Clone repository first
git clone https://github.com/SLMakomazi/TasklistApp.git
cd TasklistApp

# Make setup script executable
chmod +x scripts/setup-microk8s-wsl.sh

# Run the complete setup script
./scripts/setup-microk8s-wsl.sh
```

**The script automatically installs:**
- Docker and Docker Compose
- MicroK8s with required addons (dns, storage, ingress, dashboard, metrics-server, registry, hostpath-storage)
- ArgoCD with initial configuration
- JMeter for load testing
- Required dependencies and tools

#### 1.3 Post-Setup Steps
```bash
# Reload shell to apply group membership changes
source ~/.bashrc

# Update vault password
nano ~/.vault_pass.txt
# Replace with a secure password

# Verify installation
kubectl cluster-info
microk8s status
```

### 2. Windows Self-Hosted Runner Setup

#### 2.1 Install Runner Service
```powershell
# Open PowerShell as Administrator
cd "C:\Users\F8884374\OneDrive - FRG\Desktop\Projects\TasklistApp\scripts"

# Set GitHub token (create with repo and workflow scopes)
$env:GITHUB_TOKEN = "your_github_personal_access_token"

# Run installation script
.\install-runner-service.ps1 -RepoOwner "SLMakomazi" -RepoName "TasklistApp"
```

#### 2.2 Create GitHub Personal Access Token
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Generate new token with `repo` and `workflow` scopes
3. Use this token for `$env:GITHUB_TOKEN`

#### 2.3 Verify Runner Service
```powershell
# Check service status
Get-Service -Name "actions.runner.*"

# Or use the provided script
C:\Users\Wipro\actions-runner\status-runner.bat
```

### 3. Ansible Configuration

#### 3.1 Update Vault Variables
```bash
# In WSL Ubuntu
cd /path/to/TasklistApp/ansible

# Create encrypted vault file
ansible-vault create group_vars/all/vault.yml
```

Add your secure values:
```yaml
db_root_password: "your_secure_root_password"
db_name: "tasklistdb"
db_user: "tasklist_user"
db_password: "your_secure_db_password"
spring_datasource_url: "jdbc:postgresql://tasklist-db:5432/tasklistdb"
spring_datasource_username: "tasklist_user"
spring_datasource_password: "{{ db_password }}"
```

#### 3.2 Test Ansible Configuration
```bash
# Test playbook syntax (zero SSH)
ansible-playbook --syntax-check deploy_vm.yml --connection=local

# Run dry run
ansible-playbook --check deploy_vm.yml --connection=local
```

### 4. ArgoCD Configuration

#### 4.1 Access ArgoCD UI
After MicroK8s setup, get ArgoCD credentials:
```bash
# Get ArgoCD NodePort
ARGOCD_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')

# Get ArgoCD password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "ArgoCD URL: http://$(hostname -I | awk '{print $1}'):$ARGOCD_PORT"
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
```

#### 4.2 Configure ArgoCD Application
The ArgoCD application is automatically created by the deployment workflow. You can also apply it manually:
```bash
kubectl apply -f k8s/argocd/app.yaml
```

### 5. GitHub Repository Configuration

#### 5.1 Required Secrets
Add these secrets to your GitHub repository:

| Secret Name | Description |
|-------------|-------------|
| `GITHUB_TOKEN` | GitHub token with repo and workflow scopes |
| `SUDO_PASSWORD` | WSL Ubuntu sudo password (for self-hosted runner) |
| `FRONTEND_API_URL` | Frontend API URL configuration |

#### 5.2 Enable Self-Hosted Runner
1. Go to Repository Settings → Actions → Runners
2. Your self-hosted runner should appear automatically
3. Ensure it's online and has the `windows` and `self-hosted` labels

## 🔄 CI/CD Pipeline Flow

### Workflow Sequence:
1. **CI - Test Application** (`ci-test-application.yml`)
   - Triggers on push/PR to main branch
   - Runs unit and integration tests
   - Uploads test results

2. **Frontend CI - Build & Push Image** (`ci-frontend-build.yml`)
   - Triggers after successful tests
   - Builds and pushes frontend image to GHCR

3. **Backend CI - Build & Push Image** (`ci-backend-build.yml`)
   - Triggers after successful tests
   - Builds and pushes backend and database images to GHCR

4. **Deploy to Kubernetes** (`deploy-to-k8s.yml`)
   - Triggers after successful backend build
   - Deploys to MicroK8s using self-hosted runner
   - Runs smoke tests and JMeter load tests

### Manual Triggers:
All workflows support manual triggering via GitHub Actions UI.

## 🧪 Testing and Verification

### 1. Local Testing
```bash
# Build and test locally
cd app
mvn clean test

# Build Docker images
docker build -t tasklistapp:test ./app
docker build -t tasklistapp-frontend:test ./frontend
```

### 2. API Testing with Postman
Import the Postman collection from `/postman/` directory and test:
- `GET http://localhost:8080/api/tasks`
- `POST http://localhost:8080/api/tasks`
- `PUT http://localhost:8080/api/tasks/{id}`
- `DELETE http://localhost:8080/api/tasks/{id}`

### 3. Load Testing with JMeter
```bash
# Run JMeter test against Kubernetes deployment
cd /opt/jmeter
jmeter -n -t /path/to/TasklistApp/jmeter/test-plans/api-load-test.jmx \
        -l results.jtl \
        -J HOST=$(hostname -I | awk '{print $1}') \
        -J PORT=30080

# Generate HTML report
jmeter -g results.jtl -o report/
```

### 4. Kubernetes Verification
```bash
# Check deployment status
kubectl get pods,svc,ingress -n tasklist

# Check application logs
kubectl logs -f deployment/tasklistapp-deployment -n tasklist

# Access application
curl http://$(hostname -I | awk '{print $1}'):30080/api/tasks
```

## 🔧 Troubleshooting

### Common Issues:

#### 1. Runner Service Issues
```powershell
# Check service status
Get-Service -Name "actions.runner.*"

# Restart service
Restart-Service -Name "actions.runner.*"

# Check logs
Get-EventLog -LogName Application -Source "Actions Runner"
```

#### 2. MicroK8s Issues
```bash
# Check MicroK8s status
microk8s status --wait-ready

# Reset MicroK8s
microk8s stop
microk8s reset
microk8s start

# Check addons
microk8s kubectl get all -n kube-system
```

#### 3. ArgoCD Issues
```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Reset ArgoCD password
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {"admin.password": "newpassword"}}'

# Check ArgoCD application
argocd app get tasklist-app
argocd app sync tasklist-app
```

#### 4. Docker Issues
```bash
# Check Docker service
sudo systemctl status docker

# Fix Docker permissions
sudo usermod -aG docker $USER
# Log out and log back in

# Clean Docker resources
docker system prune -a
```

#### 5. Kubernetes Pod Issues
```bash
# Check pod status
kubectl get pods -n tasklist -o wide

# Describe pod
kubectl describe pod <pod-name> -n tasklist

# Check pod logs
kubectl logs <pod-name> -n tasklist

# Debug pod
kubectl exec -it <pod-name> -n tasklist -- /bin/bash
```

## 📊 Monitoring and Maintenance

### 1. Application Monitoring
- Access Spring Boot Actuator endpoints:
  - Health: `http://<host>:30080/actuator/health`
  - Metrics: `http://<host>:30080/actuator/metrics`
  - Prometheus: `http://<host>:30080/actuator/prometheus`

### 2. ArgoCD Monitoring
- Monitor sync status in ArgoCD UI
- Check application health and history
- Set up notifications for sync failures

### 3. JMeter Performance Testing
- Schedule regular load tests
- Monitor response times and error rates
- Set up alerts for performance degradation

### 4. Log Management
```bash
# View application logs
kubectl logs -f deployment/tasklistapp-deployment -n tasklist --tail=100

# View system logs
journalctl -u docker -f
journalctl -u snap.microk8s.daemon-kubelet.service -f
```

## 🔄 Backup and Recovery

### 1. Kubernetes Resources
```bash
# Backup all resources
kubectl get all -n tasklist -o yaml > tasklist-backup.yaml

# Backup specific resources
kubectl get deployment,service,configmap,secret -n tasklist -o yaml > resources-backup.yaml
```

### 2. Database Backup
```bash
# Backup PostgreSQL
kubectl exec -it postgresdb-pod-name -n tasklist -- pg_dump -U tasklist_user tasklistdb > db-backup.sql

# Restore database
kubectl exec -it postgresdb-pod-name -n tasklist -- psql -U tasklist_user tasklistdb < db-backup.sql
```

### 3. ArgoCD Configuration
```bash
# Backup ArgoCD application
argocd app get tasklist-app -o yaml > argocd-app-backup.yaml
```

## 🚀 Performance Optimization

### 1. Kubernetes Resources
- Adjust resource requests and limits based on usage
- Use Horizontal Pod Autoscaler for scaling
- Implement resource quotas

### 2. Database Optimization
- Tune PostgreSQL configuration
- Implement connection pooling
- Set up database backups

### 3. CI/CD Optimization
- Use GitHub Actions caching
- Parallelize test execution
- Optimize Docker build with multi-stage builds

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [MicroK8s Documentation](https://microk8s.io/docs)
- [ArgoCD Documentation](https://argoproj.github.io/argo-cd/)
- [JMeter Documentation](https://jmeter.apache.org/usermanual/index.html)
- [Ansible Documentation](https://docs.ansible.com/ansible/latest/)

## 🤝 Support

For issues and questions:
1. Check the troubleshooting section
2. Review GitHub Issues
3. Check application logs
4. Verify all prerequisites are met

---

**🎯 Zero SSH Achievement**: This setup uses zero SSH deployment as requested. All operations are performed through the GitHub self-hosted runner and local Kubernetes API access in WSL Ubuntu. The pipeline provides production-ready CI/CD with GitOps, monitoring, and comprehensive testing capabilities.
