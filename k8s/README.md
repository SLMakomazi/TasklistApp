# TasklistApp Kubernetes Deployment Guide

**Cluster: MicroK8s (WSL2 VM) — ArgoCD: Installed & Running — App: TasklistApp (Ready for Deployment)**

This directory contains all the Kubernetes manifests needed to deploy TasklistApp with PostgreSQL to a MicroK8s cluster using ArgoCD for GitOps deployment. The manifests are organized in a structured directory layout for better maintainability.

## 📁 Directory Structure

```
k8s/
├── README.md                    # This deployment guide
├── namespace.yaml               # Creates the 'tasklist' namespace
├── kustomization.yaml           # Kustomize configuration for all resources
├── tasklistapp-secrets.yaml     # Base64-encoded database credentials
├── ghcr-secret.yaml            # GitHub Container Registry credentials
├── serviceaccount.yaml         # Service account for the application
├── microk8s-hostpath-immediate.yaml # MicroK8s storage class
├── deploy.sh                   # Manual deployment script
├── api-manifests/              # API deployment manifests
│   ├── deployment.yaml          # Main API deployment
│   ├── service.yaml            # API service configuration
│   └── configmap.yaml          # API configuration
├── postgres-manifests/         # PostgreSQL database manifests
│   ├── deployment.yaml          # PostgreSQL deployment
│   ├── service.yaml            # PostgreSQL service
│   └── pvc.yaml                # Persistent volume claim
├── frontend-manifests/          # Frontend deployment manifests
│   ├── deployment.yaml          # Frontend deployment
│   └── service.yaml            # Frontend service
├── ingress/                     # Ingress configurations
│   └── tasklist-ingress.yaml    # External access configuration
├── monitoring/                  # Monitoring configurations
│   └── service-monitor.yaml     # Prometheus monitoring
└── argocd/                      # ArgoCD application manifests
    ├── app.yaml                # ArgoCD application definition
    ├── argocd-application.yaml  # ArgoCD application configuration
    └── argocd-ingress.yaml     # ArgoCD ingress configuration
```

## 🚀 CI/CD Integration

### Automated Deployment Workflow
The Kubernetes deployment is now fully integrated with GitHub Actions:

1. **deploy-infrastructure.yml** sets up MicroK8s and ArgoCD
2. **deploy-to-k8s.yml** applies all manifests from this directory structure
3. **ArgoCD** monitors the repository and maintains sync

### How It Works
```bash
# The deploy-to-k8s.yml workflow applies manifests in this order:
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/tasklistapp-secrets.yaml
kubectl apply -f k8s/ghcr-secret.yaml
kubectl apply -f k8s/serviceaccount.yaml
kubectl apply -f k8s/postgres-manifests/
kubectl apply -f k8s/api-manifests/
kubectl apply -f k8s/frontend-manifests/
kubectl apply -f k8s/ingress/
kubectl apply -f k8s/monitoring/
kubectl apply -f k8s/microk8s-hostpath-immediate.yaml
kubectl apply -f k8s/argocd/
```

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
The ArgoCD applications are now defined in the `argocd/` directory:

1. Apply the ArgoCD application manifests:
   ```bash
   kubectl apply -f argocd/
   ```

2. Access ArgoCD dashboard and monitor the applications

### ArgoCD Applications
- **app.yaml**: Main application that watches the k8s directory
- **argocd-application.yaml**: Additional ArgoCD configurations
- **argocd-ingress.yaml**: External access to ArgoCD UI

## 🔧 Configuration

### Update Secrets
Edit `tasklistapp-secrets.yaml` and update the base64 encoded database credentials:
- `db-username`: Base64 encode your PostgreSQL username
- `db-password`: Base64 encode your PostgreSQL password

### GHCR Credentials
Update `ghcr-secret.yaml` with GitHub Container Registry credentials for pulling images.

### Update Ingress
Edit `ingress/tasklist-ingress.yaml` and change the host to match your domain or IP.

### Environment Variables
The deployment uses these environment variables (configured in `deployment.yaml`):
- Database connection via Kubernetes secrets
- Application configuration via ConfigMap
- Health check endpoints for liveness and readiness probes

## 📋 Detailed Manifest Explanations

### namespace.yaml
Creates the `tasklist` namespace for resource isolation:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: tasklist
  labels:
    name: tasklist
```

### tasklistapp-secrets.yaml
Contains base64-encoded database credentials:
```bash
# Generate base64 values
echo -n "your_username" | base64  # For db-username
echo -n "your_password" | base64  # For db-password

# Update tasklistapp-secrets.yaml with encoded values
```

**⚠️ CRITICAL**: Update with your actual database credentials!

### api-manifests/configmap.yaml
Application configuration for Kubernetes environment:
- `LOG_LEVEL_SPRING: "INFO"` - Spring framework logging
- `LOG_LEVEL_TASKLIST: "INFO"` - Application logging
- `SERVER_PORT: "8080"` - Container port
- `JPA_SHOW_SQL: "false"` - Production SQL logging
- `SPRING_PROFILES_ACTIVE: "kubernetes"` - K8s-specific profile

### postgres-manifests/pvc.yaml
Persistent storage for PostgreSQL (5Gi hostpath storage):
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: tasklist-postgres-pvc
  namespace: tasklist
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: microk8s-hostpath  # Uses MicroK8s default storage
  resources:
    requests:
      storage: 5Gi
```

### postgres-manifests/deployment.yaml
PostgreSQL deployment with persistent storage:
- **Image**: Custom PostgreSQL image from GHCR
- **Database**: `tasklistdb` (created automatically)
- **Storage**: Uses PVC for data persistence
- **Credentials**: From Kubernetes secrets

### api-manifests/service.yaml
Internal cluster service for TasklistApp:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: tasklistapp-service
  namespace: tasklist
spec:
  selector:
    app: tasklistapp  # Matches deployment labels
  ports:
  - port: 80          # Service port
    targetPort: 8080  # Container port
  type: ClusterIP     # Internal access only
```

### api-manifests/deployment.yaml
Main application deployment with 3 replicas:
- **Image**: `ghcr.io/slmakomazi/tasklistapp:api-latest`
- **Health Checks**: Spring Boot Actuator (`/actuator/health`)
- **Environment**: Database connection via service discovery
- **Scaling**: 3 replicas for high availability

### ingress/tasklist-ingress.yaml
External access configuration:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tasklist-ingress
  namespace: tasklist
  annotations:
    kubernetes.io/ingress.class: "public"  # MicroK8s ingress controller
spec:
  rules:
  - http:  # No host specified for flexible local access
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: tasklistapp-service
            port:
              number: 80
```

### argocd/app.yaml
ArgoCD GitOps configuration:
- **Repository**: `https://github.com/slmakomazi/TasklistApp`
- **Path**: `k8s/` (watches all manifests)
- **Target**: `tasklist` namespace
- **Sync Policy**: Automated with self-healing

## 🚀 ArgoCD Setup and Access

### Automated ArgoCD Installation
ArgoCD is now automatically installed and configured by the `deploy-infrastructure.yml` GitHub Actions workflow. The workflow:
- Installs ArgoCD in the cluster
- Configures it with NodePort for external access
- Sets up the admin password
- Creates the application namespace

### Manual ArgoCD Installation (if needed)
```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD with CRDs
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

### Access ArgoCD Dashboard
```bash
# Get the NodePort (configured by infrastructure workflow)
ARGOCD_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')

# Port-forward ArgoCD UI (alternative method)
kubectl port-forward svc/argocd-server -n argocd 9090:443

# Alternative ports if 9090 taken:
# kubectl port-forward svc/argocd-server -n argocd 9091:443
# kubectl port-forward svc/argocd-server -n argocd 8081:443

# Access at: https://localhost:9090 or http://$(hostname -I | awk '{print $1}'):$ARGOCD_PORT
# Username: admin
# Password: admin123 (set by infrastructure workflow)
```

### Apply TasklistApp Applications
```bash
# Apply all ArgoCD application manifests
kubectl apply -f argocd/

# Check application status
kubectl get applications -n argocd

# View detailed sync information
kubectl describe application tasklist-app -n argocd
```

## 🔍 Monitoring and Troubleshooting

### Check Deployment Status
```bash
# All resources in namespace
kubectl get all -n tasklist

# Pods with detailed status
kubectl get pods -n tasklist -o wide

# Services and ingress
kubectl get services,ingress -n tasklist

# Persistent volumes
kubectl get pvc -n tasklist
```

### View Logs
```bash
# TasklistApp logs
kubectl logs -l app=tasklistapp -n tasklist -f

# PostgreSQL logs
kubectl logs -l app=tasklist-postgresql -n tasklist -f

# Specific pod logs
kubectl logs <pod-name> -n tasklist -f

# Previous container logs (if restarted)
kubectl logs <pod-name> -n tasklist --previous
```

### Debug Common Issues

#### Pod Issues
```bash
# Describe pod for detailed error information
kubectl describe pod <pod-name> -n tasklist

# Check events in namespace
kubectl get events -n tasklist --sort-by='.lastTimestamp'

# Check resource constraints
kubectl describe pod <pod-name> -n tasklist | grep -A 10 "Limits\|Requests"
```

#### Database Connection Issues
```bash
# Verify PostgreSQL service
kubectl get endpoints -n tasklist

# Check PostgreSQL logs
kubectl logs -l app=tasklist-postgresql -n tasklist

# Test connection from app pod
kubectl exec -it <tasklistapp-pod> -n tasklist -- nc -zv tasklist-postgresql-service 5432
```

#### Image Pull Issues
```bash
# Check image pull status
kubectl describe pod <pod-name> -n tasklist | grep -i image

# Verify image exists in GHCR
kubectl run test-image --image=ghcr.io/slmakomazi/tasklistapp:api-latest --dry-run=client -o yaml
```

#### ArgoCD Sync Issues
```bash
# Check application sync status
kubectl get applications tasklist-app -n argocd

# View sync errors
kubectl describe application tasklist-app -n argocd

# Force sync if needed
kubectl argo rollouts promote tasklist-app -n argocd
```

## 🔐 Security Considerations

### Secrets Management
```bash
# Generate base64 values for secrets
echo -n "your_username" | base64  # For db-username
echo -n "your_password" | base64  # For db-password

# Update k8s/tasklistapp-secrets.yaml with encoded values
# Example format:
# db-username: cG9zdGdyZXM=  # "postgres"
# db-password: YWRtaW4=      # "admin"
```

**⚠️ CRITICAL**: Update with your actual database credentials!

### GitHub Repository Secrets
The following secrets are configured in the GitHub repository and used by the automated workflows:

| Secret Name | Description | Used By |
|-------------|-------------|----------|
| `DB_PASSWORD` | PostgreSQL database password | deploy-to-k8s.yml |
| `DB_USERNAME` | PostgreSQL database username | deploy-to-k8s.yml |
| `DB_URL` | Database connection URL | deploy-to-k8s.yml |
| `FRONTEND_API_URL` | Frontend API endpoint configuration | deploy-to-k8s.yml |
| `SUDO_PASSWORD` | WSL Ubuntu sudo password for runner | deploy-infrastructure.yml |

**Note**: The workflows now use the zero SSH approach through self-hosted runner.

### Security Best Practices
- ✅ **Base64 Encoding**: All secrets must be base64 encoded in Kubernetes manifests
- ✅ **Namespace Isolation**: Secrets scoped to `tasklist` namespace
- ✅ **No Plaintext**: Never commit plaintext credentials to version control
- ✅ **Minimal Permissions**: Service accounts use least-privilege access
- ✅ **GitHub Secrets**: Sensitive data stored in GitHub repository secrets

## Production Security Checklist

### Authentication & Authorization
- [ ] **Database credentials** are strong and unique
- [ ] **No default passwords** (admin/admin, postgres/postgres)
- [ ] **SSH keys** are properly configured for VM access
- [ ] **GitHub tokens** have minimal required permissions

### Network Security
- [ ] **Firewall rules** restrict access to necessary ports only
- [ ] **Container security** runs as non-root user
- [ ] **Network policies** isolate namespaces
- [ ] **Ingress** uses HTTPS/TLS encryption

### Access Control
- [ ] **Kubernetes RBAC** configured with least privilege
- [ ] **Service accounts** have minimal permissions
- [ ] **Secrets encryption** enabled in cluster
- [ ] **Audit logging** enabled and monitored

## 🔑 Secret Management Tools

### Option 1: Kubernetes Secrets (Current Setup)
```yaml
# k8s/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: tasklistapp-secrets
  namespace: tasklistapp
type: Opaque
data:
  db-username: <base64-encoded-username>
  db-password: <base64-encoded-password>
```

**Pros**: Simple, built-in Kubernetes feature
**Cons**: Base64 encoding only (not encryption), stored in cluster

### Option 2: Sealed Secrets (Recommended for Production)
```bash
# Install sealed-secrets controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.18.0/controller.yaml

# Seal your secrets
kubeseal --format yaml --cert <path-to-cert> <secret.yaml > sealed-secret.yaml

# Apply sealed secret (safe to commit to Git)
kubectl apply -f sealed-secret.yaml
```

**Pros**: Secrets encrypted, safe to commit to Git
**Cons**: Requires controller installation

### Option 3: External Secret Managers
```yaml
# Example: AWS Secrets Manager integration
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secretsmanager
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
```

**Pros**: Enterprise-grade encryption, centralized management
**Cons**: Requires cloud provider setup

## 🔒 GitHub Actions Security

### Repository Secrets
```yaml
# In GitHub repository settings
- GITHUB_TOKEN: Automatic (for GHCR access)
- DOCKER_USERNAME: ${{ github.actor }}
- DOCKER_PASSWORD: ${{ secrets.GITHUB_TOKEN }}
```

### Runner Security
```yaml
# Self-hosted runner configuration
- Non-root execution
- Firewall restrictions
- Regular security updates
- Network isolation
```

### Workflow Security
```yaml
# Minimal permissions
permissions:
  contents: read      # Only read access to repo
  packages: write     # Write access to GHCR only

# Security scanning
- name: Run security scan
  uses: github/super-linter@v4
  with:
    secrets: false
```

## 📋 Secrets Validation

### Secrets Validation Commands
```bash
# Check for plaintext secrets in codebase
grep -r "password\|secret\|key\|token" . --exclude-dir=.git

# Verify all secrets are base64 encoded
kubectl get secret tasklistapp-secrets -n tasklistapp -o yaml

# Check secret references in deployments
kubectl get deployment tasklistapp-deployment -n tasklistapp -o yaml | grep -i secret
```

### Network Security Validation
```bash
# Check ingress security
kubectl get ingress -n tasklistapp -o yaml

# Verify service types
kubectl get services -n tasklistapp

# Check network policies
kubectl get networkpolicy -A
```

### Access Control Validation
```bash
# Check RBAC permissions
kubectl get roles,rolebindings -n tasklistapp

# Verify service accounts
kubectl get serviceaccounts -n tasklistapp

# Check pod security context
kubectl get pod <pod-name> -n tasklistapp -o yaml | grep -A 10 securityContext
```

## 🚨 Emergency Security Procedures

### Credential Compromise Response
```bash
# 1. Rotate all affected credentials
echo -n "new_password" | base64
# Update secrets.yaml with new values

# 2. Update Kubernetes secrets
kubectl apply -f k8s/secrets.yaml -n tasklistapp

# 3. Restart all deployments
kubectl rollout restart deployment -n tasklistapp

# 4. Update GitHub repository secrets
# Go to Repository Settings → Secrets and Variables → Actions

# 5. Update VM credentials if using SSH
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_new
```

### Suspicious Activity Monitoring
```bash
# Check ArgoCD sync history
kubectl describe application tasklistapp -n argocd

# Review GitHub Actions logs
gh run list --limit 10

# Check Kubernetes events
kubectl get events -n tasklistapp --sort-by='.lastTimestamp'

# Monitor resource usage
kubectl top pods -n tasklistapp
```

## 🔐 Encryption and Encoding

### Base64 Encoding (Kubernetes Secrets)
```bash
# Username encoding
echo -n "myusername" | base64
# Output: bXl1c2VybmFtZQ==

# Password encoding
echo -n "MyS3cure!Passw0rd" | base64
# Output: TXlTM2N1cmUhUGFzc3cwcmQ=

# Use in secrets.yaml:
# db-username: bXl1c2VybmFtZQ==
# db-password: TXlTM2N1cmUhUGFzc3cwcmQ=
```

### Verify Encoding
```bash
# Decode to verify
echo "bXl1c2VybmFtZQ==" | base64 -d
# Should output: myusername

# Check Kubernetes secret
kubectl get secret tasklistapp-secrets -n tasklistapp -o yaml | grep -A 5 "data:"
```

## 🌐 Network Security

### Firewall Configuration
```bash
# VM firewall (ufw)
sudo ufw allow ssh
sudo ufw allow 8080  # TasklistApp
sudo ufw allow 5432  # PostgreSQL (internal only)
sudo ufw deny 22     # SSH from external (use VPN)

# Kubernetes network policies
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: tasklistapp
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF
```

### HTTPS/TLS Setup
```bash
# For production ingress
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: tasklistapp-tls
  namespace: tasklistapp
spec:
  secretName: tasklistapp-tls-secret
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - your-domain.com
EOF
```

## 📊 Security Monitoring

### Security Event Monitoring
```bash
# Kubernetes security events
kubectl get events -n tasklistapp --field-selector type=Warning

# Pod security policies
kubectl get podsecuritypolicies

# Image security scanning
kubectl describe pod <pod-name> -n tasklistapp | grep -i image
```

### Log Security Monitoring
```bash
# Application security logs
kubectl logs -l app=tasklistapp -n tasklistapp | grep -i "error\|fail\|unauthorized"

# ArgoCD security events
kubectl logs -l app.kubernetes.io/name=argocd-server -n argocd | grep -i "auth\|token\|secret"
```

## 📚 Security Tools and Resources

### Recommended Tools
- **[Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)** - Encrypt secrets for Git
- **[External Secrets Operator](https://external-secrets.io/)** - Cloud secret manager integration
- **[Falco](https://falco.org/)** - Runtime security monitoring
- **[Trivy](https://trivy.dev/)** - Container image scanning
- **[kube-bench](https://github.com/aquasecurity/kube-bench)** - Kubernetes security benchmarking

### Security Scanning
```bash
# GitHub security scanning
- Enable Dependabot in repository settings
- Enable CodeQL analysis
- Enable secret scanning

# Container security
trivy image ghcr.io/slmakomazi/tasklistapp:api-latest

# Kubernetes security
kube-bench run --targets=master,node
```

## 🔍 Compliance Considerations

### GDPR/Data Protection
- [ ] **Data encryption at rest** (database encryption)
- [ ] **Data encryption in transit** (HTTPS/TLS)
- [ ] **Access logging** (all authentication attempts)
- [ ] **Data retention policies** (automatic cleanup)

### Audit Requirements
- [ ] **Access logs** retained for 90+ days
- [ ] **Security events** monitored and alerted
- [ ] **Change management** logs (ArgoCD sync history)
- [ ] **Backup procedures** documented and tested

## 🚨 Incident Response

### Security Incident Checklist
1. **Identify the threat**: Review logs and alerts
2. **Contain the breach**: Isolate affected resources
3. **Assess impact**: Determine data exposure
4. **Notify stakeholders**: Follow incident response plan
5. **Remediate**: Apply security fixes
6. **Document**: Record all actions and lessons learned

### Emergency Contacts
- **Security Team**: [your-security-team@company.com]
- **Incident Response**: [your-incident-response@company.com]
- **System Administrator**: [your-admin@company.com]

---

**Security is everyone's responsibility. Always err on the side of caution with credentials and access control.** 🔒

## 📊 Access and Testing

### Port Forwarding for Local Development

Port forwarding allows you to access your Kubernetes services locally for testing and management. Each port forward requires a dedicated terminal session.

#### Terminal 1: ArgoCD UI Access
```bash
# Port-forward ArgoCD dashboard (keep this terminal active)
kubectl port-forward svc/argocd-server -n argocd 9090:443

# Alternative ports if 9090 is taken:
# kubectl port-forward svc/argocd-server -n argocd 9091:443
# kubectl port-forward svc/argocd-server -n argocd 8081:443
```

**ArgoCD Access:**
- **URL**: https://localhost:9090
- **Username**: admin
- **Password**: Get initial password with:
  ```bash
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
  ```

**⚠️ Important**: Keep this terminal session active while using ArgoCD UI. Closing the terminal will disconnect the port forward.

#### Terminal 2: TasklistApp Backend API (Postman/curl)
```bash
# Port-forward TasklistApp service (keep this terminal active)
kubectl port-forward -n tasklistapp svc/tasklistapp-service 8080:80

# Alternative ports if 8080 is taken:
# kubectl port-forward -n tasklistapp svc/tasklistapp-service 8081:80
# kubectl port-forward -n tasklistapp svc/tasklistapp-service 8082:80
```

**TasklistApp API Access:**
- **Base URL**: http://localhost:8080
- **API Endpoints**: http://localhost:8080/api/tasks
- **Health Check**: http://localhost:8080/actuator/health
- **Swagger UI**: http://localhost:8080/swagger-ui.html

**⚠️ Important**: Keep this terminal session active while testing the API. Closing the terminal will disconnect the port forward.

#### Running Both Simultaneously
You can run both port forwards simultaneously using separate terminals:

**Terminal 1 (ArgoCD Management):**
```bash
kubectl port-forward svc/argocd-server -n argocd 9090:443
# Access: https://localhost:9090 (admin / [password command above])
```

**Terminal 2 (API Testing):**
```bash
kubectl port-forward -n tasklistapp svc/tasklistapp-service 8080:80
# Access: http://localhost:8080/api/tasks
```

### API Testing with Postman or curl

Once the TasklistApp port forward is active, you can test the API:

#### curl Examples
```bash
# Health check
curl http://localhost:8080/actuator/health

# Get all tasks
curl http://localhost:8080/api/tasks

# Create a new task
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Task","description":"Testing via curl","completed":false}'

# Update a task
curl -X PUT http://localhost:8080/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"completed":true}'

# Delete a task
curl -X DELETE http://localhost:8080/api/tasks/1
```

#### Postman Collection
Import these endpoints into Postman for easy testing:

**GET All Tasks**
```
GET http://localhost:8080/api/tasks
```

**POST Create Task**
```
POST http://localhost:8080/api/tasks
Content-Type: application/json

{
  "title": "New Task",
  "description": "Task description",
  "completed": false,
  "dueDate": "2024-12-31"
}
```

**GET Task by ID**
```
GET http://localhost:8080/api/tasks/{id}
```

**PUT Update Task**
```
PUT http://localhost:8080/api/tasks/{id}
Content-Type: application/json

{
  "completed": true
}
```

**DELETE Task**
```
DELETE http://localhost:8080/api/tasks/{id}
```

### Health Checks
```bash
# Application health via port-forward
curl http://localhost:8080/actuator/health

# Database connectivity check
kubectl exec -it <tasklistapp-pod> -n tasklistapp -- nc -zv tasklistapp-postgresql-service 5432

# ArgoCD application status
kubectl get applications tasklistapp -n argocd

# Pod health and status
kubectl get pods -n tasklistapp -o wide
```

### Troubleshooting Port Forwarding

#### Port Already in Use
```bash
# Check what's using a port
netstat -tulpn | grep :9090

# Use alternative ports
kubectl port-forward svc/argocd-server -n argocd 9091:443  # For ArgoCD
kubectl port-forward -n tasklistapp svc/tasklistapp-service 8081:80  # For API
```

#### Connection Issues
```bash
# Verify services exist
kubectl get services -n argocd
kubectl get services -n tasklistapp

# Check pod status
kubectl get pods -n argocd
kubectl get pods -n tasklistapp

# View service endpoints
kubectl get endpoints -n tasklistapp
```

#### Reset Port Forward
```bash
# If port forward stops working, restart it:
# Terminal 1: Ctrl+C then re-run the port-forward command
# Terminal 2: Ctrl+C then re-run the port-forward command
```

---

**💡 Tip**: Use separate terminal tabs or windows for each port forward to keep them organized and easily manageable during development and testing.

## 🔄 ArgoCD GitOps Integration

### How CI/CD Works with ArgoCD
1. **Developer pushes code** to GitHub repository
2. **GitHub Actions CI** builds and tests the application
3. **Docker images pushed** to GitHub Container Registry (GHCR)
4. **ArgoCD detects changes** in the k8s/ directory
5. **ArgoCD syncs manifests** and pulls new images automatically
6. **Kubernetes deployment updated** with zero-downtime rolling updates

### ArgoCD Application Configuration Details
- **Repository URL**: `https://github.com/slmakomazi/TasklistApp`
- **Path**: `k8s/` (watches all Kubernetes manifests in this directory)
- **Target Revision**: `HEAD` (always deploys latest commit)
- **Destination Server**: `https://kubernetes.default.svc` (local cluster)
- **Destination Namespace**: `tasklistapp` (isolated namespace)
- **Sync Policy**: Automated with self-healing and pruning enabled

### CI Integration Example
```yaml
# In GitHub Actions workflow (ci-build.yml)
- name: Update Kubernetes Image Tag
  run: |
    sed -i 's|image: ghcr.io/slmakomazi/tasklistapp:.*|image: ghcr.io/slmakomazi/tasklistapp:api-${{ github.run_number }}|' k8s/deployment.yaml
    git add k8s/deployment.yaml
    git commit -m "Update image tag to api-${{ github.run_number }}"
    git push
```

## 🔗 Integration with CI/CD

The GitHub Actions workflow now pushes images to GitHub Container Registry (GHCR). ArgoCD automatically detects new images and updates the deployment when manifests change in the repository.
