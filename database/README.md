# Database Layer - PostgreSQL Setup

This directory contains the PostgreSQL database configuration for the TasklistApp. The database runs in a Docker container and provides persistent storage for the Spring Boot API application.

## Table of Contents

- [Database Overview](#database-overview)
- [Setup Instructions](#setup-instructions)
- [Docker Container Management](#docker-container-management)
- [Environment Variables](#environment-variables)
- [Database Management](#database-management)
- [Troubleshooting](#troubleshooting)

## Database Overview

### Database Specifications
- **Database**: PostgreSQL 16
- **Container**: `tasklist-postgres`
- **Database Name**: `tasklistdb`
- **User**: `postgres`
- **Password**: `admin`
- **Port**: `5432`

### Key Features
- **Persistent Storage** - Docker volumes (`tasklistapp_postgres_data`)
- **Environment Configuration** - No hardcoded values
- **Health Checks** - Automatic readiness verification
- **Network Isolation** - Secure inter-container communication
- **Multi-Instance Ready** - Supports local + VM + Kubernetes architecture
- **Production Security** - Configurable credentials
- **Kubernetes Ready** - StatefulSet deployment with persistent volumes

## Setup Instructions

### Prerequisites
- **Docker** and **Docker Compose** installed
- **Git** for cloning the repository

### Quick Start

#### Start Database with Main Application
```bash
# From project root (recommended)
docker-compose up -d tasklist-postgres

# Or start entire application stack
docker-compose up -d --build
```

#### Verify Database is Running
```bash
# Check container status
docker ps | grep postgres

# Check database connectivity
docker exec tasklist-postgres psql -U postgres -d tasklistdb -c "SELECT version();"

# List all databases
docker exec tasklist-postgres psql -U postgres -l
```

## Docker Container Management

### Container Configuration

The database is configured in the main `docker-compose.yml` file:

```yaml
services:
  tasklist-postgres:
    image: postgres:16
    container_name: tasklist-postgres
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: admin
      POSTGRES_DB: tasklistdb
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - tasklist-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d tasklistdb"]
      interval: 10s
      timeout: 5s
      retries: 5
```

### Volume Persistence
- **Volume Name**: `tasklistapp_postgres_data`
- **Storage Location**: Docker managed volume
- **Data Survival**: Container restarts, removals, crashes
- **Backup Ready**: Can be backed up and restored

### Container Lifecycle Management
```bash
# Start database container
docker-compose up -d tasklist-postgres

# View running containers
docker ps | grep tasklist-postgres

# Check container logs
docker logs tasklist-postgres

# Monitor real-time logs
docker logs -f tasklist-postgres

# Check resource usage
docker stats tasklist-postgres

# Stop database container
docker-compose stop tasklist-postgres

# Remove database container (data persists in volume)
docker-compose rm tasklist-postgres
```

## Environment Variables

The database uses environment variables for configuration:

### Required Environment Variables

```env
# PostgreSQL Container Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=admin
POSTGRES_DB=tasklistdb
POSTGRES_PORT=5432

# Application Connection Configuration
DB_URL=jdbc:postgresql://tasklist-postgres:5432/tasklistdb
DB_USERNAME=postgres
DB_PASSWORD=admin

# JPA/Hibernate Configuration (for Spring Boot application)
JPA_DDL_AUTO=update
JPA_SHOW_SQL=true
```

### Environment Variable Mapping

| Environment Variable | Component | Description |
|---------------------|-----------|-------------|
| `POSTGRES_USER` | PostgreSQL | Database username |
| `POSTGRES_PASSWORD` | PostgreSQL | Database password |
| `POSTGRES_DB` | PostgreSQL | Database name |
| `POSTGRES_PORT` | PostgreSQL | Database port (5432) |
| `DB_URL` | Spring Boot | JDBC connection URL |
| `DB_USERNAME` | Spring Boot | Database username for application |
| `DB_PASSWORD` | Spring Boot | Database password for application |
| `JPA_DDL_AUTO` | Spring Boot | JPA schema auto-update mode |
| `JPA_SHOW_SQL` | Spring Boot | Show SQL queries in application logs |

### Setting Environment Variables

#### Using .env file (recommended for development)
```bash
# Create .env file in project root
cat > ../.env << EOF
# PostgreSQL Container Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=admin
POSTGRES_DB=tasklistdb

# Application Connection Configuration
DB_URL=jdbc:postgresql://tasklist-postgres:5432/tasklistdb
DB_USERNAME=postgres
DB_PASSWORD=admin

# JPA Configuration
JPA_DDL_AUTO=update
JPA_SHOW_SQL=true
EOF

# Load variables
export $(cat ../.env | xargs)
```

#### Using Docker Compose environment file
```bash
# Use with docker-compose
docker-compose --env-file .env up -d
```

#### Direct export for testing
```bash
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=admin
export DB_URL=jdbc:postgresql://localhost:5432/tasklistdb
```

## Database Management

### Connect to Database

#### Method 1: Docker exec (recommended)
```bash
docker exec -it tasklist-postgres psql -U postgres -d tasklistdb
```

#### Method 2: Direct connection from host
```bash
psql -h localhost -p 5432 -U postgres -d tasklistdb
```

#### Method 3: From host with password
```bash
PGPASSWORD=admin psql -h localhost -U postgres -d tasklistdb
```

### Common PostgreSQL Commands

#### Database Operations
```sql
-- List all databases
\l

-- Switch to tasklistdb
\c tasklistdb

-- List all tables
\dt

-- Describe table structure
\d task

-- Show table data
SELECT * FROM task;

-- Count records
SELECT COUNT(*) FROM task;
```

#### User Management
```sql
-- List all users
\du

-- Create new user (if needed)
CREATE USER newuser WITH PASSWORD 'password';

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE tasklistdb TO newuser;
```

### Database Backup & Restore

#### Create Backup
```bash
# Backup entire database
docker exec tasklist-postgres pg_dump -U postgres tasklistdb > backup_$(date +%Y%m%d_%H%M%S).sql

# Backup specific table
docker exec tasklist-postgres pg_dump -U postgres -t task tasklistdb > task_table_backup.sql
```

#### Restore Database
```bash
# Restore from backup file
docker exec -i tasklist-postgres psql -U postgres -d tasklistdb < backup_file.sql

# Restore specific table data
docker exec -i tasklist-postgres psql -U postgres -d tasklistdb -c "\COPY task FROM 'task_data.csv' WITH CSV HEADER"
```

## Troubleshooting

### Common Issues

#### Container Won't Start
```bash
# Check if port 5432 is in use
netstat -tulpn | grep :5432

# Stop conflicting PostgreSQL service
sudo systemctl stop postgresql  # Linux

# Remove existing container
docker rm -f tasklist-postgres
```

#### Connection Refused
```bash
# Check if container is running
docker ps | grep tasklist-postgres

# Check container logs for errors
docker logs tasklist-postgres

# Verify network connectivity
docker network ls
docker network inspect tasklistapp_tasklist-network
```

#### Authentication Failed
```bash
# Check environment variables
docker exec tasklist-postgres env | grep POSTGRES

# Verify user exists
docker exec tasklist-postgres psql -U postgres -c "\du"

# Reset password if needed
docker exec tasklist-postgres psql -U postgres -c "ALTER USER postgres PASSWORD 'newpassword';"
```

## Kubernetes Deployment

The PostgreSQL database can also be deployed to Kubernetes using the manifests in the `../k8s/` directory.

### Kubernetes PostgreSQL Architecture

- **Deployment**: StatefulSet for stateful database deployment
- **Persistent Storage**: PersistentVolumeClaim for data persistence
- **Service**: ClusterIP service for internal cluster access
- **Configuration**: Secrets for credentials, ConfigMap for configuration

### Deploy PostgreSQL to Kubernetes

```bash
# Apply PostgreSQL Kubernetes manifests
kubectl apply -f ../k8s/postgres-pvc.yaml
kubectl apply -f ../k8s/postgres-service.yaml
kubectl apply -f ../k8s/postgres-deployment.yaml

# Wait for deployment to be ready
kubectl wait --for=condition=available --timeout=300s deployment/tasklistapp-postgresql-deployment -n tasklistapp

# Check status
kubectl get pods -l app=tasklistapp-postgresql -n tasklistapp
```

### Kubernetes Database Access

The Spring Boot application in Kubernetes connects to PostgreSQL using the Kubernetes service:

```bash
# From within Kubernetes cluster
DB_URL=jdbc:postgresql://tasklistapp-postgresql-service:5432/tasklistdb
```

### Backup and Recovery

```bash
# Create backup of PersistentVolume
kubectl exec tasklistapp-postgresql-deployment-0 -n tasklistapp -- pg_dump -U postgres tasklistdb > backup.sql

# Restore from backup
kubectl exec -i tasklistapp-postgresql-deployment-0 -n tasklistapp -- psql -U postgres tasklistdb < backup.sql
```

### Scaling Considerations

- PostgreSQL StatefulSets provide stable network identities
- Persistent volumes ensure data survival across pod restarts
- For production, consider PostgreSQL Operator for advanced features

## Related Documentation

- **Main Project**: [../README.md](../README.md) - Complete project overview
- **Spring Boot App**: [../app/README.md](../app/README.md) - Application development guide
- **Kubernetes Deployment**: [../k8s/README.md](../k8s/README.md) - Kubernetes deployment guide (NEW)
- **VM Deployment**: [../vm/README.md](../vm/README.md) - VM deployment guide