# GitHub Repository Secrets Documentation

This document lists all GitHub secrets configured for the TasklistApp repository, their purposes, and last update timestamps.

## 📋 Complete Secrets List

| Secret Name | Description | Purpose | Last Updated | Used By |
|-------------|-------------|---------|--------------|----------|
| `ANSIBLE_VAULT_PASSWORD` | Password for decrypting Ansible vault files | Decrypts `ansible/group_vars/all/vault.yml` | 2 days ago | Ansible playbooks, CI/CD |
| `DB_PASSWORD` | PostgreSQL database password | Database authentication | last month | Kubernetes secrets, Docker Compose |
| `DB_URL` | Database connection URL | JDBC connection string | last month | Application configuration |
| `DB_USERNAME` | PostgreSQL database username | Database authentication | last month | Kubernetes secrets, Docker Compose |
| `DOCKER_PASSWORD` | Docker Hub/GHCR password | Container registry authentication | last month | CI/CD workflows (image push) |
| `DOCKER_USERNAME` | Docker Hub/GHCR username | Container registry authentication | last month | CI/CD workflows (image push) |
| `FRONTEND_API_URL` | Frontend API endpoint configuration | Frontend app configuration | last month | Frontend build, environment variables |
| `SSH_KNOWN_HOSTS` | SSH known hosts file content | SSH host verification | 3 weeks ago | Legacy SSH workflows (unused) |
| `SSH_PRIVATE_KEY` | SSH private key for VM access | SSH authentication | 3 weeks ago | Legacy SSH workflows (unused) |
| `SUDO_PASSWORD` | WSL Ubuntu sudo password for runner | Privileged operations in WSL | 2 days ago | Self-hosted runner, deployment scripts |
| `VM_HOST` | Target VM hostname/IP | SSH connection target | last month | Legacy VM deployment (unused) |
| `VM_SSH_KEY` | SSH key for VM access | SSH authentication | last month | Legacy VM deployment (unused) |
| `VM_USER` | SSH username for VM access | SSH authentication | last month | Legacy VM deployment (unused) |

## 🔐 Security Classification

### **High Priority Secrets** (Regularly Used)
- `ANSIBLE_VAULT_PASSWORD` - Critical for Ansible operations
- `SUDO_PASSWORD` - Required for self-hosted runner operations
- `DOCKER_USERNAME`/`DOCKER_PASSWORD` - Required for container registry access

### **Application Secrets** (Database & Config)
- `DB_PASSWORD` - Database authentication
- `DB_USERNAME` - Database authentication  
- `DB_URL` - Database connection string
- `FRONTEND_API_URL` - Frontend configuration

### **Legacy Secrets** (Currently Unused)
- `SSH_KNOWN_HOSTS` - SSH host verification
- `SSH_PRIVATE_KEY` - SSH authentication
- `VM_HOST` - SSH connection target
- `VM_SSH_KEY` - SSH authentication
- `VM_USER` - SSH authentication

## 📅 Maintenance Schedule

### **Monthly Review**
- Rotate `DB_PASSWORD` and `DB_USERNAME`
- Verify `DOCKER_USERNAME`/`DOCKER_PASSWORD` are still valid
- Check `FRONTEND_API_URL` for any needed updates

### **Quarterly Review**
- Rotate `ANSIBLE_VAULT_PASSWORD`
- Rotate `SUDO_PASSWORD`
- Review and clean up unused legacy secrets

### **As Needed**
- Update secrets when infrastructure changes
- Rotate compromised secrets immediately
- Update when team members change

## 🔄 Current Deployment Method

**Zero SSH Deployment**: The current implementation uses a self-hosted runner with local kubectl access, eliminating the need for SSH-based deployment. 

**Active Secrets in Zero SSH Deployment**:
- `ANSIBLE_VAULT_PASSWORD` - Ansible vault operations
- `SUDO_PASSWORD` - Runner privileged operations
- `DOCKER_USERNAME`/`DOCKER_PASSWORD` - Container registry
- `DB_*` secrets - Database configuration
- `FRONTEND_API_URL` - Frontend configuration

**Legacy Secrets**: SSH-related secrets (`SSH_*`, `VM_*`) are retained for backward compatibility but are not used in the current zero SSH deployment method.

## 🚨 Security Best Practices

### **Secret Rotation**
1. Generate new secure passwords/keys
2. Update GitHub repository secrets
3. Update any dependent configurations
4. Test deployment with new secrets
5. Delete old secrets

### **Secret Generation**
```bash
# Generate secure passwords (32 characters)
openssl rand -base64 32

# Generate SSH key pairs
ssh-keygen -t ed25519 -a 100 -f ~/.ssh/tasklist_key

# Generate base64 encoded values for Kubernetes
echo -n "your_secret_value" | base64
```

### **Secret Validation**
```bash
# Test Ansible vault password
ansible-vault view group_vars/all/vault.yml --vault-password-file=vault_pass.txt

# Test Docker registry access
docker login ghcr.io -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

# Test database connection
psql $DB_URL -U $DB_USERNAME
```

## 📝 Secret Usage Examples

### **Ansible Vault**
```yaml
# ansible/group_vars/all/vault.yml (encrypted)
db_password: "{{ vault_db_password }}"
ansible_vault_password: "{{ vault_ansible_password }}"
```

### **Kubernetes Secrets**
```yaml
# k8s/api-manifests/tasklistapi-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: tasklistapi-secrets
type: Opaque
data:
  db-username: {{ db_username | b64encode }}
  db-password: {{ db_password | b64encode }}
```

### **Docker Compose**
```yaml
# docker-compose.yml
services:
  postgres:
    environment:
      POSTGRES_USER: ${DB_USERNAME}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
```

### **GitHub Actions**
```yaml
# .github/workflows/deploy-to-k8s.yml
env:
  DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
  DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
  SUDO_PASSWORD: ${{ secrets.SUDO_PASSWORD }}
```

## 🔍 Troubleshooting

### **Common Issues**
1. **Secret not found**: Verify secret name matches exactly (case-sensitive)
2. **Invalid credentials**: Check for expired passwords or incorrect values
3. **Base64 encoding issues**: Ensure Kubernetes secrets are properly encoded
4. **Ansible vault errors**: Verify vault password is correct and file is properly encrypted

### **Debug Commands**
```bash
# Check if secret exists in GitHub CLI
gh secret list --repo SLMakomazi/TasklistApp

# Test secret in workflow
echo "Testing secret: ${{ secrets.SECRET_NAME }}"

# Verify Ansible vault
ansible-vault decrypt --vault-password-file=vault_pass.txt group_vars/all/vault.yml
```

## 📞 Contact Information

For secret-related issues:
1. Check this documentation first
2. Review GitHub repository settings
3. Contact repository maintainers
4. Follow security incident procedures if secrets are compromised

---

**⚠️ Important**: Never commit secrets to version control. Always use GitHub repository secrets for sensitive configuration values.
