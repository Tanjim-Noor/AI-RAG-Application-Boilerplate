# Phase 0 Validation Script
Write-Host "`n=== Phase 0 Validation ===" -ForegroundColor Cyan

$allPassed = $true

# Test 1: Check if pnpm install succeeded
Write-Host "`nTest 1: Root dependencies installed" -ForegroundColor Yellow
if (Test-Path "node_modules") {
    Write-Host "✓ PASS: node_modules exists" -ForegroundColor Green
} else {
    Write-Host "✗ FAIL: node_modules not found" -ForegroundColor Red
    $allPassed = $false
}

# Test 2: Check if backend venv exists
Write-Host "`nTest 2: Python virtual environment created" -ForegroundColor Yellow
if (Test-Path "apps/backend/venv") {
    Write-Host "✓ PASS: Python venv exists" -ForegroundColor Green
} else {
    Write-Host "✗ FAIL: Python venv not found" -ForegroundColor Red
    $allPassed = $false
}

# Test 3: Check if .env was created
Write-Host "`nTest 3: Environment file created" -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "✓ PASS: .env file exists" -ForegroundColor Green
} else {
    Write-Host "✗ FAIL: .env file not found" -ForegroundColor Red
    $allPassed = $false
}

# Test 4: Check Docker container
Write-Host "`nTest 4: PostgreSQL container running" -ForegroundColor Yellow
$container = docker ps --filter "name=ai-boilerplate-db" --format "{{.Names}}" 2>$null
if ($container -eq "ai-boilerplate-db") {
    $health = docker inspect --format "{{.State.Health.Status}}" ai-boilerplate-db 2>$null
    if ($health -eq "healthy") {
        Write-Host "✓ PASS: Database is running and healthy" -ForegroundColor Green
    } else {
        Write-Host "⚠ WARNING: Database running but not healthy (status: $health)" -ForegroundColor Yellow
    }
} else {
    Write-Host "✗ FAIL: Database container not running" -ForegroundColor Red
    $allPassed = $false
}

# Test 5: Check frontend files
Write-Host "`nTest 5: Frontend structure" -ForegroundColor Yellow
$frontendFiles = @(
    "apps/frontend/package.json",
    "apps/frontend/vite.config.ts",
    "apps/frontend/tsconfig.json",
    "apps/frontend/src/main.tsx",
    "apps/frontend/src/App.tsx"
)
$allFrontendExists = $true
foreach ($file in $frontendFiles) {
    if (-not (Test-Path $file)) {
        Write-Host "✗ Missing: $file" -ForegroundColor Red
        $allFrontendExists = $false
        $allPassed = $false
    }
}
if ($allFrontendExists) {
    Write-Host "✓ PASS: All frontend files exist" -ForegroundColor Green
}

# Test 6: Check backend files
Write-Host "`nTest 6: Backend structure" -ForegroundColor Yellow
$backendFiles = @(
    "apps/backend/package.json",
    "apps/backend/requirements.txt",
    "apps/backend/app/main.py",
    "apps/backend/pyproject.toml"
)
$allBackendExists = $true
foreach ($file in $backendFiles) {
    if (-not (Test-Path $file)) {
        Write-Host "✗ Missing: $file" -ForegroundColor Red
        $allBackendExists = $false
        $allPassed = $false
    }
}
if ($allBackendExists) {
    Write-Host "✓ PASS: All backend files exist" -ForegroundColor Green
}

# Test 7: Check configuration files
Write-Host "`nTest 7: Configuration files" -ForegroundColor Yellow
$configFiles = @(
    "turbo.json",
    "pnpm-workspace.yaml",
    "Makefile",
    ".gitignore",
    ".prettierrc"
)
$allConfigExists = $true
foreach ($file in $configFiles) {
    if (-not (Test-Path $file)) {
        Write-Host "✗ Missing: $file" -ForegroundColor Red
        $allConfigExists = $false
        $allPassed = $false
    }
}
if ($allConfigExists) {
    Write-Host "✓ PASS: All config files exist" -ForegroundColor Green
}

# Summary
Write-Host "`n=== Validation Summary ===" -ForegroundColor Cyan
if ($allPassed) {
    Write-Host "✓ ALL TESTS PASSED!" -ForegroundColor Green
    Write-Host "`nPhase 0 setup is complete and validated." -ForegroundColor Green
    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "1. Update API keys in .env file"
    Write-Host "2. Run 'make dev' or 'pnpm dev' to start development servers"
    Write-Host "3. Access frontend at http://localhost:5173"
    Write-Host "4. Access backend at http://localhost:8000"
} else {
    Write-Host "✗ SOME TESTS FAILED" -ForegroundColor Red
    Write-Host "`nPlease review the failures above and re-run setup if needed." -ForegroundColor Yellow
}
