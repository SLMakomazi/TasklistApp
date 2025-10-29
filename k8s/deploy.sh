#!/bin/bash

# TasklistApp Kubernetes Deployment Script
# This script deploys all Kubernetes manifests for the TasklistApp

set -e

echo "🚀 Starting TasklistApp Kubernetes Deployment..."

# Apply namespace first
echo "📦 Creating namespace..."
kubectl apply -f namespace.yaml

# Apply secrets and config
echo "🔐 Applying secrets and configuration..."
kubectl apply -f backend-manifests/backend-secrets.yaml -n tasklistapp
kubectl apply -f backend-manifests/backend-configmap.yaml -n tasklistapp

# Apply PostgreSQL components
echo "🗄️ Deploying PostgreSQL..."
kubectl apply -f postgres-manifests/postgres-pvc.yaml -n tasklistapp
kubectl apply -f postgres-manifests/postgres-service.yaml -n tasklistapp
kubectl apply -f postgres-manifests/postgres-deployment.yaml -n tasklistapp

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/tasklistapp-postgresql-deployment -n tasklistapp

# Apply application components
echo "📱 Deploying TasklistApp..."
kubectl apply -f backend-manifests/backend-service.yaml -n tasklistapp
kubectl apply -f backend-manifests/backend-deployment.yaml -n tasklistapp
kubectl apply -f ingress.yaml -n tasklistapp

# Wait for application to be ready
echo "⏳ Waiting for TasklistApp to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/tasklistapp-deployment -n tasklistapp

echo "✅ Deployment completed successfully!"
echo ""
echo "🌐 Access your application:"
echo "   - Port forward: kubectl port-forward -n tasklistapp svc/tasklistapp-service 8080:80"
echo "   - Service IP: kubectl get svc -n tasklistapp"
echo "   - Check ingress: kubectl get ingress -n tasklistapp"
echo "   - View logs: kubectl logs -l app=tasklistapp -n tasklistapp -f"
echo ""
echo "📊 Check status:"
echo "   - kubectl get pods -n tasklistapp"
echo "   - kubectl get services -n tasklistapp"
echo "   - kubectl get ingress -n tasklistapp"
echo "   - kubectl get pvc -n tasklistapp"
