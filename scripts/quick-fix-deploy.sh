#!/bin/bash

# Quick fix script for deployment issues
# Run this in WSL Ubuntu to fix common problems

set -e

echo "🔧 Quick Fix for TasklistApp Deployment Issues..."

# 1. Clean up existing problematic resources
echo "🧹 Cleaning up existing resources..."
kubectl delete namespace tasklist --ignore-not-found=true
kubectl delete application tasklist-app -n argocd --ignore-not-found=true
echo "✅ Cleanup completed"

# 2. Wait for cleanup
echo "⏳ Waiting for cleanup to complete..."
sleep 10

# 3. Restart ArgoCD if needed
echo "🔄 Restarting ArgoCD..."
kubectl rollout restart deployment/argocd-server -n argocd || true
kubectl rollout restart deployment/argocd-application-controller -n argocd || true
echo "✅ ArgoCD restart initiated"

# 4. Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-application-controller -n argocd
echo "✅ ArgoCD is ready"

# 5. Create namespace
echo "📂 Creating namespace..."
kubectl create namespace tasklist
echo "✅ Namespace created"

# 6. Apply secrets (if you have your secrets ready)
echo "🔐 Creating secrets..."
# Uncomment and modify these lines with your actual secrets
# kubectl create secret generic tasklist-db-secrets \
#   --from-literal=db-username=$(echo -n "your_username" | base64) \
#   --from-literal=db-password=$(echo -n "your_password" | base64) \
#   --from-literal=db-url=$(echo -n "jdbc:postgresql://tasklist-db:5432/tasklistdb" | base64) \
#   -n tasklist || true

echo "⚠️  Please create secrets manually or run the full deployment workflow"

# 7. Apply manifests
echo "🚀 Applying Kubernetes manifests..."
kubectl apply -k k8s/ -n tasklist
echo "✅ Manifests applied"

# 8. Wait for deployments
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment -n tasklist --all || true
echo "✅ Deployments ready"

# 9. Create ArgoCD application
echo "🎯 Creating ArgoCD application..."
kubectl apply -f k8s/argocd/app.yaml -n argocd
echo "✅ ArgoCD application created"

# 10. Check final status
echo "🔍 Checking final status..."
kubectl get pods -n tasklist
kubectl get services -n tasklist
kubectl get application tasklist-app -n argocd

echo "🎉 Quick fix completed!"
echo "📋 Next steps:"
echo "   1. Port-forward ArgoCD: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   2. Access ArgoCD UI: https://localhost:8080"
echo "   3. Check application status in ArgoCD"
echo "   4. Port-forward application if needed: kubectl port-forward svc/tasklistapp-service -n tasklist 8080:80"
