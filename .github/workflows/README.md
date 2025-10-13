# GitHub Actions - CI/CD Pipeline

This directory contains GitHub Actions workflows for automated building, testing, and deployment of the TasklistApp. The CI/CD pipeline supports both Docker and VM deployment strategies.

## Table of Contents

- [Pipeline Overview](#pipeline-overview)
- [Available Workflows](#available-workflows)
- [Configuration](#configuration)
- [Required Secrets](#required-secrets)
- [Testing](#testing)
- [Deployment](#deployment)

## Pipeline Overview

The TasklistApp uses two main GitHub Actions workflows for continuous integration and deployment:

### 1. Build and Test Pipeline (`docker-build.yml`)

#### Purpose
This pipeline builds, tests, and pushes Docker images to Docker Hub.

#### Triggers
- **Push events** to `main` and `develop` branches
- **Pull Requests** to `main` branch
- **Manual trigger** via `workflow_dispatch`

#### Key Features
- **Maven dependency caching** for faster builds
- **Unit and integration testing** with PostgreSQL service
- **Multi-stage Docker image building**
- **Automated push to Docker Hub** (`slmakomazi/tasklistapp`)
- **Build artifact caching** for improved performance

#### Workflow Steps
1. **Checkout code** from repository
2. **Cache Maven dependencies** for faster builds
3. **Set up Java 17** with Maven caching
4. **Build and run unit tests** with Maven
5. **Run integration tests** with PostgreSQL service
6. **Set up Docker Buildx** for cross-platform builds
7. **Login to Docker Hub** (on main branch pushes)
8. **Build and push Docker image** (on main branch pushes)

#### Cache Usage
- **Maven dependencies**: `~/.m2/repository` cached based on `pom.xml` hash
- **Docker layers**: GitHub Actions cache for faster image builds
- **Build artifacts**: Reused across workflow runs

### 2. VM Deployment Pipeline (`vm-deploy.yml`)

#### Purpose
This pipeline builds and deploys the application to a VM using a self-hosted runner for local deployment.

#### Triggers
- **Push events** to `main` branch
- **Manual trigger** via `workflow_dispatch`

#### Key Features
- **Automated JAR building** from source code
- **Self-hosted runner deployment** with local service management
- **Systemd service restart** and verification
- **Deployment artifact management**
- **Error handling** and rollback capabilities

#### Workflow Steps
1. **Checkout code** from repository
2. **Set up Java 17** with Maven caching
3. **Build Maven project** (skips tests for faster deployment)
4. **Deploy application locally** using systemd service management
5. **Verify deployment** and check service status

#### Cache Usage
- **Maven dependencies**: `~/.m2/repository` cached based on `pom.xml` hash
- **Java setup**: GitHub Actions cache for Java installation

## Available Workflows

### docker-build.yml
**Location**: `.github/workflows/docker-build.yml`

**Description**: Builds Docker images, runs tests, and pushes to Docker Hub.

**Runner**: `ubuntu-latest` (GitHub-hosted)

**Services**:
- PostgreSQL 16 for integration testing

**Artifacts**:
- Docker image: `slmakomazi/tasklistapp:latest`

### vm-deploy.yml
**Location**: `.github/workflows/vm-deploy.yml`

**Description**: Builds JAR and deploys to VM via self-hosted runner.

**Runner**: `self-hosted` (installed on target VM)

**Artifacts**:
- Deployment runs locally on VM via self-hosted runner

## Configuration

### GitHub Actions Runner Environment

The `docker-build.yml` workflow runs on GitHub-hosted `ubuntu-latest` runners, while `vm-deploy.yml` uses a self-hosted runner installed on the target VM.

#### Pre-installed Tools
- **Java 17** (Temurin distribution)
- **Maven 3.8+**
- **Docker** and **Docker Compose**
- **Git**
- **curl** and **wget**

#### Network Access
- **Outbound connections** allowed for Docker Hub, Maven repositories (for docker-build.yml)
- **GitHub connectivity** required for self-hosted runner to receive jobs (for vm-deploy.yml)
- **SSH access** to configured VM hosts

### Workflow Triggers

#### Automatic Triggers
```yaml
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  workflow_dispatch:  # Manual trigger
```

#### Branch Protection
- **Main branch**: Triggers both workflows
- **Develop branch**: Triggers build-and-test only
- **Feature branches**: Can trigger via pull requests

### Workflow Status Badges
Add these badges to your repository README:

```markdown
[![Build and Test](https://github.com/SLMakomazi/TasklistApp/actions/workflows/docker-build.yml/badge.svg)](https://github.com/SLMakomazi/TasklistApp/actions/workflows/docker-build.yml)
[![VM Deploy](https://github.com/SLMakomazi/TasklistApp/actions/workflows/vm-deploy.yml/badge.svg)](https://github.com/SLMakomazi/TasklistApp/actions/workflows/vm-deploy.yml)
```

## Required Secrets

### GitHub Repository Secrets

Configure these secrets in your GitHub repository settings:

#### For VM Deployment (`vm-deploy.yml`)
**Note**: No repository secrets required for VM deployment when using self-hosted runner. The runner operates locally on the target VM.

#### For Docker Hub (`docker-build.yml`)
```bash
DOCKER_USERNAME = your-dockerhub-username
DOCKER_PASSWORD = your-dockerhub-password
```

### Setting Up Secrets

1. **Go to GitHub Repository** → **Settings** → **Secrets and variables** → **Actions**
2. **Click "New repository secret"**
3. **Add each secret with the exact name shown above**
4. **Paste the corresponding value**

#### Self-Hosted Runner Setup for VM Deployment

1. **Download and configure self-hosted runner** on your target VM:
   ```bash
   # Download the runner (use the appropriate platform)
   curl -o actions-runner-linux-x64-2.314.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.314.1/actions-runner-linux-x64-2.314.1.tar.gz
   
   # Extract and configure
   tar xzf ./actions-runner-linux-x64-2.314.1.tar.gz
   cd actions-runner
   ./config.sh --url https://github.com/YOUR_USERNAME/YOUR_REPO --token YOUR_RUNNER_TOKEN
   ```

2. **Install and start the runner service**:
   ```bash
   sudo ./svc.sh install
   sudo ./svc.sh start
   ```

## Testing

### Build and Test Pipeline Testing

#### Unit Tests
- **Location**: `app/src/test/java/`
- **Framework**: JUnit 5
- **Coverage**: Repository and service layer tests
- **Execution**: `mvn test` in pipeline

#### Integration Tests
- **Framework**: Spring Boot Test with TestContainers
- **Database**: PostgreSQL 16 service in workflow
- **Coverage**: Full application context with database
- **Execution**: `mvn test -Dspring.profiles.active=test`

#### Test Configuration
```yaml
# PostgreSQL service for testing
services:
  postgres:
    image: postgres:16
    env:
      POSTGRES_DB: testdb
      POSTGRES_USER: test
      POSTGRES_PASSWORD: test
```

### Manual Testing

#### Test Workflow Triggers
```bash
# Trigger build-and-test manually
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/SLMakomazi/TasklistApp/actions/workflows/docker-build.yml/dispatches \
  -d '{"ref":"main"}'

# Trigger VM deployment manually
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/SLMakomazi/TasklistApp/actions/workflows/vm-deploy.yml/dispatches \
  -d '{"ref":"main"}'
```

#### View Workflow Runs
- **GitHub Actions tab**: https://github.com/SLMakomazi/TasklistApp/actions
- **API endpoint**: `https://api.github.com/repos/SLMakomazi/TasklistApp/actions/runs`

## Deployment

### Docker Deployment Pipeline

#### Docker Image Build Process
1. **Maven build** in `/app` directory
2. **Multi-stage Docker build** with optimized layers
3. **Integration testing** with PostgreSQL service
4. **Push to Docker Hub** on main branch

#### Image Details
- **Base image**: `eclipse-temurin:17-jre`
- **Build context**: `./app`
- **Tags**: `slmakomazi/tasklistapp:latest`
- **Size**: ~150MB optimized image

### VM Deployment Pipeline

#### VM Deployment Process
1. **Self-hosted runner activation** - GitHub triggers the runner installed on the VM
2. **Maven build** in `/app` directory (skips tests)
3. **Local deployment** - Runner executes deployment commands directly on the VM
4. **Service management** - Updates and restarts systemd service locally

#### Deployment Execution
- All deployment commands run directly on the VM via self-hosted runner
- No network file transfers or SSH connections required
- Immediate feedback and error reporting from local execution

### Deployment Verification

#### Check Workflow Status
```bash
# View recent workflow runs
gh run list --workflow=docker-build.yml
gh run list --workflow=vm-deploy.yml

# View specific run details
gh run view <run-id>
```

#### Manual Verification
```bash
# Test Docker deployment
curl http://localhost:8080/api/tasks

# Test VM deployment
curl http://vm-ip:8080/api/tasks

# Check application health
curl http://localhost:8080/actuator/health
curl http://vm-ip:8080/actuator/health
```

## Related Documentation

- **Main Project**: [../../README.md](../../README.md) - Complete project overview
- **Spring Boot App**: [../../app/README.md](../../app/README.md) - Application development guide
- **VM Deployment**: [../../vm/README.md](../../vm/README.md) - VM deployment guide
- **Database Setup**: [../../database/README.md](../../database/README.md) - Database management guide