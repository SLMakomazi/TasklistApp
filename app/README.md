# Spring Boot API - TasklistApp

This directory contains the Spring Boot REST API component of the TasklistApp. It provides a complete backend solution with CRUD operations for task management, built with Spring Boot 3.3.4 and environment-based configuration.

## Table of Contents

- [Application Overview](#application-overview)
- [Project Structure](#project-structure)
- [Development Setup](#development-setup)
- [Build and Run](#build-and-run)
- [Environment Variables](#environment-variables)
- [API Endpoints](#api-endpoints)
- [Testing](#testing)
- [Deployment](#deployment)

## Application Overview

### Technology Stack
- **Framework**: Spring Boot 3.3.4
- **Language**: Java 17
- **Build Tool**: Maven 3.8+
- **Database**: PostgreSQL 16 with JPA/Hibernate ORM
- **Documentation**: OpenAPI 3.0 / Swagger UI
- **Configuration**: Environment variables (no hardcoded values)

### Core Features
- **RESTful API** - Full CRUD operations (`/api/tasks`)
- **JPA Integration** - Automatic database schema generation
- **Environment Configuration** - Fully configurable via environment variables
- **API Documentation** - Interactive Swagger UI at `/swagger-ui.html`
- **Health Monitoring** - Spring Boot Actuator endpoints
- **Logging** - Configurable logging levels

## Project Structure

```
app/                              # Spring Boot Application
├── README.md                  # This file - App documentation
├── Dockerfile                 # Multi-stage build configuration
├── pom.xml                    # Maven dependencies & build config
└── src/                       # Source Code
    └── main/
        ├── java/com/tasklist/
        │   ├── TasklistApplication.java     # Main application class
        │   ├── controller/                  # REST Controllers
        │   │   └── TaskController.java      # Task management endpoints
        │   ├── model/                       # JPA Entities
        │   │   └── Task.java               # Task entity model
        │   ├── repository/                  # Data Repositories
        │   │   └── TaskRepository.java     # Task data access
        │   └── config/                      # Configuration
        │       └── OpenApiConfig.java      # OpenAPI configuration
        └── resources/
            ├── application.properties       # App configuration (env vars)
            └── logback-spring.xml           # Logging configuration
```

## Development Setup

### Prerequisites
- **Java 17** installed and configured
- **Maven 3.8+** installed
- **Git** for cloning the repository

## Build and Run

### Maven Commands

#### Build the Application
```bash
# Clean and compile
mvn clean compile

# Run tests
mvn test

# Package application (creates JAR file)
mvn clean package

# Package without running tests (faster builds)
mvn clean package -DskipTests

# Run application in development mode
mvn spring-boot:run

# Run with custom port
mvn spring-boot:run -Dserver.port=8081
```

#### Common Maven Operations
```bash
# Validate project structure
mvn validate

# Download dependencies only
mvn dependency:resolve

# Clean build artifacts
mvn clean

# Generate project documentation
mvn site

# Install to local repository
mvn install
```

### Local Development

#### Option 1: Using Maven directly
```bash
# Set environment variables (from project root .env file)
export $(cat ../.env | xargs)

# Run the application
mvn spring-boot:run

# Access the application
curl http://localhost:8080/api/tasks
```

#### Option 2: Using IDE
1. Import the project as a Maven project in your IDE (IntelliJ IDEA, Eclipse, VS Code)
2. Set up environment variables in your run configuration
3. Run the `TasklistApplication.java` main class

### Verify Setup
```bash
# Check application health
curl http://localhost:8080/actuator/health

# Check if application is responding
curl http://localhost:8080/api/tasks

# View application logs (if file logging is configured)
tail -f logs/tasklist.log
```

## Environment Variables

The application uses **strict environment configuration** (no fallback values). All variables must be provided via environment variables or `.env` file.

### Required Environment Variables

```env
# Database Configuration
DB_URL=jdbc:postgresql://localhost:5432/tasklistdb
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
LOG_FILE=logs/tasklist.log

# Optional: Application Info
APP_NAME=TasklistApp
APP_VERSION=1.0.0
```

### Environment Variable Mapping

| Environment Variable | Application Property | Description |
|---------------------|---------------------|-------------|
| `DB_URL` | `spring.datasource.url` | Database connection URL |
| `DB_USERNAME` | `spring.datasource.username` | Database username |
| `DB_PASSWORD` | `spring.datasource.password` | Database password |
| `SERVER_PORT` | `server.port` | Application server port |
| `JPA_DDL_AUTO` | `spring.jpa.hibernate.ddl-auto` | JPA schema auto-update |
| `JPA_SHOW_SQL` | `spring.jpa.show-sql` | Show SQL queries in logs |
| `LOG_LEVEL_SPRING` | `logging.level.org.springframework` | Spring framework log level |
| `LOG_LEVEL_TASKLIST` | `logging.level.com.tasklist` | Application log level |
| `LOG_FILE` | `logging.file.name` | Log file location |

### Setting Environment Variables

#### Using .env file (recommended for development)
```bash
# Create .env file in project root
cat > ../.env << EOF
DB_URL=jdbc:postgresql://localhost:5432/tasklistdb
DB_USERNAME=postgres
DB_PASSWORD=admin
SERVER_PORT=8080
JPA_DDL_AUTO=update
JPA_SHOW_SQL=true
LOG_LEVEL_SPRING=INFO
LOG_LEVEL_TASKLIST=DEBUG
LOG_FILE=logs/tasklist.log
EOF

# Load variables
export $(cat ../.env | xargs)
```

#### Using export commands
```bash
export DB_URL=jdbc:postgresql://localhost:5432/tasklistdb
export DB_USERNAME=postgres
export DB_PASSWORD=admin
export SERVER_PORT=8080
# ... other variables
```

#### Using IDE run configuration
Configure your IDE run configuration to include these environment variables.

## API Endpoints

### Base URL
```
http://localhost:8080/api
```

### Available Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| **GET** | `/tasks` | Get all tasks |
| **GET** | `/tasks/{id}` | Get task by ID |
| **POST** | `/tasks` | Create new task |
| **PUT** | `/tasks/{id}` | Update existing task |
| **DELETE** | `/tasks/{id}` | Delete task |

### Request/Response Examples

#### Create Task
```bash
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Update documentation",
    "description": "Update README files",
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
    "title": "Update documentation",
    "description": "Update README files",
    "completed": true,
    "dueDate": "2024-12-31"
  }'
```

## Testing

### Running Tests
```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=TaskControllerTest

# Run tests with verbose output
mvn test -X

# Generate test report
mvn surefire-report:report
```

### Manual API Testing
```bash
# Health check
curl http://localhost:8080/actuator/health

# Create test task
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Task","description":"Testing","completed":false}'

# Verify task was created
curl http://localhost:8080/api/tasks
```

### Database Testing
```bash
# Connect to database (requires PostgreSQL running)
psql -h localhost -U postgres -d tasklistdb

# List tables
\dt

# View tasks
SELECT * FROM task;

# Count records
SELECT COUNT(*) FROM task;
```

## Deployment

### Docker Deployment
```bash
# Build Docker image
docker build -t tasklist-api .

# Run with Docker Compose (from project root)
docker-compose up --build

# Access application
curl http://localhost:8080/api/tasks
```

### VM Deployment
```bash
# Build JAR file
mvn clean package -DskipTests

# Copy JAR to VM
scp target/tasklist-api-*.jar user@vm-ip:/tmp/

# Deploy on VM
ssh user@vm-ip "sudo cp /tmp/tasklist-api-*.jar /opt/tasklist/app/tasklist-api.jar && sudo systemctl restart tasklist"
```

## Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Find process using port 8080
netstat -tulpn | grep :8080

# Kill process or use different port
mvn spring-boot:run -Dserver.port=8081
```

#### Database Connection Issues
```bash
# Check if PostgreSQL is running
pg_isready -h localhost -p 5432

# Check environment variables
echo $DB_URL
echo $DB_USERNAME
echo $DB_PASSWORD
```

#### Maven Build Issues
```bash
# Clean Maven repository
mvn clean

# Update dependencies
mvn dependency:resolve

# Skip tests if needed
mvn clean package -DskipTests
```

## Related Documentation

- **Main Project**: [../README.md](../README.md) - Complete project overview
- **Database Setup**: [../database/README.md](../database/README.md) - Database management
- **VM Deployment**: [../vm/README.md](../vm/README.md) - VM deployment guide
- **CI/CD Workflows**: [../.github/workflows/README.md](../.github/workflows/README.md) - Pipeline documentation