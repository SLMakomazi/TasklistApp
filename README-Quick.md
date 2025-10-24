# 🚀 TasklistApp - Quick Reference

**Status: MicroK8s + ArgoCD Ready | CI/CD: GHCR Active | Deployment: VM + Kubernetes**

## 🎯 One-Minute Setup (Fresh Laptop)

```bash
# 1. Clone repo
git clone https://github.com/slmakomazi/TasklistApp.git
cd TasklistApp

# 2. Start MicroK8s (WSL Ubuntu)
microk8s start
microk8s enable ingress dns dashboard metrics-server registry hostpath-storage

# 3. Setup kubectl alias
echo "alias kubectl='microk8s kubectl'" >> ~/.bashrc && source ~/.bashrc

# 4. Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 5. Port-forward ArgoCD (port 9090)
kubectl port-forward svc/argocd-server -n argocd 9090:443 &

# 6. Get ArgoCD password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# 7. Access ArgoCD: https://localhost:9090 (admin / password above)

# 8. Deploy app
kubectl apply -f k8s/argocd-application.yaml

# 9. Port-forward app (port 8080)
kubectl port-forward -n tasklistapp svc/tasklistapp-service 8080:80 &

# 10. Access: http://localhost:8080/api/tasks
```

## 🔧 Key Commands

```bash
# Cluster status
microk8s status
kubectl get nodes

# ArgoCD
kubectl get applications -n argocd
kubectl port-forward svc/argocd-server -n argocd 9090:443

# Application
kubectl get pods -n tasklistapp
kubectl port-forward -n tasklistapp svc/tasklistapp-service 8080:80

# Logs
kubectl logs -l app=tasklistapp -n tasklistapp -f

# Secrets (base64 encode)
echo -n "password" | base64
```

## 🌐 Access URLs

- **ArgoCD**: https://localhost:9090 (admin / [get password])
- **TasklistApp**: http://localhost:8080/api/tasks
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **Health Check**: http://localhost:8080/actuator/health

## 📊 Tech Stack

- **Backend**: Spring Boot 3.3.4 + Java 17
- **Database**: PostgreSQL 16 (persistent)
- **Deployment**: Kubernetes (MicroK8s) + ArgoCD GitOps
- **CI/CD**: GitHub Actions → GHCR → ArgoCD auto-sync
- **Container**: Multi-stage Docker builds
- **Monitoring**: Health checks, metrics, logging

## 🎨 Architecture Flow

```
Developer → GitHub → GitHub Actions → GHCR → ArgoCD → MicroK8s → TasklistApp
   ↑                                                              ↓
   │                                                       Web UI/API
   └─ Code Review ← Pull Request ← Testing ← Build ← Quality Gates
```

## 🚀 Demo Script

1. **Show ArgoCD**: "Here's the GitOps dashboard showing auto-sync"
2. **Show deployment**: "3 replicas running with health checks"
3. **Show API**: "Live API with full CRUD operations at http://localhost:8080"
4. **Show persistence**: "Data survives pod restarts"
5. **Show CI/CD**: "New commits auto-deploy via ArgoCD"

## 🔧 Troubleshooting

- **kubectl fails**: `microk8s kubectl` or check alias
- **ArgoCD sync fails**: Check secrets base64 encoding
- **Pods crash**: `kubectl describe pod` + `kubectl logs`
- **Port conflicts**: Use 9090 for ArgoCD, 8080 for app

**Ready for production with GitOps, health checks, and auto-scaling!** 🚀
