# JMeter Load Testing

This directory contains JMeter test plans and configurations for load testing the Tasklist Application.

## Directory Structure

```
jmeter/
├── test-plans/      # JMeter .jmx test plans
├── data/            # Test data files (CSV, JSON, etc.)
├── results/         # Test execution results (gitignored)
├── Dockerfile       # Container configuration for JMeter
└── run-test.sh      # Helper script to run tests on VM
```

## Prerequisites

- Java 8 or higher
- Apache JMeter 5.4.1 (or compatible version)
- Docker (for containerized execution)
- kubectl (for Kubernetes execution)

## Running Tests Locally

1. **Install JMeter**:
   ```bash
   # On Ubuntu/Debian
   sudo apt-get update && sudo apt-get install -y jmeter
   ```

2. **Run a test plan**:
   ```bash
   # Make the script executable
   chmod +x run-test.sh
   
   # Run the test
   ./run-test.sh
   ```

## Running in Docker

1. **Build the JMeter image**:
   ```bash
   docker build -t tasklist-jmeter .
   ```

2. **Run a test**:
   ```bash
   docker run --rm \
     -v $(pwd)/test-plans:/test \
     -v $(pwd)/results:/test/results \
     tasklist-jmeter
   ```

## Test Results

Test results are saved in the `results/` directory with timestamps. Each test run creates:
- `results_<timestamp>/results.jtl` - Raw test results
- `results_<timestamp>/dashboard/` - HTML report dashboard

## Customizing Tests

1. Edit test plans in `test-plans/` using JMeter GUI
2. Add test data to `data/`
3. Update `run-test.sh` with any additional JMeter parameters

## Best Practices

- Keep test plans version controlled
- Use variables for environment-specific configurations
- Store large test data files in `data/` directory
- Add meaningful test plan and thread group names
- Include assertions to validate responses
