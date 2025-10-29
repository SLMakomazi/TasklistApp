#!/bin/bash
set -e

# Create directory for certificates
mkdir -p certs
cd certs

# Generate local SSL certificates
mkcert -install
mkcert -cert-file cert.pem -key-file key.pem "tasklistapp.local" "api.tasklistapp.local"

# Create TLS secret in Kubernetes
microk8s kubectl create secret tls local-tls -n tasklistapp \
  --cert=cert.pem \
  --key=key.pem \
  --dry-run=client -o yaml | microk8s kubectl apply -f -

# Go back to project root
cd ..

# Apply all configurations
microk8s kubectl apply -f k8s/namespace.yaml
microk8s kubectl apply -f k8s/backend-manifests/
microk8s kubectl apply -f k8s/frontend-manifests/
microk8s kubectl apply -f k8s/ingress/

echo ""
echo "=== HTTPS Setup Complete ==="
echo "Add these entries to your /etc/hosts file:"
echo "127.0.0.1    tasklistapp.local api.tasklistapp.local"
echo ""
echo "Access the application at:"
echo "- Frontend: https://tasklistapp.local"
echo "- Backend API: https://api.tasklistapp.local"
