# dev-up.ps1
# Starts the Shiftley local development stack

$infrastructureDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$dockerDir = Join-Path $infrastructureDir "docker"

Write-Host "🚀 Starting Shiftley Infrastructure..." -ForegroundColor Cyan

# 1. Start containers
Push-Location $dockerDir
docker-compose up -d --build
Pop-Location

Write-Host "`n✅ Services are starting. Checking health..." -ForegroundColor Yellow

# 2. Wait for MinIO buckets to be ready (minio-init exits when done)
Write-Host "⏳ Waiting for MinIO buckets..." -NoNewline
while ($(docker inspect -f '{{.State.Running}}' shiftley-minio-init) -eq "true") {
    Write-Host "." -NoNewline
    Start-Sleep -Seconds 2
}
Write-Host " Ready!" -ForegroundColor Green

# 3. Print URLs
Write-Host "`n🔥 Shiftley Developer Dashboard" -ForegroundColor Cyan
Write-Host "--------------------------------------------------"
Write-Host "Backend API:    http://localhost:8080"
Write-Host "Swagger Docs:   http://localhost:8080/swagger/index.html"
Write-Host "Health Check:   http://localhost:8080/health"
Write-Host "pgAdmin:        http://localhost:5050"
Write-Host "MinIO Console:  http://localhost:9001 (admin/admin123)"
Write-Host "--------------------------------------------------"
Write-Host "Logs: docker-compose -f infrastructure/docker/docker-compose.yml logs -f"
Write-Host "Stop: docker-compose -f infrastructure/docker/docker-compose.yml down"
