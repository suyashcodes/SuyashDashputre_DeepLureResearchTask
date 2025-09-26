#!/bin/bash

# DeepLure Research Task - Docker Build and Deploy Script
# This script builds and deploys the Movable Modal React application

set -e

echo "🚀 DeepLure Research Task - Movable Modal Application"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="deeplure/movable-modals"
CONTAINER_NAME="deeplure-research-task"
PORT="8080"

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

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

print_status "Stopping existing container if running..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

print_status "Building Docker image..."
docker build -t $IMAGE_NAME:latest .

if [ $? -eq 0 ]; then
    print_success "Docker image built successfully!"
else
    print_error "Failed to build Docker image"
    exit 1
fi

print_status "Running container..."
docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:80 \
    --restart unless-stopped \
    $IMAGE_NAME:latest

if [ $? -eq 0 ]; then
    print_success "Container started successfully!"
    echo ""
    echo "🎉 DeepLure Research Task is now running!"
    echo "📱 Application URL: http://localhost:$PORT"
    echo "📦 Download dist.tar.gz: http://localhost:$PORT/dist.tar.gz"
    echo "🔍 Health Check: http://localhost:$PORT/health"
    echo ""
    echo "🛠️ Container Management:"
    echo "   Stop:    docker stop $CONTAINER_NAME"
    echo "   Restart: docker restart $CONTAINER_NAME"
    echo "   Logs:    docker logs $CONTAINER_NAME"
    echo "   Remove:  docker rm -f $CONTAINER_NAME"
    echo ""
    
    # Wait a moment for container to fully start
    sleep 3
    
    # Test the health endpoint
    print_status "Testing application health..."
    if curl -f http://localhost:$PORT/health > /dev/null 2>&1; then
        print_success "Application is healthy and ready!"
    else
        print_warning "Application may still be starting up..."
    fi
    
else
    print_error "Failed to start container"
    exit 1
fi

echo ""
echo "✨ Deployment completed successfully!"
echo "🎯 Ready for DeepLure Research Task submission!"