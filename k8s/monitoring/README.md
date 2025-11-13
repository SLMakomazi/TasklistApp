# Kubernetes Monitoring Setup

This directory contains Kubernetes manifests and configurations for monitoring the Tasklist Application.

## Directory Structure

```
k8s/monitoring/
├── jmeter/              # JMeter load testing in Kubernetes
│   └── jmeter-job.yaml  # Kubernetes Job for running JMeter tests
└── README.md            # This file
```

## JMeter Load Testing in Kubernetes

The `jmeter/` directory contains configurations for running JMeter load tests as Kubernetes Jobs.

### Prerequisites

- Kubernetes cluster with kubectl configured
- Sufficient resources for running load tests
- Access to the application from within the cluster

### Running JMeter Tests

1. **Update Test Configuration**:
   - Update `jmeter-job.yaml` with your test parameters
   - Modify the ConfigMap to include your JMX test plans

2. **Deploy the Test Job**:
   ```bash
   kubectl apply -f jmeter/jmeter-job.yaml -n monitoring
   ```

3. **Monitor Test Execution**:
   ```bash
   # List JMeter pods
   kubectl get pods -n monitoring | grep jmeter
   
   # View logs
   kubectl logs -f <jmeter-pod-name> -n monitoring
   ```

4. **Get Test Results**:
   ```bash
   # Find the JMeter pod
   POD_NAME=$(kubectl get pods -n monitoring -l job-name=jmeter-load-test -o jsonpath='{.items[0].metadata.name}')
   
   # Copy results locally
   kubectl cp $POD_NAME:/test/results ./jmeter-results -n monitoring
   ```

### Cleanup

```bash
# Delete the job and related resources
kubectl delete -f jmeter/jmeter-job.yaml -n monitoring
```

## Monitoring Stack

This section will contain configurations for the monitoring stack (Prometheus, Grafana, etc.) as they are added.

## Best Practices

1. **Resource Management**:
   - Set appropriate resource requests and limits for JMeter pods
   - Consider using node selectors to run tests on specific nodes

2. **Security**:
   - Use Kubernetes secrets for sensitive data
   - Implement network policies to restrict pod communication

3. **Test Isolation**:
   - Run tests in a dedicated namespace
   - Clean up completed jobs to free resources

4. **Results Storage**:
   - Consider using persistent volumes for storing test results
   - Archive old test results to object storage

## Troubleshooting

### Common Issues

1. **Pod Pending**:
   ```bash
   # Check pod events
   kubectl describe pod <pod-name> -n monitoring
   
   # Check cluster capacity
   kubectl get nodes -o wide
   kubectl describe nodes
   ```

2. **Test Failures**:
   ```bash
   # Check JMeter logs
   kubectl logs <jmeter-pod-name> -n monitoring
   
   # Check application logs
   kubectl logs -l app=tasklist-app -n <namespace>
   ```
