# 🚀 TasklistApp - Task Management API

**✅ FULLY OPERATIONAL** - A modern, production-ready task management application built with **Spring Boot 3.3.4**, **PostgreSQL 16**, and **Docker**. This application provides RESTful API endpoints for managing tasks with complete CRUD operations, data persistence, and comprehensive API documentation. It supports multiple deployment strategies including Docker containers and VM-based systemd services with automated CI/CD pipelines.

![Java](https://img.shields.io/badge/Java-17-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.3.4-brightgreen)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue)
![Docker](https://img.shields.io/badge/Docker-Ready-blue)
![VM](https://img.shields.io/badge/VM-Deployed-green)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-Ready-blue)
![Status](https://img.shields.io/badge/Status-Operational-success)

## 📋 Table of Contents

- [🏗️ Project Overview](#-project-overview)
- [📁 Project Structure](#-project-structure)
- [🚀 CI/CD Pipeline Overview](#-cicd-pipeline-overview)
- [🖥️ Deployment Options](#-deployment-options)
- [🚀 Setup and Run](#-setup-and-run)
- [✅ Persistence Verification](#-persistence-verification)
- [📚 API Documentation](#-api-documentation)
- [🧪 Testing](#-testing)
- [🤝 Contributing](#-contributing)

## 🏗️ Project Overview

**TasklistApp** is a comprehensive task management system that combines a Spring Boot REST API with PostgreSQL database persistence. The application supports multiple deployment environments and includes automated CI/CD pipelines for seamless development and production workflows.

### Key Technologies
- **Backend Framework**: Spring Boot 3.3.4 with Java 17
- **Database**: PostgreSQL 16 with JPA/Hibernate ORM
- **Containerization**: Multi-stage Docker builds
- **Deployment**: Docker containers + VM systemd services
- **CI/CD**: GitHub Actions with automated build, test, and deployment
- **Documentation**: OpenAPI 3.0 / Swagger UI

### Core Features
- ✅ **Complete CRUD Operations** - Create, Read, Update, Delete tasks via REST API
- ✅ **Data Persistence** - PostgreSQL with automatic schema generation
- ✅ **Multi-Environment Deployment** - Docker containers and VM services
- ✅ **Automated CI/CD** - Build, test, and deployment automation
- ✅ **Comprehensive Logging** - Configurable logging with file rotation
- ✅ **Health Monitoring** - Spring Boot Actuator endpoints
- ✅ **API Documentation** - Interactive Swagger/OpenAPI documentation
- ✅ **Environment Configuration** - Fully configurable via environment variables

## 📁 Project Structure

```
TasklistApp/                     # 🚀 Main Project Directory
├── 📄 README.md                # 📖 This file - Complete project documentation
├── 📄 docker-compose.yml       # 🐳 Multi-container orchestration
├── 📄 .env                     # 🔐 Environment configuration (git-ignored)
├── 📁 app/                     # 💻 Spring Boot Application
│   ├── 📄 README.md           # 📱 App development and build guide
│   ├── 📄 Dockerfile          # 🐳 Multi-stage build configuration
│   ├── 📄 pom.xml             # 📦 Maven dependencies and build configuration
│   └── 📁 src/                # 💻 Source code
│       └── 📁 main/
│           ├── 📁 java/com/tasklist/
│           │   ├── 📄 TasklistApplication.java  # 🚀 Main application class
│           │   ├── 📁 controller/     # 🌐 REST Controllers (Task management endpoints)
│           │   ├── 📁 model/          # 💾 JPA Entities (Task entity model)
│           │   ├── 📁 repository/     # 🗄️ Data Repositories (Task data access)
│           │   └── 📁 config/         # ⚙️ Configuration (OpenAPI setup)
│           └── 📁 resources/
│               ├── 📄 application.properties  # ⚙️ App configuration (environment variables)
│               └── 📄 logback-spring.xml      # 📝 Logging configuration
├── 📁 database/               # 🗄️ Database Layer
│   └── 📄 README.md          # 💾 Database management and setup guide
├── 📁 vm/                    # 🖥️ VM Deployment
│   ├── 📄 README.md          # 🖥️ VM deployment and systemd service guide
│   ├── 📄 deploy.sh          # 🚀 Automated VM deployment script
│   ├── 📄 setup.sh           # 🔧 Initial VM setup script
│   ├── 📁 service/           # ⚙️ Systemd service files
│   │   └── 📄 tasklist.service
│   └── 📁 scripts/          # 🔧 Utility scripts
│       └── 📄 update.sh      # 🔄 Application update script
└── 📁 .github/               # 🤖 GitHub Actions CI/CD
    └── 📁 workflows/         # 🔄 Automated workflows
        ├── 📄 docker-build.yml   # 🐳 Docker build, test, and push pipeline
        └── 📄 vm-deploy.yml      # 🖥️ VM deployment pipeline
```

### Directory Explanations

- **`/app`**: Contains the Spring Boot application (`tasklist-api`) with Maven build configuration, source code, and Docker setup
- **`/vm`**: VM deployment scripts, systemd service configuration, and utility scripts for production deployment
- **`/database`**: Database setup instructions and configuration for PostgreSQL container management
- **`/.github/workflows`**: GitHub Actions CI/CD pipelines for automated building, testing, and deployment

## 🚀 CI/CD Pipeline Overview

The project includes two automated GitHub Actions workflows:

### **1. 🔨 Build and Test Pipeline (`docker-build.yml`)**
- **Purpose**: Builds, tests, and pushes Docker images
- **Triggers**: Push to `main`/`develop` branches, Pull Requests
- **Features**:
  - Maven dependency caching for faster builds
  - Unit and integration testing with PostgreSQL service
  - Multi-stage Docker image building
  - Automated push to Docker Hub (`slmakomazi/tasklistapp`)
  - Build artifact caching for performance

### **2. 🚀 VM Deployment Pipeline (`vm-deploy.yml`)**
- **Purpose**: Deploys application to VM via SSH and systemd
- **Triggers**: Push to `main` branch, Manual trigger
- **Features**:
  - Automated JAR building from source
  - SSH deployment to VM with service management
  - Systemd service restart and verification
  - Deployment artifact management
  - Error handling and rollback capabilities

Both pipelines run on GitHub Actions runners and provide comprehensive automation for development and production workflows.

## 🖥️ Deployment Options

The application supports multiple deployment strategies:

### **🐳 Docker Container Deployment**
- **Method**: Multi-container Docker Compose setup
- **Components**: Spring Boot API + PostgreSQL database
- **Access**: `http://localhost:8080/api/tasks`
- **Features**: Development-friendly with hot reload
- **Use Case**: Local development and containerized environments

### **🖥️ VM Service Deployment**
- **Method**: Systemd service on Linux VM
- **Components**: Spring Boot JAR + PostgreSQL (shared container)
- **Access**: `http://vm-ip:8080/api/tasks`
- **Features**: Production-grade service management
- **Use Case**: Production servers and dedicated hosting

### **🔧 Environment Variables**
All deployments use environment-based configuration (no hardcoded values):

```env
# Database Configuration
DB_URL=jdbc:postgresql://host:5432/tasklistdb
DB_USERNAME=postgres
DB_PASSWORD=admin

# Application Configuration
SERVER_PORT=8080

# JPA Configuration
JPA_DDL_AUTO=update
JPA_SHOW_SQL=true

# Logging Configuration
LOG_LEVEL_SPRING=INFO
LOG_LEVEL_TASKLIST=DEBUG
LOG_FILE=/opt/tasklist/logs/tasklist.log
```

### **🔄 Cross-Deployment Consistency**
Both Docker and VM deployments connect to the same PostgreSQL database, ensuring data consistency across environments.

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