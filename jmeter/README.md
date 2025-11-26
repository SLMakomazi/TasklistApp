# JMeter Load Testing for TasklistApp

This directory contains JMeter test plans and configurations for comprehensive load testing the Tasklist Application. The tests are integrated with the CI/CD pipeline for automated performance validation.

## Directory Structure

```
jmeter/
├── test-plans/      # JMeter .jmx test plans
│   └── api-load-test.jmx  # Complete API load test
├── data/            # Test data files (CSV, JSON, etc.)
├── results/         # Test execution results (gitignored)
├── Dockerfile       # Container configuration for JMeter
└── run-test.sh      # Helper script to run tests
```

## Prerequisites

- Java 8 or higher
- Apache JMeter 5.4.1 (or compatible version)
- Docker (for containerized execution)
- kubectl (for Kubernetes execution)
- Access to deployed TasklistApp

## 🚀 Running Tests

### 1. Against Local Development
```bash
# Run with default settings (localhost:8080)
jmeter -n -t test-plans/api-load-test.jmx -l results.jtl

# Generate HTML report
jmeter -g results.jtl -o report/
```

### 2. Against Kubernetes Deployment
```bash
# Get application NodePort
APP_PORT=$(kubectl get svc tasklistapp-service -n tasklist -o jsonpath='{.spec.ports[0].nodePort}')
HOST=$(hostname -I | awk '{print $1}')

# Run test against Kubernetes
jmeter -n -t test-plans/api-load-test.jmx \
        -l results.jtl \
        -J HOST=$HOST \
        -J PORT=$APP_PORT
```

### 3. Using Docker
```bash
# Build the JMeter image
docker build -t tasklist-jmeter .

# Run against Kubernetes deployment
docker run --rm \
  -v $(pwd)/test-plans:/test \
  -v $(pwd)/results:/test/results \
  -e HOST=$(hostname -I | awk '{print $1}') \
  -e PORT=$(kubectl get svc tasklistapp-service -n tasklist -o jsonpath='{.spec.ports[0].nodePort}') \
  tasklist-jmeter
```

### 4. Automated via CI/CD
The load tests are automatically executed as part of the deployment pipeline:
```bash
# This runs automatically in deploy-to-k8s.yml workflow
jmeter -n -t jmeter/test-plans/api-load-test.jmx \
        -l results.jtl \
        -J HOST=$(hostname -I | awk '{print $1}') \
        -J PORT=30080
```

## 📊 Test Plan Details

### API Load Test (`api-load-test.jmx`)
- **Purpose**: Comprehensive API performance testing
- **Endpoints Tested**:
  - `GET /api/tasks` - Retrieve all tasks
  - `POST /api/tasks` - Create new tasks
- **Configuration**:
  - **Threads**: 20 concurrent users (configurable)
  - **Loops**: 10 iterations per user (configurable)
  - **Ramp-up**: 5 seconds (configurable)
  - **Delay**: 1000ms between requests (configurable)

### Parameters
The test plan uses these configurable parameters:
- `HOST` - Target host (default: localhost)
- `PORT` - Target port (default: 8080)
- `PROTOCOL` - HTTP/HTTPS (default: http)
- `THREADS` - Number of concurrent users (default: 20)
- `LOOPS` - Number of iterations (default: 10)
- `RAMP` - Ramp-up time in seconds (default: 5)
- `DELAY` - Delay between requests in ms (default: 1000)

### Customizing Test Parameters
```bash
# Run with custom parameters
jmeter -n -t test-plans/api-load-test.jmx \
        -l results.jtl \
        -J HOST=your-host \
        -J PORT=30080 \
        -J THREADS=50 \
        -J LOOPS=20 \
        -J RAMP=10 \
        -J DELAY=500
```

## 📈 Test Results

### Result Files
Each test run creates:
- `results.jtl` - Raw test results in JTL format
- `report/` - HTML dashboard with comprehensive metrics
- `log/` - JMeter execution logs

### Key Metrics
The HTML report includes:
- **Response Times**: Average, min, max, percentiles
- **Throughput**: Requests per second
- **Error Rate**: Percentage of failed requests
- **Latency**: Network and processing latency
- **Concurrency**: Active users over time

### Performance Benchmarks
Expected performance targets:
- **Response Time**: < 500ms (95th percentile)
- **Throughput**: > 100 requests/second
- **Error Rate**: < 1%
- **CPU Usage**: < 80% under load

## 🔧 Integration with CI/CD

### GitHub Actions Integration
The load tests are integrated into the deployment pipeline and use the following secrets:

| Secret Name | Description | Last Updated |
|-------------|-------------|--------------|
| `ANSIBLE_VAULT_PASSWORD` | Password for decrypting Ansible vault files | 2 days ago |
| `DB_PASSWORD` | PostgreSQL database password | last month |
| `DB_URL` | Database connection URL | last month |
| `DB_USERNAME` | PostgreSQL database username | last month |
| `DOCKER_PASSWORD` | Docker Hub/GHCR password | last month |
| `DOCKER_USERNAME` | Docker Hub/GHCR username | last month |
| `FRONTEND_API_URL` | Frontend API endpoint configuration | last month |
| `SSH_KNOWN_HOSTS` | SSH known hosts file content | 3 weeks ago |
| `SSH_PRIVATE_KEY` | SSH private key for VM access | 3 weeks ago |
| `SUDO_PASSWORD` | WSL Ubuntu sudo password for runner | 2 days ago |
| `VM_HOST` | Target VM hostname/IP | last month |
| `VM_SSH_KEY` | SSH key for VM access | last month |
| `VM_USER` | SSH username for VM access | last month |

**Note**: Current implementation uses zero SSH deployment. SSH secrets are retained for compatibility.

```yaml
# From deploy-to-k8s.yml
- name: Run Load Tests
  run: |
    jmeter -n -t jmeter/test-plans/api-load-test.jmx \
            -l results.jtl \
            -J HOST=$(hostname -I | awk '{print $1}') \
            -J PORT=30080
    
    jmeter -g results.jtl -o report/
    
    # Upload results
    echo "## Load Test Results" >> $GITHUB_STEP_SUMMARY
    echo "### Response Times" >> $GITHUB_STEP_SUMMARY
    grep "Average.*ms" report/dashboard/index.html >> $GITHUB_STEP_SUMMARY || true
```

### Performance Gates
The pipeline can include performance validation:
- Response time thresholds
- Error rate limits
- Throughput requirements
- Resource usage monitoring

## 🛠️ Customization

### Adding New Test Plans
1. Create new `.jmx` files in `test-plans/`
2. Use parameterized values for environment flexibility
3. Add assertions for response validation
4. Update CI/CD pipeline to include new tests

### Test Data Management
```bash
# Add test data files
mkdir -p data
echo "test_data_1,test_data_2" > data/test.csv

# Reference in test plan
${__CSVRead(data/test.csv,0)}
```

### Environment-Specific Tests
Create different test configurations:
```bash
# Development environment
-J HOST=localhost -J PORT=8080

# Staging environment  
-J HOST=staging.example.com -J PORT=443 -J PROTOCOL=https

# Production environment
-J HOST=prod.example.com -J PORT=443 -J PROTOCOL=https
```

## 🔍 Troubleshooting

### Common Issues
- **Connection refused**: Verify application is running and accessible
- **High error rates**: Check application logs for errors during testing
- **Memory issues**: Increase JMeter heap size: `jmeter -Xms2g -Xmx4g`
- **Port conflicts**: Use different ports for concurrent tests

### Debugging Tests
```bash
# Run with GUI for debugging
jmeter -t test-plans/api-load-test.jmx

# Enable detailed logging
jmeter -n -t test-plans/api-load-test.jmx -l results.jtl -L DEBUG

# View specific request details
grep "POST /api/tasks" results.jtl
```

## 📚 Best Practices

### Test Design
- ✅ **Parameterized tests** for environment flexibility
- ✅ **Assertions** to validate response correctness
- ✅ **Think time** between requests to simulate real users
- ✅ **Ramp-up periods** to avoid shock loading
- ✅ **Resource monitoring** during test execution

### Performance Monitoring
- Monitor application metrics during load testing
- Track database performance under load
- Monitor Kubernetes resource usage
- Set up alerts for performance degradation

### Continuous Improvement
- Regularly update test scenarios based on usage patterns
- Maintain performance baselines and trends
- Incorporate performance requirements in acceptance criteria
- Use test results for capacity planning

## 🔗 Additional Resources

- [JMeter User Manual](https://jmeter.apache.org/usermanual/index.html)
- [Performance Testing Best Practices](https://jmeter.apache.org/usermanual/best-practices.html)
- [Kubernetes Performance Testing](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/)
