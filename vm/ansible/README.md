# Ansible Deployment Setup

This directory contains Ansible playbooks and configuration for automated deployment of the Tasklist application.

## 📁 Directory Structure

```
vm/ansible/
├── deploy.yml          # Main deployment playbook
├── inventory.ini       # Target hosts configuration
├── ansible.cfg         # Ansible configuration
├── requirements.yml    # Ansible Galaxy roles
├── deploy.sh          # Deployment script
├── vm-setup.sh        # VM preparation script
└── README.md          # This file
```

## 🚀 Quick Start

### 1. Prepare Your VM

Run the setup script on your Ubuntu VM:

```bash
chmod +x vm/ansible/vm-setup.sh
./vm/ansible/vm-setup.sh
```

### 2. Configure Inventory

Edit `vm/ansible/inventory.ini`:

```ini
[tasklist_servers]
your-vm-host ansible_host=192.168.1.100 ansible_user=siseko

[tasklist_servers:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
jar_file_path=/tmp/tasklist-api.jar
```

### 3. Deploy from GitHub Actions

The deployment will automatically:
1. Build the Maven project
2. Copy JAR to VM via Ansible
3. Deploy using systemd service
4. Verify deployment success

## 📋 Manual Deployment

### Install Ansible (if not already installed)

```bash
sudo apt update
sudo apt install -y ansible
```

### Run Deployment Playbook

```bash
cd vm/ansible

# Install roles (if any)
ansible-galaxy install -r requirements.yml

# Deploy application
ansible-playbook -i inventory.ini deploy.yml -v
```

### Test Connection

```bash
ansible -i inventory.ini -m ping tasklist_servers
```

## 🔧 Customization

### Environment Variables

The deployment uses these environment variables (set in systemd service):

- `DB_URL`: PostgreSQL connection URL
- `DB_USERNAME`: Database username
- `DB_PASSWORD`: Database password
- `SERVER_PORT`: Application port (default: 8080)
- `LOG_LEVEL_*`: Logging configuration

### Adding New Features

1. **New Playbooks**: Create additional `.yml` files in this directory
2. **Roles**: Add to `requirements.yml` and run `ansible-galaxy install -r requirements.yml`
3. **Variables**: Define in `inventory.ini` or pass as `--extra-vars`

## 🔍 Troubleshooting

### Common Issues

1. **SSH Connection Failed**
   - Check VM IP address in `inventory.ini`
   - Verify SSH service is running: `sudo systemctl status ssh`
   - Check SSH keys are properly configured

2. **Permission Denied**
   - Ensure the ansible user exists and has sudo privileges
   - Check SSH public key is correctly added to `authorized_keys`

3. **Service Won't Start**
   - Check application logs: `sudo journalctl -u tasklist -f`
   - Verify JAR file was copied correctly
   - Check database connectivity

### Debug Mode

Run playbook with debug output:

```bash
ansible-playbook -i inventory.ini deploy.yml -vvv
```

## 📚 Additional Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Galaxy](https://galaxy.ansible.com/)
- [Systemd Service Management](https://www.freedesktop.org/software/systemd/man/systemd.service.html)

## 🎯 Benefits of Ansible Approach

✅ **Idempotent**: Run multiple times safely
✅ **Version Controlled**: Infrastructure as code
✅ **Reusable**: Deploy to multiple environments
✅ **Maintainable**: Clear, readable automation
✅ **Testable**: Can be tested before deployment
