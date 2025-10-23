#!/bin/bash
# Ansible Deployment Script for Tasklist Application

set -e

echo "==========================================="
echo "🚀 Ansible Tasklist Deployment"
echo "==========================================="

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$SCRIPT_DIR"
JAR_FILE="$1"

if [ -z "$JAR_FILE" ]; then
    echo "❌ Error: Please provide the path to the JAR file"
    echo "Usage: $0 <path-to-jar-file>"
    exit 1
fi

if [ ! -f "$JAR_FILE" ]; then
    echo "❌ Error: JAR file not found: $JAR_FILE"
    exit 1
fi

echo "📦 JAR file: $JAR_FILE"

# Check if Ansible is installed
if ! command -v ansible >/dev/null 2>&1; then
    echo "📦 Installing Ansible..."
    sudo apt update
    sudo apt install -y ansible
fi

# Install Ansible Galaxy roles (if requirements.yml exists)
if [ -f "$ANSIBLE_DIR/requirements.yml" ]; then
    echo "📚 Installing Ansible Galaxy roles..."
    cd "$ANSIBLE_DIR"
    ansible-galaxy install -r requirements.yml
fi

# Update inventory with JAR file path
echo "🔧 Updating Ansible variables..."
sed -i.bak "s|jar_file_path.*|jar_file_path=$JAR_FILE|" "$ANSIBLE_DIR/inventory.ini"

# Run Ansible playbook
echo "🎯 Running Ansible deployment..."
cd "$ANSIBLE_DIR"
ansible-playbook -i inventory.ini deploy.yml -v

echo "✅ Deployment completed successfully!"

# Show service status
echo "📊 Checking service status..."
ansible -i inventory.ini tasklist_servers -m systemd -a "name=tasklist state=started" || echo "Service check completed"

echo "🎉 Tasklist application deployed and running!"
