#!/bin/bash

# Configuration
JMETER_HOME="/opt/apache-jmeter-5.4.1"
TEST_PLAN="test-plans/basic-load-test.jmx"
RESULTS_DIR="results/$(date +'%Y%m%d_%H%M%S')"

# Create results directory
mkdir -p "$RESULTS_DIR"

# Run JMeter test
"$JMETER_HOME/bin/jmeter" -n \
  -t "$TEST_PLAN" \
  -l "$RESULTS_DIR/results.jtl" \
  -e \
  -o "$RESULTS_DIR/dashboard"

echo "Test completed. Results available in $RESULTS_DIR"
