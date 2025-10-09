#!/bin/bash
# Automated VM deployment script for TasklistApp

set -e  # Exit on any error

echo "🚀 Starting TasklistApp VM deployment..."

# Configuration
JAR_FILE="tasklist-api-*.jar"
APP_DIR="/opt/tasklist/app"
SERVICE_NAME="tasklist"
DOCKER_HOST="192.168.18.3"  # Update this to your actual Docker host IP

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if JAR file exists in /tmp
if [ ! -f "/tmp/$JAR_FILE" ]; then
    print_error "JAR file not found in /tmp/. Please copy your JAR file first:"
    echo "  scp -i /path/to/your-key target/tasklist-api-*.jar user@vm-ip:/tmp/"
    exit 1
fi

print_status "Found JAR file: $(ls /tmp/$JAR_FILE)"

# Stop service if running
print_status "Stopping existing service..."
sudo systemctl stop $SERVICE_NAME 2>/dev/null || print_warning "Service was not running"

# Create application directories if they don't exist
print_status "Creating application directories..."
sudo mkdir -p $APP_DIR
sudo mkdir -p /opt/tasklist/logs

# Copy JAR file
print_status "Deploying application..."
sudo cp /tmp/$JAR_FILE $APP_DIR/tasklist-api.jar
sudo chown tasklist:tasklist $APP_DIR/tasklist-api.jar
sudo chmod 644 $APP_DIR/tasklist-api.jar

# Create or update application.properties
print_status "Creating application configuration..."
sudo tee $APP_DIR/application.properties > /dev/null << EOF
# Database Configuration
spring.datasource.url=jdbc:postgresql://$DOCKER_HOST:5432/tasklistdb
spring.datasource.username=postgres
spring.datasource.password=admin
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# Server Configuration
server.port=8080

# Logging
logging.file.name=/opt/tasklist/logs/tasklist.log
logging.level.com.tasklist=DEBUG
EOF

sudo chown tasklist:tasklist $APP_DIR/application.properties
sudo chmod 644 $APP_DIR/application.properties

# Copy systemd service file if it exists
if [ -f "/tmp/tasklist.service" ]; then
    print_status "Installing systemd service..."
    sudo cp /tmp/tasklist.service /etc/systemd/system/
    sudo chown root:root /etc/systemd/system/tasklist.service
    sudo chmod 644 /etc/systemd/system/tasklist.service
    sudo systemctl daemon-reload
else
    print_warning "Systemd service file not found in /tmp/tasklist.service"
fi

# Start service
print_status "Starting service..."
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME

# Wait a moment and check status
sleep 3
if sudo systemctl is-active --quiet $SERVICE_NAME; then
    print_status "✅ Deployment successful!"
    print_status "🌐 Application available at: http://$(hostname -I | awk '{print $1}'):8080/api/tasks"
    print_status "📚 Swagger UI: http://$(hostname -I | awk '{print $1}'):8080/swagger-ui.html"
else
    print_error "❌ Deployment failed. Check logs:"
    echo "  sudo journalctl -u $SERVICE_NAME -n 50"
    echo "  sudo tail -f /opt/tasklist/logs/tasklist.log"
    exit 1
fi

# Verify database connection
print_status "Verifying database connection..."
if sudo -u tasklist psql -h $DOCKER_HOST -p 5432 -U postgres -d tasklistdb -c "SELECT 1;" 2>/dev/null; then
    print_status "✅ Database connection successful!"
else
    print_warning "⚠️ Database connection failed. Check network connectivity to $DOCKER_HOST:5432"
fi

print_status "🎉 VM deployment completed successfully!"