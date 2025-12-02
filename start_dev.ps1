# Script để chạy Flask Backend + Ngrok cùng lúc
# Sử dụng: .\start_dev.ps1

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Starting Flask Backend + Ngrok" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Kiểm tra virtual environment
if (Test-Path ".venv\Scripts\Activate.ps1") {
    Write-Host "[1/4] Activating virtual environment..." -ForegroundColor Yellow
    & .venv\Scripts\Activate.ps1
} else {
    Write-Host "[WARNING] Virtual environment not found at .venv\" -ForegroundColor Red
    Write-Host "Continuing without venv..." -ForegroundColor Yellow
}

Write-Host "[2/4] Starting Flask Backend..." -ForegroundColor Yellow
# Start Flask in background
$flaskJob = Start-Job -ScriptBlock {
    param($rootPath)
    Set-Location $rootPath
    & .venv\Scripts\Activate.ps1
    Set-Location BackEnd
    python main.py
} -ArgumentList $PWD

Start-Sleep -Seconds 3

Write-Host "[3/4] Starting Ngrok tunnel..." -ForegroundColor Yellow
# Start Ngrok in background
$ngrokJob = Start-Job -ScriptBlock {
    ngrok http 5000
}

Start-Sleep -Seconds 2

Write-Host "[4/4] Getting Ngrok URL..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

try {
    $response = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -ErrorAction Stop
    $ngrokUrl = $response.tunnels[0].public_url
    
    Write-Host ""
    Write-Host "==================================" -ForegroundColor Green
    Write-Host "✅ Services Started Successfully!" -ForegroundColor Green
    Write-Host "==================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Flask Backend: http://localhost:5000" -ForegroundColor Cyan
    Write-Host "Ngrok URL:     $ngrokUrl" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📝 Update this URL in:" -ForegroundColor Yellow
    Write-Host "   app/src/main/java/com/example/floweridentifier/utils/Constants.kt" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Press Ctrl+C to stop all services" -ForegroundColor Red
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "⚠️  Could not get Ngrok URL. Check http://localhost:4040" -ForegroundColor Yellow
    Write-Host ""
}

# Keep script running and monitor jobs
try {
    while ($true) {
        Start-Sleep -Seconds 1
        
        # Check if jobs are still running
        if ($flaskJob.State -ne "Running") {
            Write-Host ""
            Write-Host "❌ Flask Backend stopped!" -ForegroundColor Red
            break
        }
        if ($ngrokJob.State -ne "Running") {
            Write-Host ""
            Write-Host "❌ Ngrok stopped!" -ForegroundColor Red
            break
        }
    }
} finally {
    Write-Host ""
    Write-Host "Stopping services..." -ForegroundColor Yellow
    Stop-Job -Job $flaskJob, $ngrokJob -ErrorAction SilentlyContinue
    Remove-Job -Job $flaskJob, $ngrokJob -ErrorAction SilentlyContinue
    Write-Host "All services stopped." -ForegroundColor Green
}
