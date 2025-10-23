# TasklistApp Kubernetes Deployment

This directory contains all the Kubernetes manifests needed to deploy TasklistApp with PostgreSQL to a Kubernetes cluster using ArgoCD for GitOps deployment.

## 📁 Files Overview

- `namespace.yaml` - Creates a dedicated namespace for the application
- `secrets.yaml` - Database credentials (⚠️ Update with your actual values)
- `configmap.yaml` - Application configuration for Kubernetes environment
- `postgres-pvc.yaml` - Persistent volume claim for PostgreSQL data
- `postgres-service.yaml` - Service to expose PostgreSQL within the cluster
- `postgres-deployment.yaml` - PostgreSQL deployment with persistent storage
- `service.yaml` - Service to expose TasklistApp within the cluster
- `deployment.yaml` - TasklistApp deployment with health checks and environment variables
- `ingress.yaml` - Ingress for external access (requires ingress controller)
- `argocd-application.yaml` - ArgoCD application manifest for automated deployment
- `deploy.sh` - Script to manually deploy all components

## 🚀 Quick Start

### Prerequisites
- MicroK8s cluster running
- ArgoCD installed and configured
- kubectl configured to access your cluster

### Manual Deployment
```bash
# Make sure you're in the k8s directory
cd k8s

# Run the deployment script
./deploy.sh
```

### ArgoCD Deployment (Recommended)
1. Apply the ArgoCD application manifest:
   ```bash
   kubectl apply -f argocd-application.yaml
   ```

2. Access ArgoCD dashboard and sync the application

## 🔧 Configuration

### Update Secrets
Edit `secrets.yaml` and update the base64 encoded database credentials:
- `db-username`: Base64 encode your PostgreSQL username
- `db-password`: Base64 encode your PostgreSQL password

### Update Ingress
Edit `ingress.yaml` and change the host to match your domain or IP.

### Environment Variables
The deployment uses these environment variables (configured in `deployment.yaml`):
- Database connection via Kubernetes secrets
- Application configuration via ConfigMap
- Health check endpoints for liveness and readiness probes

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    MicroK8s Cluster                     │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────┐    │
│  │              tasklistapp Namespace             │    │
│  ├─────────────────────────────────────────────────┤    │
│  │  ┌─────────────────────────────────────────┐    │
│  │  │         PostgreSQL Deployment           │    │
│  │  │  • Persistent Volume Claim              │    │
│  │  │  • Service for internal access          │    │
│  │  └─────────────────────────────────────────┘    │
│  │                                                 │
│  │  ┌─────────────────────────────────────────┐    │
│  │  │          TasklistApp Deployment         │    │
│  │  │  • 3 replicas with health checks        │    │
│  │  │  • Connects to PostgreSQL service       │    │
│  │  │  • Service for internal access          │    │
│  │  │  • Ingress for external access          │    │
│  │  └─────────────────────────────────────────┘    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

## 🔍 Monitoring

Check deployment status:
```bash
kubectl get all -n tasklistapp
kubectl get ingress -n tasklistapp
```

View logs:
```bash
kubectl logs -l app=tasklistapp -n tasklistapp
kubectl logs -l app=tasklistapp-postgresql -n tasklistapp
```

## 🆘 Troubleshooting

1. **Pods not starting**: Check logs and resource limits
2. **Database connection issues**: Verify secrets and service endpoints
3. **Ingress not working**: Ensure ingress controller is installed
4. **ArgoCD sync failing**: Check manifest syntax and permissions

## 🔗 Integration with CI/CD

The GitHub Actions workflow now pushes images to GitHub Container Registry (GHCR). ArgoCD automatically detects new images and updates the deployment when manifests change in the repository.
