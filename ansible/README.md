# TasklistApp Deployment

This directory contains the Docker Compose configuration and deployment scripts for the TasklistApp. The application consists of three main services:
- Frontend (React)
- Backend API (Node.js)
- Database (PostgreSQL)

## 🐳 Docker Compose Deployment

### Prerequisites
- Docker and Docker Compose installed on the target server
- Ports 3000 (frontend) and 5000 (API) available
- GitHub Container Registry (GHCR) access configured

### Configuration

1. Copy the example environment file and update the values:
   ```bash
   cp .env.example .env
   nano .env
   ```

2. Update the following environment variables in `.env`:
   - `DB_PASSWORD`: A secure password for the database
   - `JWT_SECRET`: A secure secret for JWT token generation
   - `API_URL`: The URL where your API will be accessible

### Deployment

1. Pull the latest images and start the services:
   ```bash
   docker-compose pull
   docker-compose up -d
   ```

2. Verify the services are running:
   ```bash
   docker-compose ps
   ```

3. View logs:
   ```bash
   docker-compose logs -f
   ```

## 🔧 Maintenance

### Updating the Application
```bash
docker-compose pull
docker-compose up -d --force-recreate
```

### Backing Up the Database
```bash
docker-compose exec db pg_dump -U postgres tasklist > backup_$(date +%Y%m%d).sql
```

### Restoring the Database
```bash
cat backup_file.sql | docker-compose exec -T db psql -U postgres tasklist
```
---

## 🔑 SSH Configuration for WSL VM

### 1. Generate SSH Key Pair

On your local Windows machine (PowerShell):

```powershell
# Generate a new ED25519 key pair
ssh-keygen -t ed25519 -f $HOME\.ssh\id_ed25519_wsl -N '""'

# View the public key (you'll need this for authorized_keys)
type $HOME\.ssh\id_ed25519_wsl.pub
```

### 2. Configure SSH Server in WSL

In your WSL terminal:

```bash
# Install SSH server if not already installed
sudo apt update && sudo apt install -y openssh-server

# Configure SSH to use port 2222
sudo sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

# Restart SSH service
sudo service ssh restart

# Add SSH key to authorized_keys
mkdir -p ~/.ssh
echo "PASTE_YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### 3. Test SSH Connection

From Windows (PowerShell):
```powershell
ssh -i $HOME\.ssh\id_ed25519_wsl -p 2222 siseko@localhost
```

## 🚀 GitHub Actions Integration

### Required Secrets
Add these secrets in your GitHub repository (Settings > Secrets > Actions):

1. `SSH_PRIVATE_KEY` - Contents of your private key (`id_ed25519_wsl`)
2. `SSH_KNOWN_HOSTS` - Run this command and add its output:
   ```bash
   ssh-keyscan -p 2222 localhost
   ```

### Workflow Overview

The deployment workflow (`.github/workflows/deploy-vm.yml`) will:
1. Set up SSH agent with your private key
2. Add WSL VM to known hosts
3. Copy build artifacts to `/opt/tasklistapp`
4. Restart the application service

## 🛠️ Local Development with Ansible

### Prerequisites

```bash
# Install Ansible
sudo apt update && sudo apt install -y ansible

# Install required Ansible collections
ansible-galaxy collection install community.docker
```

### Running the Playbook

1. Update `inventory.ini` with your WSL VM details:
   ```ini
   [wsl_vm]
   localhost ansible_port=2222 ansible_user=siseko
   ```

2. Run the playbook:
   ```bash
   ansible-playbook -i inventory.ini deploy_vm.yml
   ```

## 🔍 Troubleshooting

### SSH Connection Issues
- **Permission denied (publickey)**
  - Verify `~/.ssh/authorized_keys` contains the correct public key
  - Check file permissions (700 for .ssh, 600 for authorized_keys)

- **Connection refused**
  ```bash
  # Check if SSH server is running
  sudo service ssh status
  
  # Check if port 2222 is listening
  sudo ss -tulpn | grep 2222
  ```

### Ansible Playbook Issues
- **Docker permission denied**
  - Add your user to the docker group:
    ```bash
    sudo usermod -aG docker $USER
    newgrp docker
    ```

- **Missing dependencies**
  ```bash
  # Install required Python packages
  python3 -m pip install docker
  ```

## 🔒 Security Best Practices

1. **Key Management**
   - Never commit private keys to version control
   - Use a passphrase for your SSH key in production
   - Rotate keys regularly

2. **SSH Hardening**
   - Disable password authentication in `/etc/ssh/sshd_config`:
     ```
     PasswordAuthentication no
     ChallengeResponseAuthentication no
     UsePAM no
     ```
   - Restrict SSH access to specific users:
     ```
     AllowUsers siseko
     ```

3. **Firewall Rules**
   - Configure UFW to only allow port 2222 from trusted IPs:
     ```bash
     sudo ufw allow from YOUR_IP to any port 2222
     ```
