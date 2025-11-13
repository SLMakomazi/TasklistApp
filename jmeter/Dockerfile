FROM alpine/jmeter:5.4.1

# Copy test plans and data
COPY test-plans/ /test/
COPY data/ /test/data/

# Create results directory
RUN mkdir -p /test/results

# Set working directory
WORKDIR /test

# Default command to run JMeter test plan
ENTRYPOINT ["jmeter", "-n", "-t", "/test/basic-load-test.jmx", "-l", "/test/results/results.jtl", "-e", "-o", "/test/results/dashboard"]
