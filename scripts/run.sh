#!/bin/bash

# GitHub Actions Runner Entry Script
# This script starts the runner and handles graceful shutdown

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Runner directory
RUNNER_DIR="/opt/actions-runner"

# Function to cleanup on exit
cleanup() {
    print_status "Shutting down runner..."
    if [ -f "$RUNNER_DIR/run.sh" ]; then
        cd "$RUNNER_DIR"
        ./config.sh remove --token $(curl -sX POST -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$GITHUB_REPOSITORY/actions/runners/remove-token | jq -r .token) || true
    fi
    print_success "Runner shutdown complete"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Main execution
main() {
    print_status "Starting GitHub Actions runner..."
    
    # Check if runner directory exists
    if [ ! -d "$RUNNER_DIR" ]; then
        print_error "Runner directory not found: $RUNNER_DIR"
        exit 1
    fi
    
    # Change to runner directory
    cd "$RUNNER_DIR"
    
    # Check if runner is configured
    if [ ! -f ".runner" ]; then
        print_error "Runner not configured. Please run the configuration script first."
        exit 1
    fi
    
    # Start the runner
    print_status "Starting runner listener..."
    ./run.sh
    
    print_success "Runner started successfully"
}

# Run main function
main "$@"
