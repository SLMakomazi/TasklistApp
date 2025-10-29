# GitHub Actions CI/CD Workflows

**Status: All Workflows Operational — Images: GHCR Ready — Deployment: VM & Kubernetes Ready**

This directory contains the GitHub Actions workflows that automate the build, test, and deployment pipeline for TasklistApp.

## 📁 Workflow Files Overview

- `ci-testApplication.yml` - Run comprehensive unit and integration tests
- `ci-frontend-build.yml` - Build and push frontend Docker image to GitHub Container Registry (GHCR)
- `ci-backend-build.yml` - Build and push backend API and database Docker images to GHCR
- `vm-deploy.yml` - Deploy application to VM via self-hosted runner and systemd (manual trigger)

## 🚀 CI/CD Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    GitHub Actions Workflows                      │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              🧪 ci-testApplication.yml                  │    │
│  │  • Run unit and integration tests                      │    │
│  │  • Generate code coverage reports                      │    │
│  │  • Triggered by: Push to main/develop, PR              │    │
│  └───────────────────────────────┬─────────────────────────┘    │
│                                  ▼                               │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              🖥️ ci-frontend-build.yml                  │    │
│  │  • Build and push frontend Docker image                │    │
│  │  • Tag with latest and build number                   │    │
│  │  • Triggered by: Successful test completion           │    │
│  └───────────────────────────────┬─────────────────────────┘    │
│                                  ▼                               │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              🚀 ci-backend-build.yml                   │    │
│  │  • Build and push backend API and database images      │    │
│  │  • Tag with latest and build number                   │    │
│  │  • Triggered by: Successful frontend build             │    │
│  └───────────────────────────────┬─────────────────────────┘    │
│                                  ▼                               │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              🖥️ vm-deploy.yml (Manual Trigger)         │    │
│  │  • Deploy application to VM via systemd                │    │
│  │  • Zero-downtime deployment                           │    │
│  │  • Manual trigger only after successful backend build  │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

## 🧪 ci-testApplication.yml - Testing Pipeline

### Purpose
Builds, tests, and pushes optimized Docker images to GitHub Container Registry (GHCR) for use by ArgoCD and Kubernetes deployments.

### Triggers
- **Push to main branch**: Full build and deployment
- **Push to develop branch**: Build and test only
- **Pull Requests**: Run tests and validation
- **Manual trigger**: Available via GitHub UI

### Key Features
```yaml
# Multi-stage Docker builds for optimization
- Base stage: OpenJDK 17 Alpine
- Build stage: Maven compilation with caching
- Runtime stage: Minimal image with JRE only

# GitHub Container Registry integration
- Login with GITHUB_TOKEN
- Push multiple tags: latest + run_number
- Buildx for multi-platform support

# Performance optimizations
- Maven dependency caching
- Docker layer caching
- Parallel test execution
```

### Image Tags Generated
- `ghcr.io/slmakomazi/tasklistapp:api-latest` (stable)
- `ghcr.io/slmakomazi/tasklistapp:api-{run_number}` (versioned)
- `ghcr.io/slmakomazi/tasklistapp:db-latest` (database)
- `ghcr.io/slmakomazi/tasklistapp:db-{run_number}` (database versioned)

### Integration with ArgoCD
```bash
# ArgoCD watches for image changes
kubectl get applications tasklistapp -n argocd

# Manual image update example
kubectl set image deployment/tasklistapp-deployment tasklistapp=ghcr.io/slmakomazi/tasklistapp:api-123 -n tasklistapp
```

## 🧪 ci-test.yml - Testing Pipeline

### Purpose
Ensures code quality and functionality before deployment through comprehensive testing.

### Test Coverage
- **Unit Tests**: Individual component testing
- **Integration Tests**: Database and external service integration
- **TestContainers**: PostgreSQL service for database testing
- **Coverage Reports**: Code coverage analysis

### Testing Strategy
```yaml
# Individual test isolation
- Each test runs in separate process
- Parallel execution for faster results
- Detailed failure reporting

# Database testing with TestContainers
- PostgreSQL service container
- Automatic schema creation
- Clean database state per test
```

### Quality Gates
- ✅ All tests must pass
- ✅ Code coverage minimum thresholds
- ✅ No critical security vulnerabilities
- ✅ Linting and formatting checks

## 🖥️ vm-deploy.yml - VM Deployment Pipeline

### Purpose
Deploys the Spring Boot application to VM infrastructure using self-hosted GitHub Actions runner.

### Deployment Process
1. **Build Application**: Maven compilation and packaging
2. **Deploy to VM**: SSH transfer of JAR file
3. **Service Management**: Systemd service restart
4. **Verification**: Health checks and API validation

### Self-Hosted Runner Configuration
```yaml
# Runner setup in VM
- Ubuntu/Debian Linux
- GitHub Actions runner installed
- SSH access for deployment
- Systemd for service management

# Security considerations
- SSH key authentication
- Non-root service execution
- Firewall configuration
```

### Deployment Commands
```bash
# Automated deployment via GitHub Actions
- Build JAR: mvn clean package -DskipTests
- Copy to VM: scp target/tasklist-api-*.jar user@vm:/tmp/
- Deploy: sudo mv /tmp/tasklist-api-*.jar /opt/tasklist/app/
- Restart: sudo systemctl restart tasklist
- Verify: curl http://vm-ip:8080/actuator/health
```

## 🔄 ArgoCD Integration

### GitOps Flow
1. **Code Changes** → GitHub repository
2. **CI Pipeline** → Build and push Docker images to GHCR
3. **ArgoCD Detection** → Monitors k8s/ directory changes
4. **Auto-Sync** → Updates Kubernetes deployment
5. **Rolling Update** → Zero-downtime deployment

### Application Manifest (k8s/argocd-application.yaml)
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: tasklistapp
  namespace: argocd
spec:
  source:
    repoURL: https://github.com/slmakomazi/TasklistApp
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: tasklistapp
  syncPolicy:
    automated:
      prune: true      # Remove resources not in Git
      selfHeal: true   # Auto-recover from failures
```

## 📊 Workflow Monitoring

### Check Pipeline Status
```bash
# View workflow runs
- GitHub Repository → Actions tab
- Check latest runs for each workflow
- View detailed logs and artifacts

# Monitor in terminal
gh run list  # GitHub CLI
gh run view <run-id>  # Detailed view
```

### Common Issues and Solutions

#### Build Failures
```bash
# Check build logs in GitHub Actions
- Go to Actions tab in repository
- Click on failed workflow run
- View step-by-step logs

# Common fixes:
- Clear Maven cache: mvn clean
- Update dependencies: mvn dependency:resolve
- Check Java version: java -version
```

#### Image Push Failures
```bash
# Verify GHCR permissions
- Check GITHUB_TOKEN permissions
- Verify package settings in repository
- Check rate limits

# Manual image push test
docker login ghcr.io -u username -p token
docker push ghcr.io/slmakomazi/tasklistapp:api-latest
```

#### VM Deployment Failures
```bash
# Check runner status
sudo systemctl status actions-runner

# Check deployment logs
sudo journalctl -u actions-runner -f

# Manual deployment test
ssh user@vm-ip "sudo systemctl status tasklist"
```

## 🔐 Security and Best Practices

### Secrets Management
```yaml
# Never hardcode credentials in workflows
- Use GitHub repository secrets
- Rotate tokens regularly
- Use minimal required permissions

# Example secure configuration
env:
  DOCKER_REGISTRY: ghcr.io/slmakomazi
  IMAGE_NAME: tasklistapp
```

### Network Security
- **Private Runners**: Self-hosted runners on private network
- **SSH Security**: Key-based authentication only
- **Firewall**: Restrict access to necessary ports only
- **Container Security**: Non-root execution in containers

## 📈 Performance Optimizations

### Build Caching
```yaml
# Maven dependency caching
- uses: actions/cache@v3
  with:
    path: ~/.m2
    key: ${{ runner.os }}-maven-${{ hashFiles('**/pom.xml') }}

# Docker layer caching
cache-from: type=gha
cache-to: type=gha,mode=max
```

### Parallel Execution
```yaml
# Matrix builds for multiple environments
strategy:
  matrix:
    java-version: [17, 21]
    os: [ubuntu-latest, ubuntu-20.04]
```

## 🔧 Manual Operations

### Trigger Workflows Manually
```bash
# GitHub CLI
gh workflow run "CI - Build and Push Containers"

# GitHub UI
- Go to Actions tab
- Select workflow
- Click "Run workflow"
```

### Update Kubernetes Images
```bash
# Manual image update for testing
kubectl set image deployment/tasklistapp-deployment tasklistapp=ghcr.io/slmakomazi/tasklistapp:api-123 -n tasklistapp

# Check rollout status
kubectl rollout status deployment/tasklistapp-deployment -n tasklistapp
```

### Cleanup Old Images
```bash
# Clean up old GHCR packages
gh api repos/slmakomazi/TasklistApp/actions/packages/container/tasklistapp/versions \
  -H "Accept: application/vnd.github.v3+json" \
  -q '.[] | select(.metadata.container.tags | length == 0) | .id' | \
  xargs -I % gh api repos/slmakomazi/TasklistApp/actions/packages/container/tasklistapp/versions/% \
  -X DELETE -H "Accept: application/vnd.github.v3+json"
```

## 📋 Workflow Status Dashboard

### Current Pipeline Health
- **ci-build.yml**: ✅ Passing (Docker images in GHCR)
- **ci-test.yml**: ✅ Passing (All tests successful)
- **vm-deploy.yml**: ✅ Passing (VM deployment operational)
- **ArgoCD Sync**: ✅ Active (Auto-sync enabled)

### Recent Activity
```bash
# Check latest workflow runs
gh run list --limit 5

# View specific run details
gh run view 1234567890

# Check ArgoCD application status
kubectl get applications -n argocd
```

## 🚨 Emergency Procedures

### Stop All Deployments
```bash
# Disable ArgoCD sync
kubectl patch application tasklistapp -n argocd --type='merge' -p='{"spec":{"syncPolicy":{"automated":null}}}'

# Scale down Kubernetes deployment
kubectl scale deployment tasklistapp-deployment --replicas=0 -n tasklistapp

# Stop VM service
ssh user@vm-ip "sudo systemctl stop tasklist"
```

### Rollback Procedures
```bash
# ArgoCD rollback to previous version
kubectl argo rollouts undo tasklistapp -n argocd

# VM rollback
ssh user@vm-ip "sudo systemctl stop tasklist && sudo mv /opt/tasklist/app/tasklist-api.jar.bak /opt/tasklist/app/tasklist-api.jar && sudo systemctl start tasklist"
```

## 📚 Additional Resources

- **[GitHub Actions Documentation](https://docs.github.com/en/actions)** - Official workflow docs
- **[GitHub Container Registry](https://docs.github.com/en/packages)** - GHCR documentation
- **[ArgoCD Documentation](https://argo-cd.readthedocs.io/)** - GitOps deployment
- **[MicroK8s Workflows](https://microk8s.io/docs)** - Kubernetes for workstations

---

**All workflows operational and ready for production deployment!** 🚀
