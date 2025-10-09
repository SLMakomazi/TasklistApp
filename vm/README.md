# 🖥️ VM Deployment - TasklistApp

**✅ OPERATIONAL** - This directory contains the **VM deployment configuration** for the TasklistApp. The VM deployment runs the Spring Boot application as a systemd service and connects to the same PostgreSQL database used by the Docker deployment.

![Linux](https://img.shields.io/badge/Linux-VM-orange)
![Systemd](https://img.shields.io/badge/Systemd-Service-blue)
![Status](https://img.shields.io/badge/Status-Operational-success)

## 📋 Table of Contents

- [🏗️ VM Deployment Overview](#-vm-deployment-overview)
- [🚀 Current Status](#-current-status)
- [📁 Directory Structure](#-directory-structure)
- [🔧 VM Setup](#-vm-setup)
- [🚀 Application Deployment](#-application-deployment)
- [🔍 Service Management](#-service-management)
- [✅ Data Consistency Verification](#-data-consistency-verification)
- [🛠️ Troubleshooting](#-troubleshooting)

## 🏗️ VM Deployment Overview

### Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    🖥️ VM Deployment (Operational)           │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐    │
│  │            🐳 tasklist-postgres Container           │    │
│  │  • PostgreSQL 16 Database                          │    │
│  │  • Shared with Docker deployment                   │    │
│  │  • Persistent Docker volume                        │    │
│  └─────────────────────────────────────────────────────┘    │
│                    │ Docker Network                     │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              💻 VM Host Machine                     │    │
│  │  • Spring Boot JAR deployed                        │    │
│  │  • Systemd service management                      │    │
│  │  • Connects to Docker PostgreSQL                   │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────┐
│              🌐 Access Points                       │
├─────────────────────────────────────────────────────┤
│  • VM API: http://192.168.18.3:8080/api/tasks       │
│  • VM Swagger: http://192.168.18.3:8080/swagger-ui.html │
│  • Docker API: http://localhost:8080/api/tasks      │
└─────────────────────────────────────────────────────┘
```

### Key Features
- ✅ **Systemd Service** - Production-grade service management
- ✅ **Shared Database** - Same PostgreSQL as Docker deployment
- ✅ **Data Consistency** - Both deployments access same data
- ✅ **Hot Deployment** - Update JAR without downtime
- ✅ **Service Monitoring** - Logs and status checking
- ✅ **Security** - Non-root service execution

## 🚀 Current Status

### **🎯 VM Deployment is LIVE and Operational!**

| Component | Status | Details |
|-----------|--------|---------|
| **VM Application** | ✅ Running | Spring Boot JAR via systemd |
| **Database Connection** | ✅ Connected | Same PostgreSQL as Docker |
| **Service Management** | ✅ Active | `tasklist.service` running |
| **API Endpoints** | ✅ Ready | All CRUD operations functional |
| **Data Consistency** | ✅ Verified | Same data as Docker deployment |
| **Service Logs** | ✅ Available | Comprehensive logging |

### **🌐 Access Points**
- **VM API**: http://192.168.18.3:8080/api/tasks
- **VM Swagger**: http://192.168.18.3:8080/swagger-ui.html
- **Docker API**: http://localhost:8080/api/tasks (for comparison)
- **Database**: Shared PostgreSQL container

## 📁 Directory Structure

```
vm/
├── 📄 README.md                 # This file - VM deployment guide
├── 📁 service/                  # Systemd service configuration
│   └── 📄 tasklist.service      # Tasklist systemd service
├── 📁 logs/                    # Application logs
│   └── 📄 tasklist.log         # Service logs
└── 📁 scripts/                 # Deployment scripts
    ├── 📄 deploy.sh           # Automated deployment script
    └── 📄 update.sh           # Application update script
```

## 🔧 VM Setup

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
```bash
# Create tasklist user
sudo useradd -r -s /bin/false tasklist

# Create application directories
sudo mkdir -p /opt/tasklist/app
sudo mkdir -p /opt/tasklist/logs
sudo mkdir -p /opt/tasklist/scripts

# Set ownership
sudo chown -R tasklist:tasklist /opt/tasklist

# Set permissions
sudo chmod 755 /opt/tasklist
sudo chmod 755 /opt/tasklist/app
sudo chmod 755 /opt/tasklist/logs
```

## 🚀 Application Deployment

### Manual Deployment (Step by Step)

#### Step 1: Copy JAR to VM
```bash
# From your development machine
scp -i path/to/your-key target/tasklist-api-0.0.1-SNAPSHOT.jar tasklist@<VM_IP>:/tmp/

# Alternative: Use curl/wget if accessible
curl -o /tmp/tasklist-api.jar http://your-jenkins-server/job/lastSuccessfulBuild/artifact/target/tasklist-api.jar
```

#### Step 2: Deploy Application
```bash
# SSH to VM
ssh -i path/to/your-key tasklist@<VM_IP>

# Move JAR to application directory
sudo mv /tmp/tasklist-api-*.jar /opt/tasklist/app/tasklist-api.jar

# Set ownership
sudo chown tasklist:tasklist /opt/tasklist/app/tasklist-api.jar

# Set permissions
sudo chmod 644 /opt/tasklist/app/tasklist-api.jar
```

#### Step 3: Configure Application
```bash
# Create application configuration
sudo tee /opt/tasklist/app/application.properties > /dev/null <<EOF
# Database Configuration
spring.datasource.url=jdbc:postgresql://<DOCKER_HOST_IP>:5432/tasklistdb
spring.datasource.username=postgres
spring.datasource.password=admin
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# Server Configuration
server.port=8080

# Logging
logging.file.name=/opt/tasklist/logs/tasklist.log
logging.level.com.tasklist=DEBUG
EOF

# Set ownership
sudo chown tasklist:tasklist /opt/tasklist/app/application.properties
```

#### Step 4: Install and Start Service
```bash
# Copy service file (if not already present)
sudo cp /opt/tasklist/scripts/tasklist.service /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable service
sudo systemctl enable tasklist

# Start service
sudo systemctl start tasklist

# Check status
sudo systemctl status tasklist
```

### Automated Deployment Script
```bash
#!/bin/bash
# deploy.sh - Automated VM deployment

JAR_URL="http://your-build-server/tasklist-api.jar"
DOCKER_HOST="192.168.18.1"  # Your Docker host IP

# Download latest JAR
wget -O /tmp/tasklist-api.jar $JAR_URL

# Deploy application
sudo mv /tmp/tasklist-api.jar /opt/tasklist/app/
sudo chown tasklist:tasklist /opt/tasklist/app/tasklist-api.jar

# Update database configuration
sudo sed -i "s/<DOCKER_HOST_IP>/$DOCKER_HOST/" /opt/tasklist/app/application.properties

# Restart service
sudo systemctl restart tasklist

# Check deployment
sudo systemctl status tasklist
echo "Deployment completed successfully!"
```

## 🔍 Service Management

### Check Service Status
```bash
# View service status
sudo systemctl status tasklist

# Check if service is running
sudo systemctl is-active tasklist

# View service logs
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

# Restart service
sudo systemctl restart tasklist

# Reload service configuration
sudo systemctl reload tasklist

# Disable service (prevent auto-start)
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

## ✅ Data Consistency Verification

### Verify Data Consistency Between Deployments
```bash
# Check data in shared PostgreSQL database
docker exec -it tasklist-postgres psql -U postgres -d tasklistdb -c "SELECT id, title, completed FROM task ORDER BY id;"

# Check data from Docker API
curl -s http://localhost:8080/api/tasks | jq '.[] | {id, title, completed}'

# Check data from VM API
curl -s http://192.168.18.3:8080/api/tasks | jq '.[] | {id, title, completed}'
```

**Expected Result:** All three sources should return identical data, confirming both Docker and VM deployments access the same database.

### Test Data Persistence Across Deployments
```bash
# 1. Create task via Docker API
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Cross-Deployment Test","completed":false}'

# 2. Verify in database
docker exec -it tasklist-postgres psql -U postgres -d tasklistdb -c "SELECT * FROM task WHERE title = 'Cross-Deployment Test';"

# 3. Verify via VM API
curl -s http://192.168.18.3:8080/api/tasks | jq '.[] | select(.title == "Cross-Deployment Test")'

# 4. Restart VM service
sudo systemctl restart tasklist

# 5. Verify data still accessible via VM API
curl -s http://192.168.18.3:8080/api/tasks | jq '.[] | select(.title == "Cross-Deployment Test")'
```

## 🛠️ Troubleshooting

### Common Issues

**Service Won't Start**
```bash
# Check service status
sudo systemctl status tasklist

# View detailed logs
sudo journalctl -u tasklist -n 100

# Check Java process
ps aux | grep java

# Verify JAR file exists and is readable
ls -la /opt/tasklist/app/tasklist-api.jar
```

**Database Connection Issues**
```bash
# Test database connectivity from VM
nc -zv <DOCKER_HOST_IP> 5432

# Check database credentials in config
cat /opt/tasklist/app/application.properties

# Test manual database connection
psql -h <DOCKER_HOST_IP> -p 5432 -U postgres -d tasklistdb

# Check network routing
ip route show
```

**Application Logs Show Errors**
```bash
# Check application logs for details
sudo tail -f /opt/tasklist/logs/tasklist.log

# Look for specific error patterns
sudo grep -i "error\|exception\|failed" /opt/tasklist/logs/tasklist.log

# Check JVM memory and GC
sudo grep -i "memory\|gc\|heap" /opt/tasklist/logs/tasklist.log

# Verify environment variables
env | grep -E "(DB_|JPA_|SPRING_)"
```

**Port Already in Use**
```bash
# Check what's using port 8080
sudo netstat -tulpn | grep :8080

# Stop conflicting service
sudo systemctl stop conflicting-service

# Or change application port
sudo sed -i 's/server.port=8080/server.port=8081/' /opt/tasklist/app/application.properties
sudo systemctl restart tasklist
```

### Service Configuration Issues
```bash
# Validate service file syntax
sudo systemd-analyze verify /etc/systemd/system/tasklist.service

# Check service dependencies
sudo systemctl list-dependencies tasklist

# View service environment
sudo systemctl show-environment

# Check service file permissions
ls -la /etc/systemd/system/tasklist.service
```

## 📊 Monitoring & Maintenance

### System Resource Monitoring
```bash
# Check system resource usage
top -u tasklist

# Monitor memory usage
free -h

# Check disk usage
df -h

# Monitor network connections
ss -tulpn | grep :8080
```

### Application Health Checks
```bash
# Test VM API health
curl http://192.168.18.3:8080/actuator/health

# Compare with Docker API
curl http://localhost:8080/actuator/health

# Check database connectivity from VM
sudo -u tasklist psql -h <DOCKER_HOST_IP> -p 5432 -U postgres -d tasklistdb -c "SELECT 1;"
```

### Log Rotation and Management
```bash
# Check log file size
sudo du -sh /opt/tasklist/logs/tasklist.log

# Rotate logs if too large
sudo mv /opt/tasklist/logs/tasklist.log /opt/tasklist/logs/tasklist.log.$(date +%Y%m%d_%H%M%S)

# Create new log file
sudo touch /opt/tasklist/logs/tasklist.log
sudo chown tasklist:tasklist /opt/tasklist/logs/tasklist.log

# Restart service to use new log file
sudo systemctl restart tasklist
```

## 🚀 Production Deployment

### Security Hardening
```bash
# Create non-root user for application
sudo useradd -r -s /bin/false -d /opt/tasklist tasklist

# Set restrictive permissions
sudo chmod 750 /opt/tasklist
sudo chmod 640 /opt/tasklist/app/application.properties

# Configure firewall
sudo ufw allow from <DOCKER_HOST_SUBNET> to any port 5432
sudo ufw allow 8080

# Enable firewall
sudo ufw enable
```

### High Availability Setup
```bash
# Load balancing between Docker and VM
# Configure nginx as reverse proxy
sudo tee /etc/nginx/sites-available/tasklist <<EOF
upstream tasklist_backend {
    server 127.0.0.1:8080;      # Docker API
    server 192.168.18.3:8080;   # VM API
}

server {
    listen 80;
    location / {
        proxy_pass http://tasklist_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Enable site
sudo ln -s /etc/nginx/sites-available/tasklist /etc/nginx/sites-enabled/
sudo systemctl reload nginx
```

### Backup Strategy
```bash
#!/bin/bash
# backup.sh - Backup VM deployment

BACKUP_DIR="/backup/vm-deployment"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup application files
cp /opt/tasklist/app/tasklist-api.jar $BACKUP_DIR/app_$DATE.jar
cp /opt/tasklist/app/application.properties $BACKUP_DIR/config_$DATE.properties

# Backup logs
cp /opt/tasklist/logs/tasklist.log $BACKUP_DIR/logs_$DATE.log

# Create tar archive
tar -czf $BACKUP_DIR/vm-deployment-backup-$DATE.tar.gz $BACKUP_DIR/

echo "Backup completed: $BACKUP_DIR/vm-deployment-backup-$DATE.tar.gz"
```

## 📄 Related Documentation

- **Main Project**: [../README.md](../README.md) - Complete project overview
- **Spring Boot App**: [../app/README.md](../app/README.md) - Application development guide
- **Database Setup**: [../database/README.md](../database/README.md) - Database management guide

---

**🖥️ VM Deployment Ready!** Production-grade systemd service with shared database = 🚀