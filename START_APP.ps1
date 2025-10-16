# Bookaro Startup Script
# Run this to start both backend and frontend

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   BOOKARO STARTUP" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if backend JAR exists
if (-not (Test-Path "D:\Springboard\backend\target\bookaro-backend-1.0.3.jar")) {
    Write-Host "ERROR: Backend JAR not found!" -ForegroundColor Red
    Write-Host "Building backend..." -ForegroundColor Yellow
    cd D:\Springboard\backend
    mvn clean package -DskipTests
}

Write-Host "[1/2] Starting Backend..." -ForegroundColor Cyan
Start-Process pwsh -ArgumentList "-NoExit", "-Command", @"
    cd D:\Springboard\backend
    Write-Host 'BACKEND SERVER - v1.0.3' -ForegroundColor Green
    Write-Host 'Port: 8081' -ForegroundColor Cyan
    Write-Host 'Keep this terminal open' -ForegroundColor Yellow
    java -jar target/bookaro-backend-1.0.3.jar
"@

Write-Host "Waiting for backend to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host "[2/2] Starting Frontend..." -ForegroundColor Cyan
Start-Process pwsh -ArgumentList "-NoExit", "-Command", @"
    cd D:\Springboard\frontend
    Write-Host 'FRONTEND SERVER - React App' -ForegroundColor Green
    Write-Host 'Port: 3000' -ForegroundColor Cyan
    Write-Host 'Keep this terminal open' -ForegroundColor Yellow
    npm start
"@

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "STARTUP COMPLETE!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Backend:  http://localhost:8081/api/v1" -ForegroundColor White
Write-Host "Frontend: http://localhost:3000" -ForegroundColor White
Write-Host "`nTest Credentials:" -ForegroundColor Yellow
Write-Host "  Email:    user@bookaro.com" -ForegroundColor White
Write-Host "  Password: password123" -ForegroundColor White
Write-Host "`n========================================`n" -ForegroundColor Cyan
