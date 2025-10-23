#!/bin/bash
# VM Setup Script for Tasklist Ansible Deployment

set -e

echo "==========================================="
echo "🔧 Setting up VM for Ansible Deployment"
echo "==========================================="

# Update package list
echo "📦 Updating package list..."
sudo apt update

# Install required packages
echo "📦 Installing required packages..."
sudo apt install -y ansible ssh openssh-server software-properties-common

# Start SSH service if not running
echo "🔑 Ensuring SSH service is running..."
sudo systemctl enable ssh
sudo systemctl start ssh

# Create ansible user if it doesn't exist
if ! id "ansible" &>/dev/null; then
    echo "👤 Creating ansible user..."
    sudo useradd -m -s /bin/bash ansible
    sudo usermod -aG sudo ansible
    echo "ansible:ansible" | sudo chpasswd
fi

# Set up SSH key for GitHub Actions (replace with your actual public key)
echo "🔐 Setting up SSH keys for deployment..."
sudo mkdir -p /home/ansible/.ssh
sudo tee /home/ansible/.ssh/authorized_keys > /dev/null << 'EOF'
# Replace this with your actual GitHub Actions public key
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7jI1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890 your-github-actions-key
EOF

sudo chown -R ansible:ansible /home/ansible/.ssh
sudo chmod 600 /home/ansible/.ssh/authorized_keys
sudo chmod 700 /home/ansible/.ssh

# Test Ansible installation
echo "🧪 Testing Ansible installation..."
ansible --version

# Create necessary directories for the application
echo "📁 Creating application directories..."
sudo mkdir -p /opt/tasklist/app
sudo mkdir -p /opt/tasklist/logs
sudo chown -R siseko:siseko /opt/tasklist

echo "✅ VM setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Update inventory.ini with your VM's IP address"
echo "2. Replace the SSH public key in /home/ansible/.ssh/authorized_keys"
echo "3. Run the deployment from GitHub Actions"
echo ""
echo "🔍 To test Ansible connection:"
echo "ansible -i vm/ansible/inventory.ini -m ping tasklist_servers"
