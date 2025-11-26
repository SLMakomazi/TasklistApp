# TasklistApp Kubernetes Deployment Guide

**Cluster: MicroK8s (WSL2 VM) — ArgoCD: Installed & Running — App: TasklistApp (Ready for Deployment)**

This directory contains all the Kubernetes manifests needed to deploy TasklistApp with PostgreSQL to a MicroK8s cluster using ArgoCD for GitOps deployment.

## 📁 Files Overview

- `namespace.yaml` - Creates a dedicated `tasklistapp` namespace
- `secrets.yaml` - Base64-encoded database credentials (⚠️ Update with your actual values)
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

## 📋 Detailed Manifest Explanations

### namespace.yaml
Creates the `tasklistapp` namespace for resource isolation:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: tasklistapp
  labels:
    name: tasklistapp
```

### secrets.yaml
Contains base64-encoded database credentials:
```bash
# Generate base64 values
echo -n "your_username" | base64  # For db-username
echo -n "your_password" | base64  # For db-password

# Update secrets.yaml with encoded values
```

**⚠️ CRITICAL**: Update with your actual database credentials!

### configmap.yaml
Application configuration for Kubernetes environment:
- `LOG_LEVEL_SPRING: "INFO"` - Spring framework logging
- `LOG_LEVEL_TASKLIST: "INFO"` - Application logging
- `SERVER_PORT: "8080"` - Container port
- `JPA_SHOW_SQL: "false"` - Production SQL logging
- `SPRING_PROFILES_ACTIVE: "kubernetes"` - K8s-specific profile

### postgres-pvc.yaml
Persistent storage for PostgreSQL (5Gi hostpath storage):
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: tasklistapp-postgres-pvc
  namespace: tasklistapp
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: microk8s-hostpath  # Uses MicroK8s default storage
  resources:
    requests:
      storage: 5Gi
```

### postgres-deployment.yaml
PostgreSQL deployment with persistent storage:
- **Image**: Custom PostgreSQL image from GHCR
- **Database**: `tasklistdb` (created automatically)
- **Storage**: Uses PVC for data persistence
- **Credentials**: From Kubernetes secrets

### service.yaml
Internal cluster service for TasklistApp:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: tasklistapp-service
  namespace: tasklistapp
spec:
  selector:
    app: tasklistapp  # Matches deployment labels
  ports:
  - port: 80          # Service port
    targetPort: 8080  # Container port
  type: ClusterIP     # Internal access only
```

### deployment.yaml
Main application deployment with 3 replicas:
- **Image**: `ghcr.io/slmakomazi/tasklistapp:api-latest`
- **Health Checks**: Spring Boot Actuator (`/actuator/health`)
- **Environment**: Database connection via service discovery
- **Scaling**: 3 replicas for high availability

### ingress.yaml
External access configuration:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tasklistapp-ingress
  namespace: tasklistapp
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

### argocd-application.yaml
ArgoCD GitOps configuration:
- **Repository**: `https://github.com/slmakomazi/TasklistApp`
- **Path**: `k8s/` (watches all manifests)
- **Target**: `tasklistapp` namespace
- **Sync Policy**: Automated with self-healing

## 🚀 ArgoCD Setup and Access

### Install ArgoCD (if not already installed)
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
# Port-forward ArgoCD UI (avoiding common ports)
kubectl port-forward svc/argocd-server -n argocd 9090:443

# Alternative ports if 9090 taken:
# kubectl port-forward svc/argocd-server -n argocd 9091:443
# kubectl port-forward svc/argocd-server -n argocd 8081:443

# Access at: https://localhost:9090
# Username: admin
# Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Apply TasklistApp Application
```bash
# Apply the ArgoCD application manifest
kubectl apply -f argocd-application.yaml

# Check application status
kubectl get applications -n argocd

# View detailed sync information
kubectl describe application tasklistapp -n argocd
```

## 🔍 Monitoring and Troubleshooting

### Check Deployment Status
```bash
# All resources in namespace
kubectl get all -n tasklistapp

# Pods with detailed status
kubectl get pods -n tasklistapp -o wide

# Services and ingress
kubectl get services,ingress -n tasklistapp

# Persistent volumes
kubectl get pvc -n tasklistapp
```

### View Logs
```bash
# TasklistApp logs
kubectl logs -l app=tasklistapp -n tasklistapp -f

# PostgreSQL logs
kubectl logs -l app=tasklistapp-postgresql -n tasklistapp -f

# Specific pod logs
kubectl logs <pod-name> -n tasklistapp -f

# Previous container logs (if restarted)
kubectl logs <pod-name> -n tasklistapp --previous
```

### Debug Common Issues

#### Pod Issues
```bash
# Describe pod for detailed error information
kubectl describe pod <pod-name> -n tasklistapp

# Check events in namespace
kubectl get events -n tasklistapp --sort-by='.lastTimestamp'

# Check resource constraints
kubectl describe pod <pod-name> -n tasklistapp | grep -A 10 "Limits\|Requests"
```

#### Database Connection Issues
```bash
# Verify PostgreSQL service
kubectl get endpoints -n tasklistapp

# Check PostgreSQL logs
kubectl logs -l app=tasklistapp-postgresql -n tasklistapp

# Test connection from app pod
kubectl exec -it <tasklistapp-pod> -n tasklistapp -- nc -zv tasklistapp-postgresql-service 5432
```

#### Image Pull Issues
```bash
# Check image pull status
kubectl describe pod <pod-name> -n tasklistapp | grep -i image

# Verify image exists in GHCR
kubectl run test-image --image=ghcr.io/slmakomazi/tasklistapp:api-latest --dry-run=client -o yaml
```

#### ArgoCD Sync Issues
```bash
# Check application sync status
kubectl get applications tasklistapp -n argocd

# View sync errors
kubectl describe application tasklistapp -n argocd

# Force sync if needed
kubectl argo rollouts promote tasklistapp -n argocd
```

## 🔐 Security Considerations

### Secrets Management
```bash
# Generate base64 values for secrets
echo -n "your_username" | base64  # For db-username
echo -n "your_password" | base64  # For db-password

# Update k8s/secrets.yaml with encoded values
# Example format:
# db-username: cG9zdGdyZXM=  # "postgres"
# db-password: YWRtaW4=      # "admin"
```

### GitHub Repository Secrets
The following secrets are configured in the GitHub repository:

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

**Note**: Current deployment uses zero SSH approach. SSH secrets are retained for compatibility.

### Security Best Practices
- ✅ **Base64 Encoding**: All secrets must be base64 encoded
- ✅ **Namespace Isolation**: Secrets scoped to `tasklistapp` namespace
- ✅ **No Plaintext**: Never commit plaintext credentials to version control
- ✅ **Minimal Permissions**: Service accounts use least-privilege access
- ✅ **Network Policies**: Can be added for additional security

## 🛡️ Production Security Checklist

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
