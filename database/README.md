# 🗄️ Database Layer - PostgreSQL Setup

This directory contains the **PostgreSQL database configuration** for the TasklistApp. It includes Docker Compose setup, initialization scripts, and database management utilities.

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue)
![Docker](https://img.shields.io/badge/Docker-Ready-blue)

## 📋 Table of Contents

- [🏗️ Database Overview](#-database-overview)
- [🚀 Quick Start](#-quick-start)
- [📁 Directory Structure](#-directory-structure)
- [🐳 Docker Configuration](#-docker-configuration)
- [🔧 Database Management](#-database-management)
- [🔍 Monitoring & Maintenance](#-monitoring--maintenance)

## 🏗️ Database Overview

### Database Specifications
- **Database**: PostgreSQL 16
- **Container**: `tasklist-postgres`
- **Database Name**: `tasklistdb`
- **Default User**: `postgres`
- **Default Password**: `admin`
- **Port**: `5432` (external), `5432` (internal)

### Key Features
- ✅ **Persistent Storage** - Data survives container restarts
- ✅ **Health Checks** - Automatic readiness verification
- ✅ **Network Isolation** - Secure inter-container communication
- ✅ **Volume Management** - Named volumes for data persistence
- ✅ **Initialization** - Automatic database and user creation

## 🚀 Quick Start

### Start Database Only
```bash
# From database directory (legacy method)
docker-compose up -d

# Or from root directory (recommended)
cd .. && docker-compose up -d tasklist-postgres
```

### Verify Database is Running
```bash
# Check container status
docker ps | grep postgres

# Check database connectivity
docker exec tasklist-postgres psql -U postgres -d tasklistdb -c "SELECT version();"

# List all databases
docker exec tasklist-postgres psql -U postgres -l
```

## 📁 Directory Structure

```
database/
├── 📄 README.md                 # This file
├── 📄 docker-compose.yml        # Database container configuration
├── 📁 init-scripts/            # Database initialization SQL
│   └── 📄 01-create-database.sql
└── 📁 backups/                 # Database backup files
    └── 📄 schema.sql
```

## 🐳 Docker Configuration

### Docker Compose Configuration
```yaml
# docker-compose.yml
version: '3.8'
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
```

### Environment Variables
| Variable | Value | Description |
|----------|-------|-------------|
| `POSTGRES_USER` | `postgres` | Database username |
| `POSTGRES_PASSWORD` | `admin` | Database password |
| `POSTGRES_DB` | `tasklistdb` | Database name |
| `POSTGRES_PORT` | `5432` | Database port |

### Volumes
- **`postgres_data`** - Persistent storage for database files
- **Location**: `/var/lib/postgresql/data` inside container
- **Backup**: Automatic with container volume management

## 🔧 Database Management

### Connect to Database
```bash
# Method 1: Docker exec
docker exec -it tasklist-postgres psql -U postgres -d tasklistdb

# Method 2: Direct connection (if exposed)
psql -h localhost -p 5432 -U postgres -d tasklistdb

# Method 3: From host with password
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

-- Create new user
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

# Restore specific table
docker exec -i tasklist-postgres psql -U postgres -d tasklistdb -c "\COPY task FROM 'task_data.csv' WITH CSV HEADER"
```

## 🔍 Monitoring & Maintenance

### Container Monitoring
```bash
# View container logs
docker logs tasklist-postgres

# Monitor real-time logs
docker logs -f tasklist-postgres

# Check resource usage
docker stats tasklist-postgres
```

### Database Performance
```bash
# Check active connections
docker exec tasklist-postgres psql -U postgres -d tasklistdb -c "SELECT * FROM pg_stat_activity;"

# View table sizes
docker exec tasklist-postgres psql -U postgres -d tasklistdb -c "SELECT schemaname, tablename, attname, n_distinct FROM pg_stats WHERE tablename = 'task';"

# Check database size
docker exec tasklist-postgres psql -U postgres -d tasklistdb -c "SELECT pg_size_pretty(pg_database_size('tasklistdb'));"
```

### Health Checks
```bash
# Test database connectivity
docker exec tasklist-postgres pg_isready -U postgres -d tasklistdb

# Check if container is healthy
docker inspect tasklist-postgres | grep -A 5 '"Health"'
```

## 🛠️ Troubleshooting

### Common Issues

**Container Won't Start**
```bash
# Check if port 5432 is in use
netstat -tulpn | grep :5432

# Stop conflicting PostgreSQL service
sudo systemctl stop postgresql  # Linux
# or
net stop PostgreSQL  # Windows

# Remove existing container
docker rm -f tasklist-postgres
```

**Connection Refused**
```bash
# Check if container is running
docker ps | grep tasklist-postgres

# Check container logs for errors
docker logs tasklist-postgres

# Verify network connectivity
docker network ls
docker network inspect tasklistapp_tasklist-network
```

**Authentication Failed**
```bash
# Check environment variables
docker exec tasklist-postgres env | grep POSTGRES

# Verify user exists
docker exec tasklist-postgres psql -U postgres -c "\du"

# Reset password if needed
docker exec tasklist-postgres psql -U postgres -c "ALTER USER postgres PASSWORD 'newpassword';"
```

**Permission Denied**
```bash
# Check volume permissions
docker volume ls

# Inspect volume details
docker volume inspect tasklistapp_postgres_data

# Fix permissions if needed
docker run --rm -v tasklistapp_postgres_data:/data alpine chown -R 999:999 /data
```

## 🔒 Security Considerations

### Production Security
```yaml
# Use strong passwords
POSTGRES_PASSWORD: "your-secure-password-here"

# Use secrets management
secrets:
  db_password:
    file: ./secrets/db_password.txt
```

### Network Security
- Database port only exposed to necessary services
- Use Docker networks for service isolation
- Avoid exposing database port to host in production

### Access Control
```sql
-- Create read-only user for application
CREATE USER app_user WITH PASSWORD 'secure-password';
GRANT CONNECT ON DATABASE tasklistdb TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
```

## 🚀 Production Deployment

### Scaling Considerations
- **Read Replicas**: Add for read-heavy workloads
- **Connection Pooling**: Use PgBouncer for high concurrency
- **Backup Strategy**: Automated daily backups to S3/cloud storage

### High Availability
```yaml
# Example: PostgreSQL with replication
services:
  postgres-primary:
    # Primary database config

  postgres-replica:
    # Replica configuration
```

### Backup Strategy
```bash
# Automated backup script
#!/bin/bash
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup
docker exec tasklist-postgres pg_dump -U postgres tasklistdb > $BACKUP_DIR/backup_$DATE.sql

# Upload to cloud storage
aws s3 cp $BACKUP_DIR/backup_$DATE.sql s3://your-bucket/backups/
```

## 📊 Database Schema

### Current Tables

#### `task` Table
```sql
CREATE TABLE task (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    due_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Schema Evolution
- **Auto-migration**: Hibernate handles schema updates
- **Manual changes**: Add SQL scripts to `init-scripts/`
- **Version control**: Track schema changes in migrations

## 🤝 Maintenance Tasks

### Regular Maintenance
1. **Weekly**: Review and archive old logs
2. **Monthly**: Check disk space usage
3. **Quarterly**: Review and optimize slow queries
4. **Yearly**: Plan database upgrades and security updates

### Performance Optimization
```sql
-- Analyze table statistics
ANALYZE task;

-- Reindex if needed
REINDEX TABLE task;

-- View slow queries
SELECT * FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;
```

## 📄 Related Documentation

- **Main Project**: [../README.md](../README.md) - Complete project overview
- **Spring Boot App**: [../app/README.md](../app/README.md) - Application development guide
- **API Reference**: [../docs/API.md](../docs/API.md) - API documentation

---

**🗄️ Database Management Made Easy!** PostgreSQL + Docker = 🚀