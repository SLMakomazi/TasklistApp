# TasklistApp Ansible Configuration

This directory contains Ansible playbooks and configurations for **local deployment** with zero SSH access. The deployment uses local execution in WSL Ubuntu through the self-hosted GitHub runner.

## 🔐 Vault Configuration

### Vault Password
- Location: `ansible/vault_pass.txt`
- **Important**: This file is in `.gitignore` for security
- Required for decrypting sensitive data in `group_vars/all/vault.yml`

### Managing Secrets
To edit encrypted files:
```bash
# Set environment variable
export ANSIBLE_VAULT_PASSWORD_FILE=./vault_pass.txt

# Edit vault
export EDITOR=nano  # or your preferred editor
ansible-vault edit group_vars/all/vault.yml
```

## 🚀 Zero SSH Deployment

### Current Configuration
The Ansible setup has been updated for **zero SSH deployment**:

- **Inventory**: Uses `ansible_connection=local` for local execution
- **Target**: WSL Ubuntu environment via self-hosted runner
- **No SSH**: Completely removes SSH dependencies

### Inventory Configuration
```ini
[local_vm]
localhost ansible_connection=local ansible_user=siseko
```

### Required Secrets
Ensure these are set in your CI/CD environment:
- `ANSIBLE_VAULT_PASSWORD`: Vault password for decrypting secrets
- `SUDO_PASSWORD`: WSL Ubuntu sudo password (for self-hosted runner)

### Running the Playbook
```bash
# Local execution (zero SSH)
ansible-playbook -i inventory.ini deploy_vm.yml --vault-password-file=./vault_pass.txt --connection=local
```

## 📂 Deployment Structure
```
/opt/tasklistapp/
├── k8s/                    # Kubernetes manifests
├── docker-compose.yml      # Local Docker setup
├── .env                    # Environment variables
└── logs/                   # Application logs
```

## 🔄 Post-Deployment

### Verify Deployment
```bash
# Check Kubernetes resources
kubectl get pods,svc -n tasklist

# View application logs
kubectl logs -l app=tasklistapp -n tasklist -f

# Check ArgoCD sync status
kubectl get applications -n argocd
```

### Updating the Deployment
1. Push changes to your repository
2. The GitHub Actions workflow will automatically trigger
3. The self-hosted runner will execute the deployment playbook locally

## 🔧 Maintenance

### Updating the Application
```bash
# Apply latest Kubernetes manifests
kubectl apply -k k8s/

# Restart deployment
kubectl rollout restart deployment/tasklistapp-deployment -n tasklist
```

### Backing Up the Database
```bash
# Backup PostgreSQL from Kubernetes
kubectl exec -it postgresdb-pod-name -n tasklist -- pg_dump -U tasklist_user tasklistdb > backup_$(date +%Y%m%d).sql
```

### Restoring the Database
```bash
cat backup_file.sql | kubectl exec -i postgresdb-pod-name -n tasklist -- psql -U tasklist_user tasklistdb
```

---

## 🚀 Integration with CI/CD Pipeline

### GitHub Actions Integration

The Ansible playbook is now integrated with the **zero SSH** CI/CD pipeline:

1. **Self-hosted runner** executes locally in WSL Ubuntu
2. **Local Ansible** applies Kubernetes manifests
3. **No SSH required** - all operations are local
4. **ArgoCD GitOps** handles ongoing synchronization

### Workflow Overview

The deployment workflow (`.github/workflows/deploy-to-k8s.yml`) will:
1. Set up kubectl access to MicroK8s
2. Apply Kubernetes manifests using kustomize
3. Verify deployment health and status
4. Run smoke tests against the deployed application

## 🛠️ Local Development with Ansible

### Prerequisites

```bash
# Install Ansible in WSL Ubuntu
sudo apt update && sudo apt install -y ansible

# Install required Ansible collections
ansible-galaxy collection install community.docker
```

### Running the Playbook Locally

1. Update vault password:
   ```bash
   nano vault_pass.txt
   ```

2. Run the playbook:
   ```bash
   ansible-playbook -i inventory.ini deploy_vm.yml --connection=local
   ```

## 🔍 Troubleshooting

### Local Execution Issues
- **Permission denied**
  - Check user permissions in WSL Ubuntu
  - Verify sudo access for required operations

- **Missing dependencies**
  ```bash
  # Install required Python packages
  python3 -m pip install docker
  ```

- **Kubernetes connection issues**
  ```bash
  # Verify MicroK8s status
  microk8s status --wait-ready
  
  # Check kubectl configuration
  kubectl cluster-info
  ```

### Ansible Playbook Issues
- **Vault password errors**
  - Verify vault_pass.txt exists and is readable
  - Check ANSIBLE_VAULT_PASSWORD_FILE environment variable

- **Docker permission issues**
  - Add your user to the docker group:
    ```bash
    sudo usermod -aG docker $USER
    newgrp docker
    ```

## 🔒 Security Best Practices

1. **Vault Management**
   - Never commit vault_pass.txt to version control
   - Use strong vault passwords
   - Rotate vault passwords regularly

2. **Local Security**
   - Restrict WSL Ubuntu user permissions
   - Use minimal sudo requirements
   - Monitor local access logs

3. **Kubernetes Security**
   - Use namespace isolation
   - Implement network policies
   - Regular security updates

## 📚 Additional Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [MicroK8s Documentation](https://microk8s.io/docs)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
