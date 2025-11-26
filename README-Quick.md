# 🚀 TasklistApp - Quick Reference

**Status: Zero SSH DevOps Pipeline | Self-Hosted Runner | MicroK8s + ArgoCD | CI/CD: GHCR Active**

## 🎯 One-Minute Setup (Fresh Machine)

```bash
# 1. Clone repo
git clone https://github.com/SLMakomazi/TasklistApp.git
cd TasklistApp

# 2. WSL Ubuntu - Automated setup
chmod +x scripts/setup-microk8s-wsl.sh
./scripts/setup-microk8s-wsl.sh
source ~/.bashrc

# 3. Windows - Self-hosted runner (PowerShell Admin)
cd "C:\Users\F8884374\OneDrive - FRG\Desktop\Projects\TasklistApp\scripts"
$env:GITHUB_TOKEN = "your_github_token"
.\install-runner-service.ps1 -RepoOwner "SLMakomazi" -RepoName "TasklistApp"

# 4. Deploy via CI/CD
git push origin main

# 5. Access app
kubectl get pods -n tasklist
kubectl port-forward -n tasklist svc/tasklistapp-service 8080:80
```

## 🔧 Key Commands

```bash
# Cluster status
microk8s status
kubectl get nodes

# ArgoCD
ARGOCD_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
kubectl port-forward svc/argocd-server -n argocd $ARGOCD_PORT:80

# Application
kubectl get pods -n tasklist
kubectl port-forward -n tasklist svc/tasklistapp-service 8080:80

# Logs
kubectl logs -l app=tasklistapp -n tasklist -f

# Runner service (Windows)
Get-Service -Name "actions.runner.*"
```

## 🌐 Access URLs

- **ArgoCD**: http://$(hostname -I | awk '{print $1}'):$ARGOCD_PORT (admin / get password)
- **TasklistApp**: http://localhost:8080/api/tasks
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **Health Check**: http://localhost:8080/actuator/health

## 📊 Tech Stack

- **Backend**: Spring Boot 3.3.4 + Java 17
- **Database**: PostgreSQL 16 (persistent)
- **Deployment**: Kubernetes (MicroK8s) + ArgoCD GitOps
- **CI/CD**: GitHub Actions → GHCR → Self-hosted Runner → K8s
- **Container**: Multi-stage Docker builds
- **Testing**: JMeter load testing + comprehensive test suite
- **Zero SSH**: Self-hosted runner + local kubectl access

## 🎨 Architecture Flow

```
Developer → GitHub → CI/CD Pipeline → GHCR → Self-Hosted Runner → MicroK8s → TasklistApp
   ↑                                                              ↓
   │                                                       Web UI/API + ArgoCD
   └─ Code Review ← Pull Request ← Testing ← Build ← Quality Gates
```

## 🚀 Demo Script

1. **Show CI/CD**: "Zero SSH pipeline with self-hosted runner"
2. **Show ArgoCD**: "GitOps dashboard with auto-sync"
3. **Show deployment**: "3 replicas with health checks on MicroK8s"
4. **Show API**: "Live API with full CRUD at http://localhost:8080"
5. **Show persistence**: "PostgreSQL data survives pod restarts"
6. **Show load testing**: "JMeter performance testing integrated"

## 🔧 Troubleshooting

- **kubectl fails**: Use `microk8s kubectl` or check alias
- **Runner service**: `Get-Service -Name "actions.runner.*"` in PowerShell
- **ArgoCD sync**: Check secrets base64 encoding and namespace
- **Pods crash**: `kubectl describe pod` + `kubectl logs`
- **Port conflicts**: Use NodePort services instead of port-forward

## 📋 GitHub Repository Secrets Required

| Secret Name | Description | Last Updated |
|-------------|-------------|--------------|
| `ANSIBLE_VAULT_PASSWORD` | Password for decrypting Ansible vault files | 2 days ago |
| `DB_PASSWORD` | PostgreSQL database password | last month |
| `DB_URL` | Database connection URL | last month |
| `DB_USERNAME` | PostgreSQL database username | last month |
| `DOCKER_PASSWORD` | Docker Hub/GHCR password | last month |
| `DOCKER_USERNAME` | Docker Hub/GHCR username | last month |
| `FRONTEND_API_URL` | Frontend API endpoint configuration | last month |
| `SSH_KNOWN_HOSTS` | SSH known hosts file content | 3 weeks ago |
| `SSH_PRIVATE_KEY` | SSH private key for VM access | 3 weeks ago |
| `SUDO_PASSWORD` | WSL Ubuntu sudo password for runner | 2 days ago |
| `VM_HOST` | Target VM hostname/IP | last month |
| `VM_SSH_KEY` | SSH key for VM access | last month |
| `VM_USER` | SSH username for VM access | last month |

**Current deployment uses zero SSH approach through self-hosted runner. SSH secrets are retained for compatibility.**

**Zero SSH deployment ready with GitOps, health checks, auto-scaling, and comprehensive monitoring!** 🚀
