# 📱 Spring Boot API - TasklistApp

This directory contains the **Spring Boot REST API** component of the TasklistApp. It provides a complete backend solution with CRUD operations for task management, built with modern Spring Boot 3.x features.

![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.3.4-brightgreen)
![Java](https://img.shields.io/badge/Java-17-orange)
![Maven](https://img.shields.io/badge/Maven-3.8-blue)

## 📋 Table of Contents

- [🏗️ Application Overview](#-application-overview)
- [🚀 Quick Start](#-quick-start)
- [📁 Project Structure](#-project-structure)
- [🔧 Development Setup](#-development-setup)
- [🐳 Docker Development](#-docker-development)
- [📚 API Endpoints](#-api-endpoints)
- [🔍 Testing & Debugging](#-testing--debugging)

## 🏗️ Application Overview

### Technology Stack
- **Framework**: Spring Boot 3.3.4
- **Language**: Java 17
- **Build Tool**: Maven
- **Database**: PostgreSQL with JPA/Hibernate
- **Documentation**: OpenAPI 3.0 / Swagger UI
- **Containerization**: Docker & Multi-stage builds

### Core Features
- ✅ **RESTful API** - Full CRUD operations
- ✅ **JPA Integration** - Automatic database schema generation
- ✅ **Data Validation** - Input validation and error handling
- ✅ **API Documentation** - Interactive Swagger UI
- ✅ **Logging** - Comprehensive logging configuration
- ✅ **Hot Reload** - Development-friendly configuration

## 🚀 Quick Start

### Prerequisites
- **Java 17+**
- **Maven 3.6+**
- **PostgreSQL** (or Docker)

### Run Application
```bash
# Option 1: With Docker (Recommended)
cd ..  # Go to root directory
docker-compose up --build

# Option 2: Local Development
mvn spring-boot:run
```

### Access Points
- **Application**: http://localhost:8080
- **API Base**: http://localhost:8080/api
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **API Docs**: http://localhost:8080/api-docs

## 📁 Project Structure

```
app/
├── 📄 README.md              # This file
├── 📄 Dockerfile             # Multi-stage build configuration
├── 📄 pom.xml                # Maven dependencies & build config
├── 📄 .env                   # Environment variables (optional)
└── 📁 src/
    └── 📁 main/
        ├── 📁 java/
        │   └── 📁 com/tasklist/
        │       ├── 📄 TasklistApplication.java
        │       ├── 📁 controller/     # REST Controllers
        │       ├── 📁 entity/         # JPA Entities
        │       ├── 📁 repository/     # Data Repositories
        │       ├── 📁 service/        # Business Logic
        │       └── 📁 dto/            # Data Transfer Objects
        └── 📁 resources/
            ├── 📄 application.properties  # App configuration
            └── 📄 logback-spring.xml      # Logging config
```

## 🔧 Development Setup

### 1. Database Setup
```bash
# Start PostgreSQL (from root directory)
cd .. && docker-compose up -d tasklist-postgres

# Or start from database folder (legacy)
cd ../database && docker-compose up -d
```

### 2. Run Application
```bash
# Compile and run
mvn clean compile
mvn spring-boot:run

# Or run with custom port
mvn spring-boot:run -Dserver.port=8081
```

### 3. Verify Setup
```bash
# Check if app is running
curl http://localhost:8080/actuator/health

# Check database connection
docker exec tasklist-postgres psql -U postgres -d tasklistdb -c "\dt"
```

## 🐳 Docker Development

### Build Application Image
```bash
# From app directory
docker build -t tasklist-api .

# Or from root directory
docker-compose build tasklist-api
```

### Run with Docker Compose
```bash
# From root directory
docker-compose up -d

# View logs
docker-compose logs -f tasklist-api
```

### Dockerfile Features
- **Multi-stage build** for optimized image size
- **Maven build** inside container
- **Java 17** runtime environment
- **Port 8080** exposed for external access

## 📚 API Endpoints

### Base URL
```
http://localhost:8080/api
```

### Task Management Endpoints

| Method | Endpoint | Description | Request Body |
|--------|----------|-------------|--------------|
| **GET** | `/tasks` | Get all tasks | None |
| **GET** | `/tasks/{id}` | Get task by ID | None |
| **POST** | `/tasks` | Create new task | Task JSON |
| **PUT** | `/tasks/{id}` | Update existing task | Task JSON |
| **DELETE** | `/tasks/{id}` | Delete task | None |

### Request/Response Examples

#### Create Task
```bash
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Learn Docker",
    "description": "Complete Docker tutorial",
    "completed": false,
    "dueDate": "2024-12-31"
  }'
```

#### Get All Tasks
```bash
curl http://localhost:8080/api/tasks
```

#### Update Task
```bash
curl -X PUT http://localhost:8080/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Learn Docker",
    "description": "Complete Docker tutorial",
    "completed": true,
    "dueDate": "2024-12-31"
  }'
```

## 🔍 Testing & Debugging

### Run Tests
```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=TaskControllerTest

# Run with coverage
mvn test jacoco:report
```

### Debug Mode
```bash
# Run with debug logging
mvn spring-boot:run -Dlogging.level.com.tasklist=DEBUG

# Remote debugging
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005"
```

### Common Issues

**Database Connection Issues**
```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Test database connection
docker exec tasklist-postgres psql -U postgres -d tasklistdb -c "SELECT 1;"
```

**Port Already in Use**
```bash
# Find process using port 8080
netstat -tulpn | grep :8080

# Kill process or use different port
mvn spring-boot:run -Dserver.port=8081
```

## 📊 Application Configuration

### Database Configuration
```properties
# application.properties
spring.datasource.url=jdbc:postgresql://localhost:5432/tasklistdb
spring.datasource.username=postgres
spring.datasource.password=admin
spring.jpa.hibernate.ddl-auto=update
```

### Logging Configuration
```properties
# Debug logging for your package
logging.level.com.tasklist=DEBUG
logging.level.org.springframework.web=DEBUG
logging.file.name=logs/tasklist.log
```

## 🚀 Development Workflow

### 1. Make Code Changes
Edit files in `src/main/java/com/tasklist/`

### 2. Test Changes
```bash
# Run tests
mvn test

# Manual testing via Swagger UI
# http://localhost:8080/swagger-ui.html
```

### 3. Build & Deploy
```bash
# Build the application
mvn clean package

# Build Docker image
docker build -t tasklist-api .

# Deploy with Docker Compose
docker-compose up -d
```

## 🔧 Useful Maven Commands

```bash
# Clean and compile
mvn clean compile

# Run tests
mvn test

# Package application
mvn package

# Run application
mvn spring-boot:run

# Skip tests during build
mvn package -DskipTests

# Generate API documentation
mvn compile
```

## 📈 Performance & Monitoring

### Health Check Endpoints
- **Health**: http://localhost:8080/actuator/health
- **Info**: http://localhost:8080/actuator/info
- **Metrics**: http://localhost:8080/actuator/metrics

### Application Metrics
```bash
# View JVM metrics
curl http://localhost:8080/actuator/metrics/jvm.memory.used

# View HTTP metrics
curl http://localhost:8080/actuator/metrics/http.server.requests
```

## 🤝 Contributing

1. Follow the existing code structure
2. Write tests for new features
3. Update API documentation if adding endpoints
4. Follow Spring Boot best practices
5. Test with both Docker and local development

## 📄 Related Documentation

- **Main Project**: [../README.md](../README.md) - Complete project overview
- **Database Setup**: [../database/README.md](../database/README.md) - Database configuration
- **API Reference**: [../docs/API.md](../docs/API.md) - Detailed API documentation

---

**Happy Coding!** 🚀 Built with Spring Boot 3.x and modern Java practices.