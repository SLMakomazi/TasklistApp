# 🚀 TasklistApp - Task Management API

A modern, containerized task management application built with **Spring Boot**, **PostgreSQL**, and **Docker**. This full-stack application provides RESTful API endpoints for managing tasks with features like CRUD operations, data persistence, and API documentation.

![Java](https://img.shields.io/badge/Java-17-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.3.4-brightgreen)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue)
![Docker](https://img.shields.io/badge/Docker-Ready-blue)

## 📋 Table of Contents

- [🏗️ Architecture](#-architecture)
- [✨ Features](#-features)
- [🚀 Quick Start](#-quick-start)
- [📁 Project Structure](#-project-structure)
- [🔧 Development Setup](#-development-setup)
- [🐳 Production Deployment](#-production-deployment)
- [📚 API Documentation](#-api-documentation)
- [🧪 Testing](#-testing)
- [🤝 Contributing](#-contributing)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    TasklistApp                          │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────┐    │
│  │              Spring Boot API                    │    │
│  │  • REST Controllers                             │    │
│  │  • JPA Repositories                             │    │
│  │  • Service Layer                                │    │
│  │  • DTOs & Entities                              │    │
│  └─────────────────────────────────────────────────┘    │
│                    │                                 │
│         Docker Network / Direct Connection           │
│                    │                                 │
│  ┌─────────────────────────────────────────────────┐    │
│  │             PostgreSQL Database                  │    │
│  │  • Task Table (Auto-created)                    │    │
│  │  • Data Persistence                             │    │
│  │  • ACID Compliance                              │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

## ✨ Features

- ✅ **Full CRUD Operations** - Create, Read, Update, Delete tasks
- ✅ **RESTful API** - Clean, standardized endpoints
- ✅ **Data Persistence** - PostgreSQL with JPA/Hibernate
- ✅ **Containerized** - Docker support for easy deployment
- ✅ **API Documentation** - Swagger/OpenAPI integration
- ✅ **Auto Schema Generation** - Database tables created automatically
- ✅ **Development Tools** - Hot reload, logging, error handling
- ✅ **Production Ready** - Multi-stage Docker builds, health checks

## 🚀 Quick Start

### Prerequisites
- **Docker & Docker Compose**
- **Java 17+** (for development)
- **Maven 3.6+** (for development)

### One-Command Setup
```bash
# Clone and start everything
git clone <repository-url>
cd TasklistApp
docker-compose up --build
```

### Access Your Application
- **API**: http://localhost:8080/api/tasks
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **Database**: localhost:5432 (from host)

## 📁 Project Structure

```
TasklistApp/
├── 📄 README.md                 # This file - Project overview
├── 📄 docker-compose.yml        # Main container orchestration
├── 📁 app/                      # Spring Boot application
│   ├── 📄 README.md            # App development guide
│   ├── 📄 Dockerfile           # Multi-stage build
│   ├── 📄 pom.xml              # Maven dependencies
│   └── 📁 src/                 # Source code
├── 📁 database/                # Database configuration
│   ├── 📄 README.md           # Database setup guide
│   └── 📄 docker-compose.yml   # Legacy DB setup (deprecated)
└── 📁 docs/                   # Documentation
    └── 📄 API.md              # API reference
```

## 🔧 Development Setup

### Local Development (Without Docker)
```bash
# Start PostgreSQL
cd database
docker-compose up -d

# Run Spring Boot app
cd ../app
mvn spring-boot:run
```

### Docker Development
```bash
# Build and run all services
docker-compose up --build

# Run in background
docker-compose up -d --build

# View logs
docker-compose logs -f tasklist-api
```

### Stop Development Environment
```bash
docker-compose down
```

## 🐳 Production Deployment

### Build Production Images
```bash
# Build optimized images
docker-compose -f docker-compose.yml build

# Or build individually
docker build -t tasklist-api ./app
```

### Environment Variables
Create `.env` file in root directory:
```env
DB_HOST=tasklist-postgres
DB_PORT=5432
DB_NAME=tasklistdb
DB_USERNAME=postgres
DB_PASSWORD=your-secure-password
API_PORT=8080
```

### Deploy to Production
```bash
# Start production containers
docker-compose up -d

# Scale API service (if needed)
docker-compose up -d --scale tasklist-api=3
```

## 📚 API Documentation

### Base URL
```
http://localhost:8080/api
```

### Core Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/tasks` | Get all tasks |
| GET | `/tasks/{id}` | Get task by ID |
| POST | `/tasks` | Create new task |
| PUT | `/tasks/{id}` | Update existing task |
| DELETE | `/tasks/{id}` | Delete task |

### Task Data Structure
```json
{
  "id": "long",
  "title": "string",
  "description": "string",
  "completed": "boolean",
  "dueDate": "date (YYYY-MM-DD)"
}
```

### Example Requests

#### Create Task
```bash
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Complete project",
    "description": "Finish the TasklistApp",
    "completed": false,
    "dueDate": "2024-12-31"
  }'
```

#### Get All Tasks
```bash
curl http://localhost:8080/api/tasks
```

## 🧪 Testing

### Run Tests
```bash
cd app
mvn test
```

### Manual Testing
1. Start the application
2. Use Swagger UI at http://localhost:8080/swagger-ui.html
3. Or use curl/Postman with the endpoints above

## 🔍 Monitoring & Logs

### View Application Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f tasklist-api
docker-compose logs -f tasklist-postgres
```

### Database Inspection
```bash
# Connect to database
docker exec -it tasklist-postgres psql -U postgres -d tasklistdb

# List tables
\dt

# View table structure
\d task
```

## 🛠️ Troubleshooting

### Common Issues

**Database Connection Failed**
```bash
# Check if database is running
docker ps | grep postgres

# Restart database
docker-compose restart tasklist-postgres
```

**Application Won't Start**
```bash
# Check logs
docker-compose logs tasklist-api

# Rebuild application
docker-compose build --no-cache tasklist-api
```

**Port Already in Use**
```bash
# Stop other services using port 8080
sudo lsof -ti:8080 | xargs kill -9

# Or change port in docker-compose.yml
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Spring Boot** - The framework that powers this API
- **PostgreSQL** - Robust and reliable database
- **Docker** - Containerization made easy
- **OpenAPI/Swagger** - API documentation

---

**🎉 Happy Coding!** Built with ❤️ using Spring Boot, PostgreSQL, and Docker.