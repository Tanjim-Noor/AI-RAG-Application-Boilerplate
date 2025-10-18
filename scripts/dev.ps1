# Development Commands for AI Boilerplate
# This script provides PowerShell alternatives to Makefile commands

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('help', 'setup', 'dev', 'test', 'lint', 'format', 'clean', 'reset-db')]
    [string]$Command = 'help'
)

# Get script directory and navigate to project root
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptPath
Set-Location $projectRoot

function Show-Help {
    Write-Host "`nAI Boilerplate - Available Commands" -ForegroundColor Cyan
    Write-Host "====================================`n" -ForegroundColor Cyan
    Write-Host "Usage: .\scripts\dev.ps1 <command>`n"
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  help      - Display this help message"
    Write-Host "  setup     - Run initial project setup"
    Write-Host "  dev       - Start development servers (frontend + backend)"
    Write-Host "  test      - Run all tests"
    Write-Host "  lint      - Run linters"
    Write-Host "  format    - Format code"
    Write-Host "  clean     - Clean build artifacts and volumes"
    Write-Host "  reset-db  - Reset database (WARNING: deletes all data)"
    Write-Host "`nExamples:" -ForegroundColor Yellow
    Write-Host "  .\scripts\dev.ps1 setup"
    Write-Host "  .\scripts\dev.ps1 dev"
    Write-Host "  .\scripts\dev.ps1 test"
}

function Start-Setup {
    Write-Host "Running setup..." -ForegroundColor Green
    & "$projectRoot\scripts\setup.ps1"
}

function Start-Dev {
    Write-Host "Starting development environment..." -ForegroundColor Green
    
    # Start PostgreSQL
    Write-Host "`nStarting PostgreSQL..." -ForegroundColor Cyan
    Set-Location docker
    docker-compose up -d
    Set-Location ..
    
    # Wait a moment for database to start
    Start-Sleep -Seconds 2
    
    # Start development servers
    Write-Host "`nStarting frontend and backend..." -ForegroundColor Cyan
    Write-Host "Frontend will be at: http://localhost:5173" -ForegroundColor Yellow
    Write-Host "Backend will be at: http://localhost:8000" -ForegroundColor Yellow
    Write-Host "API Docs will be at: http://localhost:8000/docs" -ForegroundColor Yellow
    Write-Host "`nPress Ctrl+C to stop all services`n" -ForegroundColor Yellow
    
    pnpm dev
}

function Start-Test {
    Write-Host "Running tests..." -ForegroundColor Green
    pnpm test
}

function Start-Lint {
    Write-Host "Running linters..." -ForegroundColor Green
    pnpm lint
}

function Start-Format {
    Write-Host "Formatting code..." -ForegroundColor Green
    pnpm format
}

function Start-Clean {
    Write-Host "Cleaning build artifacts..." -ForegroundColor Green
    pnpm clean
    
    Write-Host "Stopping and removing Docker volumes..." -ForegroundColor Cyan
    Set-Location docker
    docker-compose down -v
    Set-Location ..
    
    Write-Host "Clean complete!" -ForegroundColor Green
}

function Start-ResetDb {
    & "$projectRoot\scripts\reset-db.ps1"
}

# Execute command
switch ($Command) {
    'help' { Show-Help }
    'setup' { Start-Setup }
    'dev' { Start-Dev }
    'test' { Start-Test }
    'lint' { Start-Lint }
    'format' { Start-Format }
    'clean' { Start-Clean }
    'reset-db' { Start-ResetDb }
}
