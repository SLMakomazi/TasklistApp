#!/bin/bash

# MicroK8s Setup Script for WSL Ubuntu
# This script sets up MicroK8s with all required addons for TasklistApp

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root for security reasons."
        print_error "Run as regular user with sudo privileges."
        exit 1
    fi
}

# Check WSL environment
check_wsl() {
    if ! grep -q Microsoft /proc/version; then
        print_warning "Not running in WSL environment. This script is optimized for WSL Ubuntu."
        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Update system packages
update_system() {
    print_status "Updating system packages..."
    sudo apt-get update -y
    sudo apt-get upgrade -y
    print_success "System updated successfully"
}

# Install required packages
install_packages() {
    print_status "Installing required packages..."
    
    packages=(
        curl
        wget
        apt-transport-https
        ca-certificates
        gnupg
        lsb-release
        jq
        htop
        tree
        unzip
        python3
        python3-pip
        software-properties-common
    )
    
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            print_status "Installing $package..."
            sudo apt-get install -y "$package"
        else
            print_status "$package is already installed"
        fi
    done
    
    print_success "Required packages installed"
}

# Install Docker
install_docker() {
    print_status "Installing Docker..."
    
    # Remove old Docker versions
    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Set up the stable repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker Engine
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add user to docker group
    sudo usermod -aG docker "$USER"
    
    # Enable and start Docker
    sudo systemctl enable docker
    sudo systemctl start docker
    
    print_success "Docker installed successfully"
    print_warning "You may need to log out and log back in for docker group changes to take effect"
}

# Install MicroK8s
install_microk8s() {
    print_status "Installing MicroK8s..."
    
    # Install MicroK8s
    sudo snap install microk8s --classic --channel=1.27/stable
    
    # Wait for MicroK8s to be ready
    print_status "Waiting for MicroK8s to start..."
    microk8s status --wait-ready
    
    # Add user to microk8s group
    sudo usermod -a -G microk8s "$USER"
    
    # Fix kubeconfig permissions
    sudo chown -f -R "$USER" ~/.kube
    
    print_success "MicroK8s installed successfully"
}

# Enable MicroK8s addons
enable_addons() {
    print_status "Enabling MicroK8s addons..."
    
    addons=(
        dns
        storage
        ingress
        dashboard
        metrics-server
        registry
        hostpath-storage
    )
    
    for addon in "${addons[@]}"; do
        print_status "Enabling $addon addon..."
        microk8s enable "$addon"
    done
    
    # Wait for addons to be ready
    print_status "Waiting for addons to be ready..."
    sleep 30
    
    # Verify addons are running
    microk8s kubectl wait --for=condition=available --timeout=300s deployment -n kube-system --all
    
    print_success "All addons enabled successfully"
}

# Configure kubectl
configure_kubectl() {
    print_status "Configuring kubectl..."
    
    # Create .kube directory
    mkdir -p "$HOME/.kube"
    
    # Get MicroK8s config
    microk8s config > "$HOME/.kube/config"
    
    # Set correct permissions
    chmod 600 "$HOME/.kube/config"
    
    # Add kubectl alias to bashrc
    if ! grep -q "alias kubectl=" ~/.bashrc; then
        echo 'alias kubectl="microk8s kubectl"' >> ~/.bashrc
    fi
    
    # Apply alias to current session
    alias kubectl="microk8s kubectl"
    
    print_success "kubectl configured successfully"
}

# Install and configure ArgoCD
install_argocd() {
    print_status "Installing ArgoCD..."
    
    # Create namespace
    kubectl create namespace argocd || true
    
    # Install ArgoCD
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    # Wait for ArgoCD to be ready
    print_status "Waiting for ArgoCD to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment -n argocd --all
    
    # Patch ArgoCD to use NodePort for external access
    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
    
    # Get ArgoCD admin password
    ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    
    # Get ArgoCD NodePort
    ARGOCD_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
    
    print_success "ArgoCD installed successfully"
    print_status "ArgoCD URL: http://$(hostname -I | awk '{print $1}'):$ARGOCD_PORT"
    print_status "ArgoCD Username: admin"
    print_status "ArgoCD Password: $ARGOCD_PASSWORD"
}

# Create application namespace
create_app_namespace() {
    print_status "Creating application namespace..."
    
    kubectl create namespace tasklist || true
    
    print_success "Application namespace created"
}

# Install JMeter
install_jmeter() {
    print_status "Installing JMeter..."
    
    # Download JMeter
    JMETER_VERSION="5.6.3"
    JMETER_URL="https://downloads.apache.org//jmeter/binaries/apache-jmeter-${JMETER_VERSION}.zip"
    
    cd /tmp
    wget -O jmeter.zip "$JMETER_URL"
    unzip -q jmeter.zip
    sudo mv "apache-jmeter-${JMETER_VERSION}" /opt/jmeter
    sudo chown -R "$USER:$USER" /opt/jmeter
    
    # Create JMeter symlink
    sudo ln -sf /opt/jmeter/bin/jmeter /usr/local/bin/jmeter
    
    # Clean up
    rm -f jmeter.zip
    
    print_success "JMeter installed successfully"
}

# Verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    echo "=== MicroK8s Status ==="
    microk8s status
    
    echo -e "\n=== Kubernetes Cluster Info ==="
    kubectl cluster-info
    
    echo -e "\n=== Nodes ==="
    kubectl get nodes -o wide
    
    echo -e "\n=== Namespaces ==="
    kubectl get namespaces
    
    echo -e "\n=== ArgoCD Status ==="
    kubectl get pods -n argocd
    
    echo -e "\n=== Addons Status ==="
    microk8s kubectl get all -n kube-system
    
    print_success "Installation verification completed"
}

# Create vault password file
create_vault_password() {
    print_status "Creating Ansible vault password file..."
    
    mkdir -p "$HOME"
    echo "ansible_vault_password_change_me" > "$HOME/.vault_pass.txt"
    chmod 600 "$HOME/.vault_pass.txt"
    
    print_success "Vault password file created at $HOME/.vault_pass.txt"
    print_warning "Please update the vault password with a secure password"
}

# Main execution
main() {
    print_status "Starting MicroK8s setup for WSL Ubuntu..."
    
    check_root
    check_wsl
    
    update_system
    install_packages
    install_docker
    install_microk8s
    enable_addons
    configure_kubectl
    install_argocd
    create_app_namespace
    install_jmeter
    create_vault_password
    verify_installation
    
    print_success "MicroK8s setup completed successfully!"
    echo
    print_status "Next steps:"
    echo "1. Log out and log back in to apply group membership changes"
    echo "2. Update the vault password: $HOME/.vault_pass.txt"
    echo "3. Access ArgoCD at the URL shown above"
    echo "4. Configure your GitHub Actions self-hosted runner"
    echo
    print_warning "Remember to reload your shell: source ~/.bashrc"
}

# Run main function
main "$@"
