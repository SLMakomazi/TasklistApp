# 🚀 TasklistApp - Task Management API

**✅ FULLY OPERATIONAL** - A modern, containerized task management application built with **Spring Boot 3.3.4**, **PostgreSQL 16**, and **Docker**. This production-ready application provides RESTful API endpoints for managing tasks with complete CRUD operations, data persistence, and comprehensive API documentation.

![Java](https://img.shields.io/badge/Java-17-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.3.4-brightgreen)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue)
![Docker](https://img.shields.io/badge/Docker-Ready-blue)
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
│                    🌐 TasklistApp (Operational)                 │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              🐳 tasklist-api Container                  │    │
│  │  • Spring Boot 3.3.4 (Java 17)                         │    │
│  │  • REST API Endpoints: ✅ Operational                   │    │
│  │  • Database Connection: ✅ Connected                     │    │
│  │  • Swagger Documentation: ✅ Available                  │    │
│  └─────────────────────────────────────────────────────────┘    │
│                          │ Docker Network                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              🐳 tasklist-postgres Container             │    │
│  │  • PostgreSQL 16 Database                               │    │
│  │  • Database: tasklistdb ✅ Created                      │    │
│  │  • Persistent Storage: ✅ Configured                    │    │
│  │  • Tables: task ✅ Auto-created                         │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│              💻 Access Points                           │
├─────────────────────────────────────────────────────────┤
│  • API: http://localhost:8080/api/tasks                 │
│  • Swagger UI: http://localhost:8080/swagger-ui.html    │
│  • Health: http://localhost:8080/actuator/health        │
└─────────────────────────────────────────────────────────┘
```

## ✨ Features

### ✅ **Core Functionality (All Operational)**
- **Full CRUD Operations** - Create, Read, Update, Delete tasks
- **RESTful API** - Clean, standardized endpoints (`/api/tasks`)
- **Data Persistence** - PostgreSQL with JPA/Hibernate ORM
- **Containerized** - Multi-container Docker setup
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

## 🚀 Current Status

### **🎯 Application is LIVE and Operational!**

| Component | Status | Details |
|-----------|--------|---------|
| **Spring Boot API** | ✅ Running | Port 8080, 16.6s startup time |
| **PostgreSQL Database** | ✅ Connected | tasklistdb, task table created |
| **Docker Containers** | ✅ Active | tasklist-postgres, tasklist-api |
| **API Endpoints** | ✅ Ready | All CRUD operations functional |
| **Swagger UI** | ✅ Available | Interactive API documentation |
| **Database Persistence** | ✅ Configured | Docker volumes enabled |

### **📊 Live Metrics**
- **Startup Time**: 16.6 seconds
- **Database Connections**: Active and healthy
- **Memory Usage**: Optimized multi-stage build
- **Network**: Inter-container communication working

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
└── 📁 vm/                    # 🖥️ VM Deployment
    └── 📄 README.md          # 🖥️ VM deployment guide
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
- **🖥️ API Base**: http://localhost:8080/api/tasks
- **📚 Swagger UI**: http://localhost:8080/swagger-ui.html
- **🔍 API Docs**: http://localhost:8080/api-docs
- **❤️ Health Check**: http://localhost:8080/actuator/health

### **Default Application URLs**
```bash
# API Endpoints
GET  http://localhost:8080/api/tasks          # Get all tasks
POST http://localhost:8080/api/tasks          # Create new task
GET  http://localhost:8080/api/tasks/{id}     # Get task by ID
PUT  http://localhost:8080/api/tasks/{id}     # Update task
DELETE http://localhost:8080/api/tasks/{id}  # Delete task

# Documentation & Monitoring
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

# From API
curl -s http://localhost:8080/api/tasks | jq '.[] | {id, title, completed}'
```

**Expected Result:** Both commands should return identical data, confirming persistence works correctly.

## 🖥️ VM Deployment

### **Deploy Updated Builds to VM**
```bash
# 1. Copy new JAR to VM
scp -i path/to/your-key target/tasklist-api-0.0.1-SNAPSHOT.jar tasklist@<VM_IP>:/tmp/

# 2. Deploy and restart service
ssh -i path/to/your-key tasklist@<VM_IP> "sudo mv /tmp/tasklist-api-0.0.1-SNAPSHOT.jar /opt/tasklist/app/tasklist-api.jar && sudo systemctl restart tasklist && sudo journalctl -u tasklist -f --no-pager"
```

### **VM Application Details**
- **VM API URL**: http://192.168.18.3:8080/api/tasks
- **VM Swagger**: http://192.168.18.3:8080/swagger-ui.html
- **Database**: Same PostgreSQL container (shared with Docker deployment)
- **Service**: Runs as systemd service for production stability

## 📚 API Documentation

### **Base URL**
```
http://localhost:8080/api
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
Visit **http://localhost:8080/swagger-ui.html** for:
- 📋 Complete API documentation
- 🧪 Interactive request testing
- 📝 Request/response examples
- 🔍 Schema definitions

## 🧪 Testing

### **Manual API Testing**
```bash
# Health check
curl http://localhost:8080/actuator/health

# Get all tasks
curl http://localhost:8080/api/tasks

# Create task
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Task","description":"Testing the API","completed":false}'

# Update task
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

### **Browser Testing**
1. **Swagger UI**: http://localhost:8080/swagger-ui.html
2. **API Docs**: http://localhost:8080/api-docs
3. **Direct API**: http://localhost:8080/api/tasks

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes with environment variables in mind
4. Test with `docker-compose up --build`
5. Commit your changes: `git commit -m 'Add amazing feature'`
6. Push to the branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Spring Boot** - The framework that powers this API
- **PostgreSQL** - Robust and reliable database
- **Docker** - Containerization made easy
- **OpenAPI/Swagger** - API documentation

---

**🎉 Status: FULLY OPERATIONAL** - Your TasklistApp is live and ready for production use! 🚀