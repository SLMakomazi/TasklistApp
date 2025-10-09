#!/bin/bash
# Initial VM setup script for TasklistApp

set -e  # Exit on any error

echo "🔧 Setting up VM for TasklistApp deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Update package index
print_status "Updating package index..."
sudo apt update

# Install Java 17
print_status "Installing Java 17..."
sudo apt install -y openjdk-17-jdk

# Verify Java installation
print_status "Verifying Java installation..."
java -version

# Create tasklist user
print_status "Creating tasklist user..."
sudo useradd -r -s /bin/false tasklist

# Create application directories
print_status "Creating application directories..."
sudo mkdir -p /opt/tasklist/app
sudo mkdir -p /opt/tasklist/logs
sudo mkdir -p /opt/tasklist/scripts

# Set ownership and permissions
print_status "Setting permissions..."
sudo chown -R tasklist:tasklist /opt/tasklist
sudo chmod 755 /opt/tasklist
sudo chmod 755 /opt/tasklist/app
sudo chmod 755 /opt/tasklist/logs
sudo chmod 755 /opt/tasklist/scripts

# Install PostgreSQL client for database testing
print_status "Installing PostgreSQL client..."
sudo apt install -y postgresql-client

print_status "✅ VM setup completed successfully!"
print_status ""
print_status "Next steps:"
echo "1. Copy your JAR file: scp target/tasklist-api-*.jar user@vm-ip:/tmp/"
echo "2. Run deployment: ./vm/deploy.sh"
echo "3. Verify deployment: curl http://vm-ip:8080/api/tasks"
#!/bin/bash
# Initial VM setup script for TasklistApp

set -e  # Exit on any error

echo "🔧 Setting up VM for TasklistApp deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Update package index
print_status "Updating package index..."
sudo apt update

# Install Java 17
print_status "Installing Java 17..."
sudo apt install -y openjdk-17-jdk

# Verify Java installation
print_status "Verifying Java installation..."
java -version

# Create tasklist user
print_status "Creating tasklist user..."
# -r creates a system user, -s /bin/false denies shell login access
if ! id "tasklist" &>/dev/null; then
    sudo useradd -r -s /bin/false tasklist
    print_status "'tasklist' system user created."
else
    print_warning "'tasklist' system user already exists. Skipping creation."
fi


# Create application directories
print_status "Creating application directories..."
sudo mkdir -p /opt/tasklist/app
sudo mkdir -p /opt/tasklist/logs
sudo mkdir -p /opt/tasklist/scripts

# Set ownership and permissions
print_status "Setting permissions..."
sudo chown -R tasklist:tasklist /opt/tasklist
sudo chmod 755 /opt/tasklist
sudo chmod 755 /opt/tasklist/app
sudo chmod 755 /opt/tasklist/logs
sudo chmod 755 /opt/tasklist/scripts

# Install PostgreSQL client for database testing
print_status "Installing PostgreSQL client..."
sudo apt install -y postgresql-client

print_status "✅ VM setup completed successfully!"
print_status ""
print_status "Next steps:"
echo "1. Copy your JAR file: scp target/tasklist-api-*.jar user@vm-ip:/tmp/"
echo "2. Run deployment: /tmp/deploy.sh (once copied)"
echo "3. Verify deployment: curl http://vm-ip:8080/api/tasks"
