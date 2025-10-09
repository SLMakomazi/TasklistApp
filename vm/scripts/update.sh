#!/bin/bash
# Application update script

JAR_URL="http://your-jenkins-server/job/lastSuccessfulBuild/artifact/target/tasklist-api.jar"
BACKUP_DIR="/opt/tasklist/backup"

echo "🔄 Updating TasklistApp..."

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup current JAR
cp /opt/tasklist/app/tasklist-api.jar $BACKUP_DIR/tasklist-api-$(date +%Y%m%d_%H%M%S).jar

# Download latest JAR
wget -O /tmp/tasklist-api.jar $JAR_URL

# Deploy new version
mv /tmp/tasklist-api.jar /opt/tasklist/app/

# Restart service
systemctl restart tasklist

# Check status
if systemctl is-active --quiet tasklist; then
    echo "✅ Update completed successfully!"
else
    echo "❌ Update failed. Rolling back..."
    cp $BACKUP_DIR/$(ls -t $BACKUP_DIR/ | head -1) /opt/tasklist/app/tasklist-api.jar
    systemctl restart tasklist
fi