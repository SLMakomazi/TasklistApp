#!/bin/bash

# Exit on error
set -e


# Update packages
sudo apt-get update

# Install required packages
sudo apt-get install -y \
    curl \
    docker.io \
    docker-compose \
    jq \
    unzip

# Create a directory for the runner
RUNNER_DIR="$HOME/actions-runner"
mkdir -p $RUNNER_DIR
cd $RUNNER_DIR

# Download the latest runner package
RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name' | cut -d'v' -f2)
RUNNER_PACKAGE="actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"

curl -o $RUNNER_PACKAGE -L "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
tar xzf "./$RUNNER_PACKAGE"

# Install dependencies
sudo ./bin/installdependencies.sh

# Create a systemd service for the runner
cat > actions-runner.service << EOL
[Unit]
Description=GitHub Actions Runner
After=network.target

[Service]
ExecStart=$RUNNER_DIR/run.sh
User=siseko
WorkingDirectory=$RUNNER_DIR
KillMode=process
KillSignal=SIGTERM
TimeoutStopSec=5min

[Install]
WantedBy=multi-user.target
EOL

# Move the service file to systemd directory
sudo mv actions-runner.service /etc/systemd/system/
sudo systemctl daemon-reload

echo "GitHub Actions runner setup complete!"
echo "1. Run 'cd $RUNNER_DIR'"
echo "2. Run './config.sh --url https://github.com/slmakomazi/TasklistApp --token <RUNNER_TOKEN>'"
echo "3. Run 'sudo systemctl enable actions-runner.service'"
echo "4. Run 'sudo systemctl start actions-runner.service'"
echo "Make sure to replace <RUNNER_TOKEN> with a valid runner token from your GitHub repository settings."
