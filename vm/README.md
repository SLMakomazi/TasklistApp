# VM Deployment - TasklistApp

This directory contains the VM deployment configuration for the TasklistApp. The VM deployment runs the Spring Boot application as a systemd service and connects to the same PostgreSQL database used by the Docker and Kubernetes deployments.

## Table of Contents

- [VM Deployment Overview](#vm-deployment-overview)
- [VM Setup](#vm-setup)
- [GitHub Actions Runner Setup](#github-actions-runner-setup)
- [Application Deployment](#application-deployment)
- [Service Management](#service-management)
- [Service Configuration](#service-configuration)
- [Troubleshooting](#troubleshooting)

## 🖥️ MicroK8s Setup in WSL2 Ubuntu

This section covers the complete setup of MicroK8s and ArgoCD in WSL2 Ubuntu environment for local Kubernetes development.

### Prerequisites
- **Windows 11** with WSL2 enabled
- **Ubuntu 22.04** installed via Microsoft Store or `wsl --install`
- **Docker Desktop** (optional, for container development)

### Step 1: Update Ubuntu and Install Snap
```bash
# Update package lists
sudo apt update && sudo apt upgrade -y

# Install snapd (required for MicroK8s)
sudo apt install snapd -y

# Enable snap socket
sudo systemctl enable --now snapd.socket
```

### Step 2: Install MicroK8s
```bash
# Install MicroK8s via snap
sudo snap install microk8s --classic

# Add user to microk8s group
sudo usermod -aG microk8s $USER

# Apply group changes (or logout/login)
newgrp microk8s
```

### Step 3: Start MicroK8s and Enable Addons
```bash
# Start MicroK8s cluster
microk8s start

# Wait for cluster to be ready
microk8s status --wait-ready

# Enable essential addons for TasklistApp
microk8s enable ingress dns dashboard metrics-server registry hostpath-storage

# Verify cluster status
microk8s kubectl get nodes
```

### Step 4: Setup kubectl Alias
```bash
# Add kubectl alias to bashrc
echo "alias kubectl='microk8s kubectl'" >> ~/.bashrc

# Apply changes
source ~/.bashrc

# Verify alias works
kubectl get nodes
```

### Step 5: Install ArgoCD
```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD with all CRDs
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Check ArgoCD pods
kubectl get pods -n argocd
```

### Step 6: Access ArgoCD Dashboard
```bash
# Port-forward ArgoCD UI (avoiding common ports)
kubectl port-forward svc/argocd-server -n argocd 9090:443

# Alternative ports if 9090 is taken:
# kubectl port-forward svc/argocd-server -n argocd 9091:443

# Access ArgoCD at: https://localhost:9090
# Username: admin
# Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Step 7: Deploy TasklistApp via ArgoCD
```bash
# Apply ArgoCD application manifest
kubectl apply -f k8s/argocd-application.yaml

# Check application status
kubectl get applications -n argocd

# Verify sync status
kubectl describe application tasklistapp -n argocd
```

### Step 8: Access TasklistApp
```bash
# Port-forward TasklistApp (avoiding port conflicts)
kubectl port-forward -n tasklistapp svc/tasklistapp-service 8081:80

# Alternative ports:
# kubectl port-forward -n tasklistapp svc/tasklistapp-service 8082:80

# Access at: http://localhost:8081/api/tasks
# Swagger UI: http://localhost:8081/swagger-ui.html
```

## VM Deployment Overview

### Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    VM Deployment (Operational)           │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐    │
│  │            tasklist-postgres Container           │    │
│  │  • PostgreSQL 16 Database                          │    │
│  │  • Shared with Docker & Kubernetes deployments     │    │
│  │  • Persistent Docker volume                        │    │
│  └─────────────────────────────────────────────────────┘    │
│                    │ Docker Network                     │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              VM Host Machine                     │    │
│  │  • Spring Boot JAR deployed                        │    │
│  │  • Systemd service management                      │    │
│  │  • Connects to shared PostgreSQL                   │    │
│  └─────────────────────────────────────────────────────┘    │
│                    │ GitHub Container Registry           │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Kubernetes Cluster                    │    │
│  │  • MicroK8s with ArgoCD GitOps                     │    │
│  │  • Multi-replica deployment                        │    │
│  │  • Shared PostgreSQL database                      │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────┐
│              Access Points                       │
├─────────────────────────────────────────────────────┤
│  • VM API: http://vm-ip:8080/api/tasks              │
│  • Kubernetes API: http://cluster-ip/api/tasks     │
│  • VM Swagger: http://vm-ip:8080/swagger-ui.html    │
│  • Docker API: http://localhost:8080/api/tasks      │
└─────────────────────────────────────────────────────┘
```

### Key Features
- **Systemd Service** - Production-grade service management
- **Shared Database** - Same PostgreSQL as Docker and Kubernetes deployments
- **Data Consistency** - All deployments access same data
- **Hot Deployment** - Update JAR without downtime
- **Alternative to Kubernetes** - For environments where Kubernetes is not suitable

### Deployment Options Comparison

| Feature | VM Deployment | Kubernetes Deployment |
|---------|---------------|----------------------|
| **Scalability** | Single instance | Multi-replica |
| **Management** | Manual systemd | ArgoCD GitOps |
| **Updates** | Manual JAR replacement | Automatic via Git |
| **Resources** | Single server | Cluster orchestration |
| **Complexity** | Simple | More complex |
| **Use Case** | Single server, dedicated hosting | Cloud-native, scalable apps |

- **Service Monitoring** - Logs and status checking
- **Security** - Non-root service execution

## VM Setup

### Prerequisites
- **Ubuntu/Debian Linux** system
- **Java 17** installed
- **Systemd** for service management
- **Network access** to Docker host (for database connection)
- **SSH access** with sudo privileges

### Install Required Software
```bash
# Update package index
sudo apt update

# Install Java 17
sudo apt install -y openjdk-17-jdk

# Verify Java installation
java -version
```

### Create Application User and Directories

#### Required Directories
The VM deployment uses specific directories with proper permissions:

- **`/opt/tasklist/app`**: Application JAR file location
- **`/opt/tasklist/logs`**: Application log files
- **`/opt/tasklist/scripts`**: Deployment scripts (optional)

#### Directory Setup Commands
```bash
# Create tasklist user (non-interactive user for security)
sudo useradd -r -s /bin/false siseko

# Create application directories
sudo mkdir -p /opt/tasklist/app
sudo mkdir -p /opt/tasklist/logs
sudo mkdir -p /opt/tasklist/scripts

# Set ownership (application runs as 'siseko' user)
sudo chown -R siseko:siseko /opt/tasklist

# Set permissions
sudo chmod 755 /opt/tasklist
sudo chmod 755 /opt/tasklist/app
sudo chmod 755 /opt/tasklist/logs
sudo chmod 755 /opt/tasklist/scripts
```

#### Directory Structure After Setup
```
/opt/tasklist/
├── app/
│   └── tasklist-api.jar          # Spring Boot JAR file
├── logs/
│   └── tasklist.log             # Application logs
└── scripts/                     # Optional deployment scripts
```

## GitHub Actions Runner Setup

The VM deployment includes a GitHub Actions self-hosted runner that automatically picks up deployment jobs from your GitHub repository. This enables automated CI/CD deployment to the VM.

### Complete Workflow Process

#### Step 1: Push Changes to GitHub
```bash
# From your development machine
git add .
git commit -m "Your changes"
git push origin main
```

#### Step 2: Start the Runner on VM
```bash
# SSH to your VM and navigate to runner directory
cd ~/actions-runner

# Start the runner (this connects to GitHub Actions)
./run.sh
```

**Expected Output:**
```
√ Connected to GitHub

Current runner version: '2.320.0'
2025-10-23 15:11:40Z: Listening for Jobs
```

#### Step 3: Trigger Deployment
The `vm-deploy.yml` workflow will automatically:
1. Build your Spring Boot application
2. Deploy it to the VM
3. Start the systemd service
4. Verify the deployment

#### Step 4: Monitor the Process
```bash
# On VM - Watch deployment in real-time
sudo journalctl -u actions-runner -f

# Check if service starts successfully
sudo systemctl status tasklist

# View application logs
sudo tail -f /opt/tasklist/logs/tasklist.log
```

### Architecture with Runner

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Actions Workflow              │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐    │
│  │              GitHub.com                             │    │
│  │  • Triggers on push to main branch                  │    │
│  │  • Sends job to self-hosted runner                  │    │
│  └─────────────────────────────────────────────────────┘    │
│                    │ SSH/HTTPS Connection               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │               VM Runner                             │    │
│  │  • Listens for GitHub jobs                          │    │
│  │  • Executes vm-deploy.yml workflow                  │    │
│  │  • Deploys application to VM                        │    │
│  └─────────────────────────────────────────────────────┘    │
│                    │ Systemd Service                   │
│  ┌─────────────────────────────────────────────────────┐    │
│  │            TasklistApp Service                      │    │
│  │  • Spring Boot application                          │    │
│  │  • Connects to PostgreSQL                           │    │
│  │  • Serves API endpoints                             │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### Runner Setup Prerequisites

- **GitHub Repository**: Must have a `vm-deploy.yml` workflow configured
- **Runner Token**: Personal Access Token with `repo` permissions
- **Network Access**: VM must be able to connect to GitHub (github.com)
- **User Account**: Runner should run as non-root user

### Runner Management

#### Start Runner
```bash
# Option 1: Manual start (recommended for deployment)
cd ~/actions-runner
./run.sh

# Option 2: As systemd service
sudo systemctl start actions-runner
```

#### Stop Runner
```bash
# Stop the service
sudo systemctl stop actions-runner

# Or kill the process
pkill -f "actions.runner"
```

#### Check Runner Status
```bash
# Check service status
sudo systemctl status actions-runner

# Check if runner process is running
ps aux | grep -i runner

# View real-time logs
sudo journalctl -u actions-runner -f
```

### Troubleshooting Runner Issues

#### Runner Won't Start
```bash
# Check runner configuration
cd ~/actions-runner
./config.sh --check

# Verify network connectivity
ping github.com

# Check runner logs
sudo journalctl -u actions-runner -n 100
```

#### Runner Not Picking Up Jobs
```bash
# Check if runner is registered on GitHub
# Go to Repository Settings → Actions → Runners

# Verify runner is running and listening
ps aux | grep -i runner

# Check runner logs for connection errors
sudo journalctl -u actions-runner -f | grep -i error
```

#### Authentication Issues
```bash
# Reconfigure runner with new token
cd ~/actions-runner
./config.sh --url https://github.com/YOUR_USERNAME/YOUR_REPOSITORY --token NEW_TOKEN

# Restart runner service
sudo systemctl restart actions-runner
```

## Application Deployment

### Manual Deployment (Step by Step)

#### Step 1: Build and Copy JAR to VM
```bash
# From development machine - build the application
cd /path/to/TasklistApp/app
mvn clean package -DskipTests

# Copy JAR to VM
scp target/tasklist-api-*.jar user@vm-ip:/tmp/
```

#### Step 2: Deploy Application on VM
```bash
# SSH to VM
ssh user@vm-ip

# Move JAR to application directory
sudo mv /tmp/tasklist-api-*.jar /opt/tasklist/app/tasklist-api.jar

# Set ownership and permissions
sudo chown siseko:siseko /opt/tasklist/app/tasklist-api.jar
sudo chmod 644 /opt/tasklist/app/tasklist-api.jar

# Create log file if it doesn't exist
sudo touch /opt/tasklist/logs/tasklist.log
sudo chown siseko:siseko /opt/tasklist/logs/tasklist.log
```

#### Step 3: Configure Application (if needed)
```bash
# Create application configuration (optional - uses environment variables by default)
sudo tee /opt/tasklist/app/application.properties > /dev/null <<EOF
# Database Configuration
spring.datasource.url=jdbc:postgresql://docker-host-ip:5432/tasklistdb
spring.datasource.username=postgres
spring.datasource.password=admin

# Server Configuration
server.port=8080

# Logging
logging.file.name=/opt/tasklist/logs/tasklist.log
logging.level.com.tasklist=DEBUG
EOF

sudo chown siseko:siseko /opt/tasklist/app/application.properties
```

#### Step 4: Install and Start Service
```bash
# Copy service file to systemd
sudo cp /path/to/TasklistApp/vm/service/tasklist.service /etc/systemd/system/tasklist.service

# Set proper ownership
sudo chown root:root /etc/systemd/system/tasklist.service
sudo chmod 644 /etc/systemd/system/tasklist.service

# Reload systemd configuration
sudo systemctl daemon-reload

# Enable service to start on boot
sudo systemctl enable tasklist

# Start the service
sudo systemctl start tasklist

# Check service status
sudo systemctl status tasklist
```

## Service Management

### Check Service Status
```bash
# View service status
sudo systemctl status tasklist

# Check if service is running
sudo systemctl is-active tasklist

# View service logs (journalctl)
sudo journalctl -u tasklist -f --no-pager

# View last 50 log lines
sudo journalctl -u tasklist -n 50
```

### Service Control Commands
```bash
# Start service
sudo systemctl start tasklist

# Stop service
sudo systemctl stop tasklist

# Restart service (for updates)
sudo systemctl restart tasklist

# Reload service configuration (without restart)
sudo systemctl reload tasklist

# Disable service (prevent auto-start on boot)
sudo systemctl disable tasklist

# Enable service (auto-start on boot)
sudo systemctl enable tasklist
```

### View Application Logs
```bash
# View real-time application logs
sudo tail -f /opt/tasklist/logs/tasklist.log

# View last 100 lines
sudo tail -n 100 /opt/tasklist/logs/tasklist.log

# Search for errors
sudo grep -i "error\|exception" /opt/tasklist/logs/tasklist.log

# Monitor database connections
sudo grep -i "hikaricp\|connection" /opt/tasklist/logs/tasklist.log
```

### Reload/Restart Service After Updates

#### After JAR File Update
```bash
# 1. Copy new JAR to VM
scp target/tasklist-api-*.jar user@vm-ip:/tmp/

# 2. SSH to VM and deploy
ssh user@vm-ip
sudo mv /tmp/tasklist-api-*.jar /opt/tasklist/app/tasklist-api.jar
sudo chown siseko:siseko /opt/tasklist/app/tasklist-api.jar

# 3. Restart service to load new JAR
sudo systemctl restart tasklist

# 4. Verify deployment
sudo systemctl status tasklist
curl http://vm-ip:8080/api/tasks
```

#### After Configuration Changes
```bash
# 1. Update configuration files (e.g., environment variables in service file)
sudo nano /etc/systemd/system/tasklist.service

# 2. Reload systemd configuration
sudo systemctl daemon-reload

# 3. Restart service to apply changes
sudo systemctl restart tasklist

# 4. Verify changes took effect
sudo systemctl status tasklist
```

## Service Configuration

### tasklist.service Configuration

The systemd service file (`vm/service/tasklist.service`) is configured with:

#### Service Section
```ini
[Service]
Type=simple
User=siseko                    # Non-root user for security
Group=siseko
ExecStart=/usr/bin/java -jar /opt/tasklist/app/tasklist-api.jar
ExecStop=/bin/kill -TERM $MAINPID
Restart=always                # Auto-restart on failure
RestartSec=10                 # Wait 10 seconds before restart

# Environment variables for Spring Boot placeholders
Environment=DB_URL=jdbc:postgresql://192.168.18.3:5432/tasklistdb
Environment=DB_USERNAME=postgres
Environment=DB_PASSWORD=admin
Environment=JPA_DDL_AUTO=update
Environment=JPA_SHOW_SQL=true
Environment=SERVER_PORT=8080
Environment=LOG_LEVEL_SPRING=INFO
Environment=LOG_LEVEL_TASKLIST=DEBUG
Environment=LOG_FILE=/opt/tasklist/logs/tasklist.log

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/tasklist/logs

# Resource limits
LimitNOFILE=65536
MemoryLimit=512M

# Logging (output to journal for systemctl status/logs)
StandardOutput=journal
StandardError=journal
```

#### Environment Variables in Service
The service uses environment variables that map to Spring Boot application properties:

| Environment Variable | Application Property | Description |
|---------------------|---------------------|-------------|
| `DB_URL` | `spring.datasource.url` | PostgreSQL connection URL |
| `DB_USERNAME` | `spring.datasource.username` | Database username |
| `DB_PASSWORD` | `spring.datasource.password` | Database password |
| `SERVER_PORT` | `server.port` | Application server port (8080) |
| `JPA_DDL_AUTO` | `spring.jpa.hibernate.ddl-auto` | Schema auto-update |
| `JPA_SHOW_SQL` | `spring.jpa.show-sql` | Show SQL queries in logs |
| `LOG_LEVEL_SPRING` | `logging.level.org.springframework` | Spring framework logging |
| `LOG_LEVEL_TASKLIST` | `logging.level.com.tasklist` | Application logging |
| `LOG_FILE` | `logging.file.name` | Log file location |

#### Install Section
```ini
[Install]
WantedBy=multi-user.target    # Start when system reaches multi-user runlevel
```

## Troubleshooting

### Common Issues

#### Service Won't Start
```bash
# Check service status for detailed error messages
sudo systemctl status tasklist

# View recent logs
sudo journalctl -u tasklist -n 100

# Check if JAR file exists and is readable
ls -la /opt/tasklist/app/tasklist-api.jar

# Verify Java process
ps aux | grep java

# Check service file syntax
sudo systemd-analyze verify /etc/systemd/system/tasklist.service
```

#### Database Connection Issues
```bash
# Test database connectivity from VM
nc -zv docker-host-ip 5432

# Check database credentials in service environment
sudo systemctl show-environment | grep DB_

# Test manual database connection
sudo -u siseko psql -h docker-host-ip -p 5432 -U postgres -d tasklistdb

# Check network routing
ip route show
```

#### Application Logs Show Errors
```bash
# View application logs for details
sudo tail -f /opt/tasklist/logs/tasklist.log

# Look for specific error patterns
sudo grep -i "error\|exception\|failed" /opt/tasklist/logs/tasklist.log

# Check JVM memory and garbage collection
sudo grep -i "memory\|gc\|heap" /opt/tasklist/logs/tasklist.log

# Verify all required directories exist and have correct permissions
ls -la /opt/tasklist/
```

#### Port Already in Use
```bash
# Check what's using port 8080
sudo netstat -tulpn | grep :8080

# Stop conflicting service
sudo systemctl stop conflicting-service

# Or change application port in service file
sudo sed -i 's/SERVER_PORT=8080/SERVER_PORT=8081/' /etc/systemd/system/tasklist.service
sudo systemctl daemon-reload
sudo systemctl restart tasklist
```

### Service Configuration Issues
```bash
# Validate service file syntax
sudo systemd-analyze verify /etc/systemd/system/tasklist.service

# Check service dependencies
sudo systemctl list-dependencies tasklist

# View service environment variables
sudo systemctl show-environment

# Check service file permissions
ls -la /etc/systemd/system/tasklist.service
```

## Related Documentation

- **Main Project**: [../README.md](../README.md) - Complete project overview
- **Spring Boot App**: [../app/README.md](../app/README.md) - Application development guide
- **Database Setup**: [../database/README.md](../database/README.md) - Database management guide