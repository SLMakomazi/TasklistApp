# 📱 Spring Boot API - TasklistApp

**✅ OPERATIONAL** - This directory contains the **Spring Boot REST API** component of the TasklistApp. It provides a complete backend solution with CRUD operations for task management, built with modern Spring Boot 3.3.4 features and environment-based configuration.

![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.3.4-brightgreen)
![Java](https://img.shields.io/badge/Java-17-orange)
![Maven](https://img.shields.io/badge/Maven-3.8-blue)
![Docker](https://img.shields.io/badge/Docker-Ready-blue)
![VM](https://img.shields.io/badge/VM-Deployed-green)
![Status](https://img.shields.io/badge/Status-Operational-success)

## 📋 Table of Contents

- [🏗️ Application Overview](#-application-overview)
- [🚀 Current Status](#-current-status)
- [📁 Project Structure](#-project-structure)
- [🔧 Development Setup](#-development-setup)
- [🐳 Docker Development](#-docker-development)
- [📚 API Endpoints](#-api-endpoints)
- [🔍 Testing & Debugging](#-testing--debugging)

## 🏗️ Application Overview

### Technology Stack
- **Framework**: Spring Boot 3.3.4 (Operational)
- **Language**: Java 17
- **Build Tool**: Maven 3.8+
- **Database**: PostgreSQL 16 with JPA/Hibernate ORM
- **Documentation**: OpenAPI 3.0 / Swagger UI
- **Containerization**: Multi-stage Docker builds
- **Deployment**: Docker containers + VM systemd service
- **Configuration**: Environment variables (no hardcoded values)

### Core Features (All Operational)
- ✅ **RESTful API** - Full CRUD operations (`/api/tasks`)
- ✅ **JPA Integration** - Automatic database schema generation
- ✅ **Environment Configuration** - Fully configurable via `.env` file
- ✅ **API Documentation** - Interactive Swagger UI at `/swagger-ui.html`
- ✅ **Health Monitoring** - Spring Boot Actuator endpoints
- ✅ **Logging** - Configurable logging levels
- ✅ **Error Handling** - Proper HTTP status codes and responses

## 🚀 Current Status

### **🎯 Application is LIVE and Operational!**

| Component | Status | Details |
|-----------|--------|---------|
| **Spring Boot Application (Docker)** | ✅ Running | Version 3.3.4, Port 8080 |
| **Spring Boot Application (VM)** | ✅ Running | Systemd service, Port 8080 |
| **Database Connection** | ✅ Connected | PostgreSQL 16, HikariCP pool |
| **API Endpoints** | ✅ Active | All CRUD operations functional |
| **Swagger Documentation** | ✅ Available | Interactive at both deployments |
| **Health Monitoring** | ✅ Enabled | Actuator endpoints available |
| **Environment Config** | ✅ Working | All variables loaded from `.env` |
| **Cross-Deployment** | ✅ Verified | Both APIs access same database |

### **📊 Performance Metrics**
- **Startup Time**: 16.6 seconds (Docker), ~3 seconds (VM)
- **Memory Usage**: Optimized multi-stage Docker build + systemd limits
- **Database Pool**: HikariCP with PostgreSQL
- **Response Time**: Sub-second API responses

### **🌐 Access Points (All Active)**
- **Docker API**: http://localhost:8080/api/tasks
- **VM API**: http://172.18.253.249:8080/api/tasks
- **Docker Swagger**: http://localhost:8080/swagger-ui.html
- **VM Swagger**: http://172.18.253.249:8080/swagger-ui.html
- **Health Check**: http://localhost:8080/actuator/health (both deployments)

## 📁 Project Structure

```
app/                              # 💻 Spring Boot Application
├── 📄 README.md                  # 📖 This file - App documentation
├── 📄 Dockerfile                 # 🐳 Multi-stage build configuration
├── 📄 pom.xml                    # 📦 Maven dependencies & build config
└── 📁 src/                       # 💻 Source Code
    └── 📁 main/
        ├── 📁 java/com/tasklist/
        │   ├── 📄 TasklistApplication.java     # 🚀 Main application class
        │   ├── 📁 controller/                  # 🌐 REST Controllers
        │   │   └── 📄 TaskController.java      # 📋 Task management endpoints
        │   ├── 📁 model/                       # 💾 JPA Entities
        │   │   └── 📄 Task.java               # 📋 Task entity model
        │   ├── 📁 repository/                  # 🗄️ Data Repositories
        │   │   └── 📄 TaskRepository.java     # 💾 Task data access
        │   └── 📁 config/                      # ⚙️ Configuration
        │       └── 📄 OpenApiConfig.java      # 🔧 OpenAPI configuration
        └── 📁 resources/
            ├── 📄 application.properties       # ⚙️ App configuration (env vars)
            └── 📄 logback-spring.xml           # 📝 Logging configuration
```

## 🔧 Development Setup

### **Environment Variables (Required)**
The application uses **strict environment configuration** (no fallback values). Create/update `.env` file in project root:

```env
# Database Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=admin
POSTGRES_DB=tasklistdb
POSTGRES_PORT=5432

# Application Database Connection
DB_URL=jdbc:postgresql://tasklist-postgres:5432/tasklistdb
DB_USERNAME=postgres
DB_PASSWORD=admin

# Application Configuration
API_PORT=8080
SERVER_PORT=8080

# JPA Configuration
JPA_DDL_AUTO=update
JPA_SHOW_SQL=true

# Logging Configuration
LOG_LEVEL_SPRING=INFO
LOG_LEVEL_TASKLIST=DEBUG
LOG_FILE=logs/tasklist.log
```

### **Start Application**

#### **Option 1: Docker (Recommended - Currently Running)**
```bash
# From project root
export $(cat .env | xargs) && docker-compose up --build

# Or with env file
docker-compose --env-file .env up --build
```

#### **Option 2: Local Development**
```bash
# Set environment variables
export $(cat ../.env | xargs)

# Run with Maven
mvn spring-boot:run

# Or with specific port
mvn spring-boot:run -Dserver.port=8081
```

### **Verify Setup**
```bash
# Check application health
curl http://localhost:8080/actuator/health

# Check database connection
docker exec tasklist-postgres psql -U postgres -d tasklistdb -c "\dt"
```

## 🐳 Docker Development

### **Multi-Stage Build Features**
- **Builder Stage**: Maven build with dependencies
- **Runtime Stage**: Optimized Java 17 JRE
- **Final Image**: ~150MB optimized size
- **Port Exposure**: 8080 for external access

### **Container Management**
```bash
# Build application image
docker build -t tasklist-api .

# View running containers
docker ps | grep tasklist

# Check logs
docker-compose logs -f tasklist-api

# Restart application
docker-compose restart tasklist-api
```

## 📚 API Endpoints

### **Base URL**
```
http://localhost:8080/api
```

### **Available Endpoints (All Operational)**

| Method | Endpoint | Description | Status |
|--------|----------|-------------|---------|
| **GET** | `/tasks` | Get all tasks | ✅ Live |
| **GET** | `/tasks/{id}` | Get task by ID | ✅ Live |
| **POST** | `/tasks` | Create new task | ✅ Live |
| **PUT** | `/tasks/{id}` | Update existing task | ✅ Live |
| **DELETE** | `/tasks/{id}` | Delete task | ✅ Live |

### **Request/Response Examples**

#### **Create Task**
```bash
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Update documentation",
    "description": "Update all README files with current status",
    "completed": false,
    "dueDate": "2024-12-31"
  }'
```

#### **Get All Tasks**
```bash
curl http://localhost:8080/api/tasks
```

#### **Update Task**
```bash
curl -X PUT http://localhost:8080/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Update documentation",
    "description": "Update all README files with current status",
    "completed": true,
    "dueDate": "2024-12-31"
  }'
```

### **Interactive Testing**
Visit **http://localhost:8080/swagger-ui.html** for:
- 📋 Complete API documentation
- 🧪 Interactive request testing
- 📝 Request/response examples
- 🔍 Schema validation

## 🔍 Testing & Debugging

### **Application Health**
```bash
# Health check endpoint
curl http://localhost:8080/actuator/health

# Application info
curl http://localhost:8080/actuator/info

# Metrics
curl http://localhost:8080/actuator/metrics
```

### **Database Testing**
```bash
# Connect to database
docker exec -it tasklist-postgres psql -U postgres -d tasklistdb

# List tables
\dt

# View table structure
\d task

# Query tasks
SELECT * FROM task;

# Count records
SELECT COUNT(*) FROM task;
```

### **Debug Mode**
```bash
# Run with debug logging
mvn spring-boot:run -Dlogging.level.com.tasklist=DEBUG

# Remote debugging (port 5005)
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005"
```

### **Common Issues & Solutions**

#### **Environment Variables Not Loading**
```bash
# Check .env file exists and has correct format
cat .env

# Test variable loading
export $(cat .env | xargs) && echo $DB_URL

# Use explicit env file
docker-compose --env-file .env up
```

#### **Database Connection Issues**
```bash
# Check PostgreSQL container
docker ps | grep postgres

# Test database connectivity
docker exec tasklist-postgres pg_isready -U postgres -d tasklistdb

# View database logs
docker logs tasklist-postgres
```

#### **Port Already in Use**
```bash
# Find process using port 8080
netstat -tulpn | grep :8080

# Use different port
SERVER_PORT=8081 docker-compose up
```

## 📊 Application Configuration

### **Database Configuration (Environment-Based)**
```properties
# application.properties
spring.datasource.url=${DB_URL}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}
spring.jpa.hibernate.ddl-auto=${JPA_DDL_AUTO}
spring.jpa.show-sql=${JPA_SHOW_SQL}
```

### **Server Configuration**
```properties
server.port=${SERVER_PORT}
management.endpoints.web.exposure.include=health,info,metrics
```

### **Logging Configuration**
```properties
logging.level.org.springframework=${LOG_LEVEL_SPRING}
logging.level.com.tasklist=${LOG_LEVEL_TASKLIST}
logging.file.name=${LOG_FILE}
```

## 🚀 Development Workflow

### **1. Make Code Changes**
Edit files in `src/main/java/com/tasklist/`

### **2. Test Changes**
```bash
# Run tests
mvn test

# Manual testing via Swagger UI
open http://localhost:8080/swagger-ui.html

# API testing
curl http://localhost:8080/api/tasks
```

### **3. Build & Deploy**
```bash
# Build application
mvn clean package

# Build Docker image
docker build -t tasklist-api .

# Deploy with Docker Compose
docker-compose up -d --build
```

## 🔧 Useful Commands

### **Maven Commands**
```bash
mvn clean compile      # Clean and compile
mvn test              # Run tests
mvn package           # Package application
mvn spring-boot:run   # Run application
```

### **Docker Commands**
```bash
docker-compose up --build      # Start all services
docker-compose logs -f         # View all logs
docker-compose down           # Stop all services
docker-compose restart        # Restart all services
```

### **Database Commands**
```bash
docker exec -it tasklist-postgres psql -U postgres -d tasklistdb
\dt                           # List tables
\d task                      # Describe task table
SELECT * FROM task;          # View all tasks
```

## 📈 Performance & Monitoring

### **Health Check Endpoints**
- **Health**: http://localhost:8080/actuator/health
- **Info**: http://localhost:8080/actuator/info
- **Metrics**: http://localhost:8080/actuator/metrics

### **Application Metrics**
```bash
# JVM memory usage
curl http://localhost:8080/actuator/metrics/jvm.memory.used

# HTTP request metrics
curl http://localhost:8080/actuator/metrics/http.server.requests

# Database connection pool
curl http://localhost:8080/actuator/metrics/hikaricp.connections
```

## 🤝 Contributing

1. Follow existing code structure in `src/main/java/com/tasklist/`
2. Write tests for new features
3. Update API documentation if adding endpoints
4. Follow Spring Boot best practices
5. Test with both Docker and local development
6. Ensure environment variables are properly configured

## 📄 Related Documentation

- **Main Project**: [../README.md](../README.md) - Complete project overview
- **Database Setup**: [../database/README.md](../database/README.md) - Database management
- **VM Deployment**: [../vm/README.md](../vm/README.md) - VM deployment guide

---

**🎉 Status: FULLY OPERATIONAL** - Your Spring Boot API is live and production-ready! 🚀