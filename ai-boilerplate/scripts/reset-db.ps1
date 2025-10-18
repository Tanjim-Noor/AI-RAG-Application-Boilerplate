# Database Reset Script
Write-Host "⚠️  This will delete all database data!" -ForegroundColor Yellow
$confirmation = Read-Host "Are you sure you want to reset the database? (yes/no)"

if ($confirmation -ne "yes") {
    Write-Host "❌ Database reset cancelled" -ForegroundColor Red
    exit 0
}

Write-Host "`n🗑️  Resetting database..." -ForegroundColor Cyan

# Stop and remove container
Set-Location docker
docker-compose down -v
Write-Host "✓ Removed database container and volume" -ForegroundColor Green

# Start fresh database
Write-Host "`n🐘 Starting fresh PostgreSQL instance..." -ForegroundColor Cyan
docker-compose up -d

# Wait for database
Write-Host "⏳ Waiting for database to be ready..." -ForegroundColor Cyan
$maxAttempts = 30
$attempt = 0
while ($attempt -lt $maxAttempts) {
    $health = docker inspect --format='{{.State.Health.Status}}' ai-boilerplate-db 2>$null
    if ($health -eq "healthy") {
        Write-Host "✓ Database is ready" -ForegroundColor Green
        break
    }
    Start-Sleep -Seconds 1
    $attempt++
}

Set-Location ..

if ($attempt -eq $maxAttempts) {
    Write-Host "✗ Database failed to start" -ForegroundColor Red
    exit 1
}

# Run migrations (placeholder for now)
Write-Host "`n📊 Running migrations..." -ForegroundColor Cyan
Write-Host "ℹ️  Migrations will be configured in Phase 1" -ForegroundColor Yellow

Write-Host "`n✅ Database reset complete!" -ForegroundColor Green
