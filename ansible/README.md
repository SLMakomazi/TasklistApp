# Ansible Provisioning - TasklistApp VM Management

This directory contains Ansible playbooks for provisioning and deploying TasklistApp to VM servers. Supports single VM deployment with easy scaling to multiple VMs.

## 📁 Files Overview

- `inventory.ini` - Ansible inventory defining VM targets and variables
- `provision.yml` - Main provisioning playbook (installs software, configures system)
- `deploy.yml` - Application deployment playbook (copies JAR, updates service)
- `templates/` - Jinja2 templates for configuration files
- `README.md` - This documentation

## 🚀 Quick Start

### Prerequisites
- **Ansible** installed on your control machine (`pip install ansible`)
- **SSH access** to target VM(s) with sudo privileges
- **SSH key** configured for passwordless authentication

### 1. Configure Inventory
Edit `inventory.ini`:
```ini
[vm_servers]
your-vm-name ansible_host=YOUR_VM_IP ansible_user=YOUR_USERNAME

[vm_servers:vars]
db_host=your-docker-host-ip
db_password=your_db_password
```

### 2. Provision VM (First Time Setup)
```bash
# Provision VM with required software
ansible-playbook -i inventory.ini provision.yml

# VM is now ready with:
# - Java 17 installed
# - Docker configured
# - Application user and directories created
# - Systemd service configured
# - Firewall configured
```

### 3. Deploy Application
```bash
# Deploy application to provisioned VM(s)
ansible-playbook -i inventory.ini deploy.yml

# This will:
# - Copy latest JAR file from ../app/target/
# - Update application configuration
# - Restart systemd service
# - Verify deployment
```

## 📋 Playbook Details

### `provision.yml` - VM Setup
**What it does:**
- Updates system packages
- Installs Java 17, Docker, and utilities
- Creates application user (`siseko`) and directories
- Configures firewall (allows SSH and port 8080)
- Installs and configures systemd service
- Sets up logging and configuration templates

**Run on:**
- Fresh Ubuntu/Debian VMs
- Before deploying application

### `deploy.yml` - Application Deployment
**What it does:**
- Copies JAR file from local `../app/target/` to VM
- Updates application configuration with current database settings
- Restarts systemd service
- Verifies deployment success

**Run on:**
- Already provisioned VMs
- After application code changes
- When updating to new JAR version

## 🔧 Configuration

### Inventory Variables
```ini
[vm_servers:vars]
# SSH Configuration
ansible_user=tasklist
ansible_ssh_private_key_file=/path/to/your/key

# Application Configuration
app_user=siseko
app_base_dir=/opt/tasklist
service_name=tasklist

# Database Configuration
db_host=tasklist-postgres  # Docker container name/IP
db_port=5432
db_name=tasklistdb
db_user=postgres
db_password=admin
```

### Template Variables
Templates in `templates/` use these variables for configuration generation.

## 🔄 Scaling to Multiple VMs

### Add More VMs to Inventory
```ini
[vm_servers]
vm-01 ansible_host=192.168.1.101 ansible_user=tasklist
vm-02 ansible_host=192.168.1.102 ansible_user=tasklist
vm-03 ansible_host=192.168.1.103 ansible_user=tasklist

[load_balancer]
haproxy-lb ansible_host=192.168.1.100 ansible_user=admin
```

### Run Playbooks on Multiple VMs
```bash
# Provision all VMs
ansible-playbook -i inventory.ini provision.yml

# Deploy to all VMs
ansible-playbook -i inventory.ini deploy.yml

# Deploy to specific VM
ansible-playbook -i inventory.ini -l vm-01 deploy.yml
```

## 🛠️ Troubleshooting

### Common Issues

#### SSH Connection Failed
```bash
# Test SSH connection manually
ssh -i /path/to/key tasklist@your-vm-ip

# Fix inventory host key checking
ansible -i inventory.ini vm_servers -m ping
```

#### Permission Denied
```bash
# Ensure sudo access on target VM
# Check /etc/sudoers for ansible user

# Run with manual password prompt
ansible-playbook -i inventory.ini --ask-become-pass provision.yml
```

#### JAR File Not Found
```bash
# Ensure JAR exists in ../app/target/
ls -la ../app/target/tasklist-api-*.jar

# Build application first
cd ../app && mvn clean package -DskipTests
```

## 🔗 Integration with CI/CD

### GitHub Actions Integration
Add to `.github/workflows/vm-deploy.yml`:
```yaml
- name: Run Ansible deployment
  run: |
    cd ansible
    ansible-playbook -i inventory.ini deploy.yml
```

### Automated Deployment
```bash
# From project root
./ansible/deploy.sh  # If you create a wrapper script
```

## 📚 Related Documentation

- **Main Project**: [../README.md](../README.md) - Complete project overview
- **VM Deployment**: [../vm/README.md](../vm/README.md) - Manual VM deployment guide
- **Kubernetes**: [../k8s/README.md](../k8s/README.md) - Kubernetes deployment guide

## 🎯 Benefits

- **Idempotent**: Run multiple times safely
- **Scalable**: Easy to add more VMs
- **Consistent**: Same configuration across all VMs
- **Automated**: Integrates with CI/CD pipelines
- **Version Controlled**: All configuration in Git
