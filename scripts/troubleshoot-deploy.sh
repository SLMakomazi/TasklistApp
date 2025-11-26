#!/bin/bash

# Troubleshooting script for TasklistApp deployment
# This script helps diagnose and fix common deployment issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

NAMESPACE="tasklist"
ARGOCD_NAMESPACE="argocd"

print_status "Starting TasklistApp deployment troubleshooting..."

# 1. Check MicroK8s status
print_status "=== Checking MicroK8s Status ==="
if ! microk8s status --wait-ready; then
    print_error "MicroK8s is not ready"
    exit 1
fi
print_success "MicroK8s is running"

# 2. Check kubectl access
print_status "=== Checking kubectl Access ==="
mkdir -p $HOME/.kube
microk8s config > $HOME/.kube/config
chmod 600 $HOME/.kube/config

if ! kubectl cluster-info; then
    print_error "Cannot access Kubernetes cluster"
    exit 1
fi
print_success "kubectl access configured"

# 3. Check namespaces
print_status "=== Checking Namespaces ==="
kubectl get namespaces | grep -E "(argocd|tasklist)" || true

# 4. Check ArgoCD status
print_status "=== Checking ArgoCD Status ==="
if kubectl get namespace argocd >/dev/null 2>&1; then
    echo "ArgoCD namespace exists"
    kubectl get pods -n argocd
    kubectl get deployment -n argocd
    
    # Check if ArgoCD is ready
    ARGOCD_READY=$(kubectl get deployment -n argocd -o jsonpath='{.items[*].status.readyReplicas}' | tr ' ' '\n' | grep -v '^0$' | wc -l)
    ARGOCD_TOTAL=$(kubectl get deployment -n argocd --no-headers | wc -l)
    
    if [ "$ARGOCD_READY" -eq "$ARGOCD_TOTAL" ]; then
        print_success "All ArgoCD deployments are ready"
    else
        print_warning "Some ArgoCD deployments are not ready ($ARGOCD_READY/$ARGOCD_TOTAL)"
        
        # Show problematic deployments
        kubectl get deployment -n argocd -o custom-columns=NAME:.metadata.name,READY:.status.readyReplicas,DESIRED:.spec.replicas | grep -v "readyReplicas.*[0-9]"
    fi
else
    print_warning "ArgoCD namespace not found"
fi

# 5. Check application namespace
print_status "=== Checking Application Namespace ==="
if kubectl get namespace $NAMESPACE >/dev/null 2>&1; then
    echo "Application namespace exists"
    kubectl get pods -n $NAMESPACE
    kubectl get deployment -n $NAMESPACE
    kubectl get services -n $NAMESPACE
    kubectl get secrets -n $NAMESPACE
else
    print_warning "Application namespace not found"
fi

# 6. Check ArgoCD application
print_status "=== Checking ArgoCD Application ==="
if kubectl get application tasklist-app -n argocd >/dev/null 2>&1; then
    echo "ArgoCD application exists"
    kubectl get application tasklist-app -n argocd -o wide
    
    # Check application status
    APP_STATUS=$(kubectl get application tasklist-app -n argocd -o jsonpath='{.status.health.status}')
    SYNC_STATUS=$(kubectl get application tasklist-app -n argocd -o jsonpath='{.status.sync.status}')
    
    echo "Health Status: $APP_STATUS"
    echo "Sync Status: $SYNC_STATUS"
    
    if [ "$APP_STATUS" = "Healthy" ] && [ "$SYNC_STATUS" = "Synced" ]; then
        print_success "ArgoCD application is healthy and synced"
    else
        print_warning "ArgoCD application has issues"
        
        # Show application conditions
        kubectl get application tasklist-app -n argocd -o jsonpath='{.status.conditions}' | jq . || echo "Cannot parse conditions"
    fi
else
    print_warning "ArgoCD application not found"
fi

# 7. Check recent events
print_status "=== Recent Events ==="
echo "ArgoCD namespace events:"
kubectl get events -n argocd --sort-by='.lastTimestamp' | tail -5

echo "Application namespace events:"
kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp' | tail -5

# 8. Check resource usage
print_status "=== Resource Usage ==="
kubectl top nodes 2>/dev/null || print_warning "Metrics server not available"
kubectl top pods -n argocd 2>/dev/null || print_warning "Pod metrics not available"
kubectl top pods -n $NAMESPACE 2>/dev/null || print_warning "Pod metrics not available"

# 9. Check logs for problematic pods
print_status "=== Checking Logs ==="
# Find pods with issues
PROBLEM_PODS=$(kubectl get pods -n $NAMESPACE -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.phase}{"\n"}{end}' | grep -v "Running\|Succeeded" || true)

if [ -n "$PROBLEM_PODS" ]; then
    echo "Found problematic pods:"
    echo "$PROBLEM_PODS" | while read pod status; do
        pod_name=$(echo $pod | cut -d' ' -f1)
        echo "Logs for pod $pod_name (status: $(echo $pod | cut -d' ' -f2)):"
        kubectl logs -n $NAMESPACE $pod_name --tail=10 || echo "Cannot get logs"
        echo "---"
    done
else
    print_success "No problematic pods found"
fi

# 10. Network connectivity test
print_status "=== Network Connectivity Test ==="
# Test if services are accessible
BACKEND_SVC=$(kubectl get svc -n $NAMESPACE --no-headers | grep -E "(api|backend)" | awk '{print $1}' | head -1)
if [ -n "$BACKEND_SVC" ]; then
    echo "Testing connectivity to $BACKEND_SVC service..."
    kubectl run test-pod --image=curlimages/curl --rm -i --restart=Never -- \
        curl -f -s --connect-timeout 5 "http://$BACKEND_SVC.$NAMESPACE.svc.cluster.local/actuator/health" || \
        print_warning "Cannot connect to backend service"
else
    print_warning "Backend service not found"
fi

# 11. Generate summary
print_status "=== Troubleshooting Summary ==="
echo "Commands to manually fix issues:"
echo
echo "1. Restart ArgoCD deployments:"
echo "   kubectl rollout restart deployment/argocd-server -n argocd"
echo "   kubectl rollout restart deployment/argocd-application-controller -n argocd"
echo
echo "2. Restart application deployments:"
echo "   kubectl rollout restart deployment -n $NAMESPACE"
echo
echo "3. Force ArgoCD sync:"
echo "   kubectl patch application tasklist-app -n argocd -p '{\"spec\":{\"sync\":{\"forced\":true}}}' --type=merge"
echo
echo "4. Clean up and redeploy:"
echo "   kubectl delete namespace $NAMESPACE"
echo "   kubectl delete application tasklist-app -n argocd"
echo "   # Then run the deployment again"
echo
echo "5. Check ArgoCD UI:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   # Access at https://localhost:8080"
echo

print_success "Troubleshooting completed"
