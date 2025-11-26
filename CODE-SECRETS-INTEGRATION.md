# Code Files Integration with GitHub Secrets

This document shows how all the GitHub repository secrets are integrated into the code files and workflows.

## 📋 Secret Usage Matrix

| Secret Name | Used In Files | Purpose | Integration Method |
|-------------|---------------|---------|-------------------|
| `ANSIBLE_VAULT_PASSWORD` | `ansible/group_vars/all/vault.yml` | Decrypt Ansible vault files | `{{ vault_ansible_vault_password }}` |
| `DB_PASSWORD` | Multiple files | Database authentication | Environment variables |
| `DB_USERNAME` | Multiple files | Database authentication | Environment variables |
| `DB_URL` | Multiple files | Database connection string | Environment variables |
| `DOCKER_PASSWORD` | CI/CD workflows | Container registry auth | `${{ secrets.DOCKER_PASSWORD }}` |
| `DOCKER_USERNAME` | CI/CD workflows | Container registry auth | `${{ secrets.DOCKER_USERNAME }}` |
| `FRONTEND_API_URL` | Multiple files | Frontend configuration | Environment variables |
| `SUDO_PASSWORD` | Deployment workflow | WSL sudo operations | `${{ secrets.SUDO_PASSWORD }}` |
| `SSH_KNOWN_HOSTS` | Legacy workflows | SSH host verification | `${{ secrets.SSH_KNOWN_HOSTS }}` |
| `SSH_PRIVATE_KEY` | Legacy workflows | SSH authentication | `${{ secrets.SSH_PRIVATE_KEY }}` |
| `VM_HOST` | Legacy workflows | SSH connection target | `${{ secrets.VM_HOST }}` |
| `VM_SSH_KEY` | Legacy workflows | SSH authentication | `${{ secrets.VM_SSH_KEY }}` |
| `VM_USER` | Legacy workflows | SSH authentication | `${{ secrets.VM_USER }}` |

## 🔧 File-by-File Integration

### 1. **Ansible Vault Configuration**
**File**: `ansible/group_vars/all/vault.yml`
```yaml
# Database credentials (from GitHub secrets)
db_root_password: "{{ vault_db_password }}"
db_user: "{{ vault_db_username }}"
db_password: "{{ vault_db_password }}"

# Application secrets (from GitHub secrets)
spring_datasource_url: "{{ vault_db_url }}"
spring_datasource_username: "{{ vault_db_username }}"
spring_datasource_password: "{{ vault_db_password }}"

# GitHub Container Registry credentials (from GitHub secrets)
ghcr_username: "{{ vault_docker_username }}"
ghcr_password: "{{ vault_docker_password }}"

# Ansible vault password (from GitHub secrets)
ansible_vault_password: "{{ vault_ansible_vault_password }}"

# Frontend configuration (from GitHub secrets)
frontend_api_url: "{{ vault_frontend_api_url }}"

# Sudo password for WSL operations (from GitHub secrets)
sudo_password: "{{ vault_sudo_password }}"
```

### 2. **GitHub Actions Workflows**

#### Frontend Build Workflow
**File**: `.github/workflows/ci-frontend-build.yml`
```yaml
- name: Log in to GitHub Container Registry
  uses: docker/login-action@v2
  with:
    registry: ghcr.io
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}

# Build args with secrets
build-args: |
  FRONTEND_API_URL=${{ secrets.FRONTEND_API_URL }}
```

#### Backend Build Workflow
**File**: `.github/workflows/ci-backend-build.yml`
```yaml
- name: Login to GitHub Container Registry
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}
```

#### Deployment Workflow
**File**: `.github/workflows/deploy-to-k8s.yml`
```yaml
env:
  # Environment variables from GitHub secrets
  DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
  DB_USERNAME: ${{ secrets.DB_USERNAME }}
  DB_URL: ${{ secrets.DB_URL }}
  FRONTEND_API_URL: ${{ secrets.FRONTEND_API_URL }}
  SUDO_PASSWORD: ${{ secrets.SUDO_PASSWORD }}
  ANSIBLE_VAULT_PASSWORD: ${{ secrets.ANSIBLE_VAULT_PASSWORD }}

# Create Kubernetes secrets from GitHub secrets
- name: Create Kubernetes secrets from GitHub secrets
  run: |
    # Create database secrets
    kubectl create secret generic tasklist-db-secrets \
      --from-literal=db-username=$(echo -n "${{ secrets.DB_USERNAME }}" | base64) \
      --from-literal=db-password=$(echo -n "${{ secrets.DB_PASSWORD }}" | base64) \
      --from-literal=db-url=$(echo -n "${{ secrets.DB_URL }}" | base64) \
      -n ${{ env.NAMESPACE }} || true
    
    # Create application secrets
    kubectl create secret generic tasklist-app-secrets \
      --from-literal=frontend-api-url="${{ secrets.FRONTEND_API_URL }}" \
      -n ${{ env.NAMESPACE }} || true
```

### 3. **Kubernetes Manifests**

#### Secrets Manifest
**File**: `k8s/api-manifests/tasklistapi-secrets.yaml`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: tasklistapi-secrets
  namespace: tasklist
type: Opaque
data:
  # These will be populated by GitHub Actions from GitHub secrets
  # Values are base64 encoded
  DB_USERNAME: ""  # Populated from secrets.DB_USERNAME
  DB_PASSWORD: ""  # Populated from secrets.DB_PASSWORD
  DB_URL: ""       # Populated from secrets.DB_URL
  DB_NAME: dGFza2xpc3RkYg==  # "tasklistdb"
  DB_HOST: dGFza2xpc3QtZGI=   # "tasklist-db"
```

#### Deployment Manifest
**File**: `k8s/api-manifests/tasklistapi-deployment.yaml`
```yaml
spec:
  containers:
    - name: tasklistapi
      envFrom:
        - configMapRef:
            name: tasklistapi-config
        - secretRef:
            name: tasklistapi-secrets  # References secrets populated from GitHub secrets
```

### 4. **Docker Compose Configuration**
**File**: `ansible/docker-compose.yml`
```yaml
services:
  frontend:
    environment:
      - REACT_APP_API_URL=${FRONTEND_API_URL:-http://api:8080}

  api:
    environment:
      - DB_URL=${DB_URL:-jdbc:postgresql://db:5432/tasklistdb}
      - DB_USERNAME=${DB_USERNAME:-postgres}
      - DB_PASSWORD=${DB_PASSWORD}

  db:
    environment:
      - POSTGRES_USER=${DB_USERNAME:-postgres}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
```

### 5. **Application Configuration**
**File**: `app/src/main/resources/application.properties`
```properties
# Database Configuration (Environment Variables)
spring.datasource.url=${DB_URL}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}

# Other configurations use environment variables
server.port=${SERVER_PORT}
spring.jpa.hibernate.ddl-auto=${JPA_DDL_AUTO}
spring.jpa.show-sql=${JPA_SHOW_SQL}
```

### 6. **Environment Template**
**File**: `.env.example`
```bash
# Database Configuration (from GitHub secrets)
DB_URL=jdbc:postgresql://localhost:5432/tasklistdb
DB_USERNAME=postgres
DB_PASSWORD=your_password_here

# Frontend Configuration (from GitHub secrets)
FRONTEND_API_URL=http://localhost:8080

# Docker Registry Configuration (from GitHub secrets)
DOCKER_USERNAME=your_docker_username
DOCKER_PASSWORD=your_docker_password

# Sudo Password for WSL operations (from GitHub secrets)
SUDO_PASSWORD=your_wsl_sudo_password

# Ansible Vault Password (from GitHub secrets)
ANSIBLE_VAULT_PASSWORD=your_ansible_vault_password
```

## 🔄 Secret Flow in CI/CD Pipeline

### 1. **Development Phase**
```bash
# Developer sets local environment variables
export DB_URL="jdbc:postgresql://localhost:5432/tasklistdb"
export DB_USERNAME="postgres"
export DB_PASSWORD="local_password"
```

### 2. **CI/CD Phase**
```yaml
# GitHub Actions injects secrets into workflow
env:
  DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
  DB_USERNAME: ${{ secrets.DB_USERNAME }}
  DB_URL: ${{ secrets.DB_URL }}
```

### 3. **Deployment Phase**
```bash
# Secrets are injected into Kubernetes
kubectl create secret generic tasklist-db-secrets \
  --from-literal=db-username=$(echo -n "${{ secrets.DB_USERNAME }}" | base64) \
  --from-literal=db-password=$(echo -n "${{ secrets.DB_PASSWORD }}" | base64) \
  --from-literal=db-url=$(echo -n "${{ secrets.DB_URL }}" | base64)
```

### 4. **Runtime Phase**
```yaml
# Application reads secrets from environment
envFrom:
  - secretRef:
      name: tasklist-db-secrets
```

## 🛡️ Security Considerations

### 1. **Base64 Encoding**
- Kubernetes secrets require base64 encoding
- GitHub Actions handles encoding automatically
- Local development requires manual encoding

### 2. **Namespace Isolation**
- Secrets are scoped to `tasklist` namespace
- Prevents cross-namespace secret access

### 3. **Least Privilege**
- Service accounts have minimal required permissions
- Secrets are only accessible to required pods

### 4. **Audit Trail**
- GitHub Actions logs show secret usage (but not values)
- Kubernetes audit logs track secret access

## 🚀 Testing Secret Integration

### 1. **Local Testing**
```bash
# Test with environment variables
export DB_URL="jdbc:postgresql://localhost:5432/tasklistdb"
export DB_USERNAME="postgres"
export DB_PASSWORD="test_password"
mvn spring-boot:run
```

### 2. **Docker Testing**
```bash
# Test with Docker Compose
docker-compose --env-file .env up
```

### 3. **Kubernetes Testing**
```bash
# Test secret creation
kubectl create secret generic test-secret \
  --from-literal=test-value="test" \
  --dry-run=client -o yaml

# Test secret injection
kubectl exec -it <pod-name> -- env | grep DB_
```

## 📝 Best Practices

1. **Never commit secrets to version control**
2. **Use different secrets for different environments**
3. **Rotate secrets regularly**
4. **Monitor secret access logs**
5. **Use strong, unique passwords**
6. **Implement secret scanning tools**
7. **Document secret usage and rotation procedures**

---

**This integration ensures that all GitHub secrets are properly utilized across the entire application stack while maintaining security best practices.**
