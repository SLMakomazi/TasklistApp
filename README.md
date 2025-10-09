# 🚀 TasklistApp - Task Management API

**✅ FULLY OPERATIONAL** - A modern, containerized task management application built with **Spring Boot 3.3.4**, **PostgreSQL 16**, and **Docker**. This production-ready application provides RESTful API endpoints for managing tasks with complete CRUD operations, data persistence, and comprehensive API documentation.

![Java](https://img.shields.io/badge/Java-17-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.3.4-brightgreen)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue)
![Docker](https://img.shields.io/badge/Docker-Ready-blue)
![VM](https://img.shields.io/badge/VM-Deployed-green)
![Status](https://img.shields.io/badge/Status-Operational-success)

## 📋 Table of Contents

- [🏗️ Architecture](#-architecture)
- [✨ Features](#-features)
- [🚀 Current Status](#-current-status)
- [📁 Project Structure](#-project-structure)
- [🚀 Setup and Run](#-setup-and-run)
- [✅ Persistence Verification](#-persistence-verification)
- [🖥️ VM Deployment](#-vm-deployment)
- [📚 API Documentation](#-api-documentation)
- [🧪 Testing](#-testing)
- [🤝 Contributing](#-contributing)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    🌐 TasklistApp (Fully Operational)           │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              🐳 tasklist-api Container                  │    │
│  │  • Spring Boot 3.3.4 (Java 17)                         │    │
│  │  • REST API Endpoints: ✅ Operational                   │    │
│  │  • Database Connection: ✅ Connected                     │    │
│  │  • Swagger Documentation: ✅ Available                  │    │
│  └─────────────────────────────────────────────────────────┘    │
│                    │ Docker Network                        │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              🐳 tasklist-postgres Container             │    │
│  │  • PostgreSQL 16 Database                               │    │
│  │  • Database: tasklistdb ✅ Created                      │    │
│  │  • Persistent Storage: ✅ Configured                    │    │
│  │  • Tables: task ✅ Auto-created                         │    │
│  └─────────────────────────────────────────────────────────┘    │
│                    │ Network Bridge                        │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                 🖥️ VM Deployment                       │    │
│  │  • Spring Boot JAR (172.18.253.249:8080)               │    │
│  │  • Systemd Service: ✅ Running                          │    │
│  │  • Shared Database: ✅ Connected                        │    │
│  │  • Production Ready: ✅ Deployed                        │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│              💻 Access Points                           │
├─────────────────────────────────────────────────────────┤
│  • Docker API: http://localhost:8080/api/tasks          │
│  • VM API: http://172.18.253.249:8080/api/tasks        │
│  • Swagger UI: Available on both deployments           │
│  • Health: Available on both deployments               │
└─────────────────────────────────────────────────────────┘
```

## ✨ Features

### ✅ **Core Functionality (All Operational)**
- **Full CRUD Operations** - Create, Read, Update, Delete tasks
- **RESTful API** - Clean, standardized endpoints (`/api/tasks`)
- **Data Persistence** - PostgreSQL with JPA/Hibernate ORM
- **Containerized** - Multi-container Docker setup
- **VM Deployment** - Production systemd service deployment
- **API Documentation** - Interactive Swagger/OpenAPI 3.0 UI
- **Auto Schema Generation** - Database tables created automatically
- **Environment Configuration** - No hardcoded values, fully configurable

### ✅ **Production Ready Features**
- **Health Monitoring** - Spring Boot Actuator endpoints
- **Persistent Database** - Docker volumes for data persistence
- **Environment Variables** - Secure configuration management
- **Logging** - Comprehensive logging with configurable levels
- **Error Handling** - Proper HTTP status codes and error responses
- **Hot Reload** - Development-friendly configuration
- **Multi-Environment** - Docker + VM deployment options
- **Data Consistency** - Shared database across deployments

## 🚀 Current Status

### **🎯 Application is LIVE and Fully Operational!**

| Component | Status | Details |
|-----------|--------|---------|
| **Spring Boot API (Docker)** | ✅ Running | Port 8080, 16.6s startup time |
| **Spring Boot API (VM)** | ✅ Running | Port 8080, systemd service |
| **PostgreSQL Database** | ✅ Connected | tasklistdb, task table created |
| **Docker Containers** | ✅ Active | tasklist-postgres, tasklist-api |
| **VM Deployment** | ✅ Deployed | Systemd service operational |
| **API Endpoints** | ✅ Ready | All CRUD operations functional |
| **Swagger UI** | ✅ Available | Interactive API documentation |
| **Database Persistence** | ✅ Configured | Docker volumes + shared access |
| **Cross-Deployment Data** | ✅ Verified | Both APIs access same database |

### **📊 Live Metrics**
- **Startup Time**: 16.6 seconds (Docker), ~3 seconds (VM)
- **Database Connections**: Active and healthy (shared)
- **Memory Usage**: Optimized multi-stage build + systemd limits
- **Network**: Inter-container + cross-environment communication
- **Data Consistency**: ✅ Verified between Docker and VM deployments

## 📁 Project Structure

```
TasklistApp/                     # 🚀 Main Project Directory
├── 📄 README.md                # 📖 This file - Complete documentation
├── 📄 docker-compose.yml       # 🐳 Multi-container orchestration
├── 📄 .env                     # 🔐 Environment configuration (git-ignored)
├── 📁 app/                     # 💻 Spring Boot Application
│   ├── 📄 README.md           # 📱 App development guide
│   ├── 📄 Dockerfile          # 🐳 Multi-stage build configuration
│   ├── 📄 pom.xml             # 📦 Maven dependencies & build
│   └── 📁 src/                # 💻 Source code
│       └── 📁 main/
│           ├── 📁 java/com/tasklist/
│           │   ├── 📄 TasklistApplication.java
│           │   ├── 📁 controller/     # 🌐 REST Controllers
│           │   ├── 📁 model/          # 💾 JPA Entities
│           │   ├── 📁 repository/     # 🗄️ Data Repositories
│           │   └── 📁 config/         # ⚙️ Configuration
│           └── 📁 resources/
│               ├── 📄 application.properties  # ⚙️ App configuration
│               └── 📄 logback-spring.xml      # 📝 Logging config
├── 📁 database/               # 🗄️ Database Layer
│   └── 📄 README.md          # 💾 Database management guide
└── 📁 vm/                    # 🖥️ VM Deployment (Complete)
    ├── 📄 README.md          # 🖥️ VM deployment guide
    ├── 📄 deploy.sh          # 🚀 Automated deployment script
    ├── 📄 setup.sh           # 🔧 Initial setup script
    ├── 📁 service/           # ⚙️ Systemd service files
    │   └── 📄 tasklist.service
    └── 📁 scripts/          # 🔧 Utility scripts
        └── 📄 update.sh      # 🔄 Application update script
```

## 🚀 Setup and Run

### **Prerequisites**
- **Docker** and **Docker Compose** installed
- **Git** for cloning the repository

### **Quick Start (One Command)**
```bash
# 1. Clone the repository
git clone <repository-url>
cd TasklistApp

# 2. Start entire application (database + API)
docker-compose up --build

# 3. Or run in background for development
docker-compose up -d --build
```

### **Access Your Live Application**
- **🖥️ Docker API**: http://localhost:8080/api/tasks
- **🖥️ VM API**: http://172.18.253.249:8080/api/tasks
- **📚 Swagger UI**: Available on both deployments
- **🔍 API Docs**: Available on both deployments
- **❤️ Health Check**: Available on both deployments

### **Default Application URLs**
```bash
# API Endpoints (Both Deployments)
GET  http://localhost:8080/api/tasks          # Docker API - Get all tasks
GET  http://172.18.253.249:8080/api/tasks     # VM API - Get all tasks
POST http://localhost:8080/api/tasks          # Create new task
GET  http://localhost:8080/api/tasks/{id}     # Get task by ID
PUT  http://localhost:8080/api/tasks/{id}     # Update task
DELETE http://localhost:8080/api/tasks/{id}  # Delete task

# Documentation & Monitoring (Both Deployments)
Swagger UI: http://localhost:8080/swagger-ui.html
API Docs:   http://localhost:8080/api-docs
Health:     http://localhost:8080/actuator/health
```

### **PostgreSQL Access**
```bash
# Connect to database directly
docker exec -it tasklist-postgres psql -U postgres -d tasklistdb

# Check tables
\dt

# View data
SELECT * FROM task;
```

## ✅ Persistence Verification

### **Verify Data Consistency Between API and Database**
```bash
# From database
docker exec -it tasklist-postgres psql -U postgres -d tasklistdb -c "SELECT id, title, completed FROM task ORDER BY id;"

# From Docker API
curl -s http://localhost:8080/api/tasks | jq '.[] | {id, title, completed}'

# From VM API
curl -s http://172.18.253.249:8080/api/tasks | jq '.[] | {id, title, completed}'
```

**Expected Result:** All three sources should return identical data, confirming persistence and cross-deployment consistency work correctly.

## 🖥️ VM Deployment

### **🚀 Deploy Updated Builds to VM**
```bash
# 1. Copy new JAR to VM
scp -i path/to/your-key target/tasklist-api-0.0.1-SNAPSHOT.jar tasklist@172.18.253.249:/tmp/

# 2. Deploy and restart service
ssh -i path/to/your-key tasklist@172.18.253.249 "sudo mv /tmp/tasklist-api-0.0.1-SNAPSHOT.jar /opt/tasklist/app/tasklist-api.jar && sudo systemctl restart tasklist"

# 3. Verify deployment
curl http://172.18.253.249:8080/api/tasks
```

### **VM Application Details**
- **VM IP Address**: 172.18.253.249
- **VM API URL**: http://172.18.253.249:8080/api/tasks
- **VM Swagger**: http://172.18.253.249:8080/swagger-ui.html
- **Database**: Same PostgreSQL container (shared with Docker deployment)
- **Service**: Runs as systemd service for production stability
- **Status**: ✅ **FULLY OPERATIONAL**

## 📚 API Documentation

### **Base URL (Both Deployments)**
```
http://localhost:8080/api  (Docker)
http://172.18.253.249:8080/api  (VM)
```

### **Available Endpoints**

| Method | Endpoint | Description | Status |
|--------|----------|-------------|---------|
| **GET** | `/tasks` | Get all tasks | ✅ Live |
| **GET** | `/tasks/{id}` | Get task by ID | ✅ Live |
| **POST** | `/tasks` | Create new task | ✅ Live |
| **PUT** | `/tasks/{id}` | Update existing task | ✅ Live |
| **DELETE** | `/tasks/{id}` | Delete task | ✅ Live |

### **Task Data Structure**
```json
{
  "id": "long",
  "title": "string",
  "description": "string",
  "completed": "boolean",
  "dueDate": "date (YYYY-MM-DD)"
}
```

### **Interactive Testing**
Visit **http://localhost:8080/swagger-ui.html** or **http://172.18.253.249:8080/swagger-ui.html** for:
- 📋 Complete API documentation
- 🧪 Interactive request testing
- 📝 Request/response examples
- 🔍 Schema definitions

## 🧪 Testing

### **Manual API Testing**
```bash
# Health check (Both deployments)
curl http://localhost:8080/actuator/health
curl http://172.18.253.249:8080/actuator/health

# Get all tasks (Both deployments)
curl http://localhost:8080/api/tasks
curl http://172.18.253.249:8080/api/tasks

# Create task (Both deployments)
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Task","description":"Testing the API","completed":false}'

# Update task (Both deployments)
curl -X PUT http://localhost:8080/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"completed":true}'
```

### **Database Verification**
```bash
# Connect to database
docker exec -it tasklist-postgres psql -U postgres -d tasklistdb

# List tables
\dt

# View tasks
SELECT * FROM task;

# Count records
SELECT COUNT(*) FROM task;
```

### **Cross-Deployment Testing**
```bash
# Create task via Docker API
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Cross-deployment test","completed":false}'

# Verify same data appears in VM API
curl http://172.18.253.249:8080/api/tasks | jq '.[] | select(.title == "Cross-deployment test")'

# Verify in database
docker exec -it tasklist-postgres psql -U postgres -d tasklistdb -c "SELECT * FROM task WHERE title = 'Cross-deployment test';"
```

### **Browser Testing**
1. **Docker Swagger UI**: http://localhost:8080/swagger-ui.html
2. **VM Swagger UI**: http://172.18.253.249:8080/swagger-ui.html
3. **Docker API**: http://localhost:8080/api/tasks
4. **VM API**: http://172.18.253.249:8080/api/tasks

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes with environment variables in mind
4. Test with `docker-compose up --build`
5. Test VM deployment: `./vm/deploy.sh`
6. Commit your changes: `git commit -m 'Add amazing feature'`
7. Push to the branch: `git push origin feature/amazing-feature`
8. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Spring Boot** - The framework that powers this API
- **PostgreSQL** - Robust and reliable database
- **Docker** - Containerization made easy
- **OpenAPI/Swagger** - API documentation

---

**🎉 Status: FULLY OPERATIONAL** - Your TasklistApp is live on both Docker and VM with shared database! 🚀