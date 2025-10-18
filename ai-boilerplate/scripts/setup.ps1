# AI Boilerplate Setup Script
# Get the script's directory and navigate to project root
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptPath
Set-Location $projectRoot

Write-Host "Setting up AI RAG Boilerplate..." -ForegroundColor Green

# Check for required tools
Write-Host "`nChecking prerequisites..." -ForegroundColor Cyan

# Check Docker
$dockerCheck = Get-Command docker -ErrorAction SilentlyContinue
if ($dockerCheck) {
    Write-Host "Docker is installed" -ForegroundColor Green
} else {
    Write-Host "Docker is not installed. Please install Docker Desktop." -ForegroundColor Red
    exit 1
}

# Check pnpm
$pnpmCheck = Get-Command pnpm -ErrorAction SilentlyContinue
if ($pnpmCheck) {
    Write-Host "pnpm is installed" -ForegroundColor Green
} else {
    Write-Host "pnpm is not installed. Installing pnpm..." -ForegroundColor Yellow
    npm install -g pnpm
}

# Check Python
$pythonCheck = Get-Command python -ErrorAction SilentlyContinue
if ($pythonCheck) {
    Write-Host "Python is installed" -ForegroundColor Green
} else {
    Write-Host "Python is not installed. Please install Python 3.10+." -ForegroundColor Red
    exit 1
}

# Copy .env.example to .env if not exists
Write-Host "`nSetting up environment variables..." -ForegroundColor Cyan
if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "Created .env file from .env.example" -ForegroundColor Green
    Write-Host "Please update API keys in .env file" -ForegroundColor Yellow
} else {
    Write-Host ".env file already exists" -ForegroundColor Green
}

# Install root dependencies
Write-Host "`nInstalling root dependencies..." -ForegroundColor Cyan
pnpm install

# Create Python virtual environment
Write-Host "`nSetting up Python virtual environment..." -ForegroundColor Cyan
Set-Location apps/backend
if (-not (Test-Path "venv")) {
    python -m venv venv
    Write-Host "Created virtual environment" -ForegroundColor Green
} else {
    Write-Host "Virtual environment already exists" -ForegroundColor Green
}

# Activate venv and install requirements
Write-Host "Installing Python dependencies..." -ForegroundColor Cyan
& .\venv\Scripts\Activate.ps1
pip install --upgrade pip
pip install -r requirements.txt
deactivate
Set-Location ../..

# Start PostgreSQL
Write-Host "`nStarting PostgreSQL..." -ForegroundColor Cyan
Set-Location docker
docker-compose up -d
Set-Location ..

# Wait for database to be healthy
Write-Host "Waiting for database to be ready..." -ForegroundColor Cyan
$maxAttempts = 30
$attempt = 0
while ($attempt -lt $maxAttempts) {
    $health = docker inspect --format "{{.State.Health.Status}}" ai-boilerplate-db 2>$null
    if ($health -eq "healthy") {
        Write-Host "Database is ready" -ForegroundColor Green
        break
    }
    Start-Sleep -Seconds 1
    $attempt++
}

if ($attempt -eq $maxAttempts) {
    Write-Host "Database failed to start" -ForegroundColor Red
    exit 1
}

Write-Host "`nSetup complete!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Update API keys in .env file"
Write-Host "2. Run 'make dev' or 'pnpm dev' to start the development servers"
Write-Host "3. Frontend: http://localhost:5173"
Write-Host "4. Backend: http://localhost:8000"
Write-Host "5. API Docs: http://localhost:8000/docs"
