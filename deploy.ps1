# DeepLure Research Task - Docker Build and Deploy Script (PowerShell)
# This script builds and deploys the Movable Modal React application

param(
    [string]$Action = "deploy"
)

# Configuration
$IMAGE_NAME = "deeplure/movable-modals"
$CONTAINER_NAME = "deeplure-research-task"
$PORT = "8080"

# Colors for output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Cyan"
}

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Colors.Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Colors.Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Colors.Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Colors.Red
}

Write-Host "🚀 DeepLure Research Task - Movable Modal Application" -ForegroundColor $Colors.Blue
Write-Host "================================================" -ForegroundColor $Colors.Blue
Write-Host ""

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Status "Docker is running ✓"
} catch {
    Write-Error "Docker is not running. Please start Docker Desktop and try again."
    exit 1
}

if ($Action -eq "clean") {
    Write-Status "Cleaning up existing containers and images..."
    docker stop $CONTAINER_NAME 2>$null
    docker rm $CONTAINER_NAME 2>$null
    docker rmi $IMAGE_NAME`:latest 2>$null
    Write-Success "Cleanup completed!"
    exit 0
}

Write-Status "Stopping existing container if running..."
docker stop $CONTAINER_NAME 2>$null | Out-Null
docker rm $CONTAINER_NAME 2>$null | Out-Null

Write-Status "Building Docker image..."
$buildResult = docker build -t $IMAGE_NAME`:latest .

if ($LASTEXITCODE -eq 0) {
    Write-Success "Docker image built successfully!"
} else {
    Write-Error "Failed to build Docker image"
    exit 1
}

Write-Status "Running container..."
$runResult = docker run -d --name $CONTAINER_NAME -p $PORT`:80 --restart unless-stopped $IMAGE_NAME`:latest

if ($LASTEXITCODE -eq 0) {
    Write-Success "Container started successfully!"
    Write-Host ""
    Write-Host "🎉 DeepLure Research Task is now running!" -ForegroundColor $Colors.Green
    Write-Host "📱 Application URL: http://localhost:$PORT" -ForegroundColor $Colors.Blue
    Write-Host "📦 Download dist.tar.gz: http://localhost:$PORT/dist.tar.gz" -ForegroundColor $Colors.Blue
    Write-Host "🔍 Health Check: http://localhost:$PORT/health" -ForegroundColor $Colors.Blue
    Write-Host ""
    Write-Host "🛠️ Container Management:" -ForegroundColor $Colors.Yellow
    Write-Host "   Stop:    docker stop $CONTAINER_NAME"
    Write-Host "   Restart: docker restart $CONTAINER_NAME"
    Write-Host "   Logs:    docker logs $CONTAINER_NAME"
    Write-Host "   Remove:  docker rm -f $CONTAINER_NAME"
    Write-Host ""
    
    # Wait a moment for container to fully start
    Start-Sleep -Seconds 3
    
    # Test the health endpoint
    Write-Status "Testing application health..."
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$PORT/health" -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Success "Application is healthy and ready!"
        }
    } catch {
        Write-Warning "Application may still be starting up..."
    }
    
} else {
    Write-Error "Failed to start container"
    exit 1
}

Write-Host ""
Write-Host "✨ Deployment completed successfully!" -ForegroundColor $Colors.Green
Write-Host "🎯 Ready for DeepLure Research Task submission!" -ForegroundColor $Colors.Green

# Optional: Open browser
$openBrowser = Read-Host "Would you like to open the application in your browser? (y/N)"
if ($openBrowser -match "^[Yy]") {
    Start-Process "http://localhost:$PORT"
}