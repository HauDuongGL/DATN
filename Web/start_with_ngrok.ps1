# PowerShell script to run Next.js Web app and expose it via ngrok
# Usage:
#   1) Ensure ngrok is installed and authenticated: ngrok config add-authtoken <TOKEN>
#   2) Run this script from the Web directory: cd Web; .\start_with_ngrok.ps1
#   3) Copy the printed public URL and update it in:
#      app/src/main/java/com/example/floweridentifier/utils/Constants.kt (WEB_SHARE_URL)

$ErrorActionPreference = "Stop"

# --- Settings ---
$port = 3000
$webPath = Join-Path $PSScriptRoot "."
$ngrokLogPath = Join-Path $PSScriptRoot "ngrok_web.log"

# Check if node_modules exists
if (-not (Test-Path (Join-Path $webPath "node_modules"))) {
    Write-Host "[WARNING] node_modules not found. Installing dependencies..." -ForegroundColor Yellow
    Set-Location $webPath
    npm install
}

$ngrokExe = "C:\Users\hau09\ngrok\ngrok.exe"
if (-not (Test-Path $ngrokExe)) {
    throw "ngrok is not found at $ngrokExe. Please check the path."
}

Write-Host "`n[1/3] Starting Next.js Web app on port $port..." -ForegroundColor Yellow
Set-Location $webPath
$nextProcess = Start-Process -FilePath "npm" -ArgumentList "run", "dev" -NoNewWindow -PassThru

# Give the server a moment to start.
Start-Sleep -Seconds 5

Write-Host "[2/3] Starting ngrok http $port..." -ForegroundColor Yellow
$ngrokArgs = @("http", "$port", "--log=stdout")
$ngrokProcess = Start-Process -FilePath $ngrokExe -ArgumentList $ngrokArgs -NoNewWindow -RedirectStandardOutput $ngrokLogPath -PassThru

# Wait for ngrok to come up, then query its local API for the public URL.
Start-Sleep -Seconds 3
$publicUrl = $null
try {
    $tunnelInfo = Invoke-RestMethod -Uri "http://127.0.0.1:4040/api/tunnels" -ErrorAction Stop
    $publicUrl = ($tunnelInfo.tunnels | Where-Object { $_.proto -eq "https" } | Select-Object -First 1 -ExpandProperty public_url)
}
catch {
    Write-Warning "Could not query ngrok API automatically. Check $ngrokLogPath or the ngrok console output."
}

if ($publicUrl) {
    $webShareUrl = "$publicUrl/upload"
    Write-Host ""
    Write-Host "==================================" -ForegroundColor Green
    Write-Host "✅ Web App Started Successfully!" -ForegroundColor Green
    Write-Host "==================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next.js Web App: http://localhost:$port" -ForegroundColor Cyan
    Write-Host "Ngrok URL:        $publicUrl" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📝 Update WEB_SHARE_URL in:" -ForegroundColor Yellow
    Write-Host "   app/src/main/java/com/example/floweridentifier/utils/Constants.kt" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Change this line:" -ForegroundColor Yellow
    Write-Host "   const val WEB_SHARE_URL = \"$webShareUrl\"" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "[3/3] Ngrok started. If the URL is not shown, open the local dashboard: http://127.0.0.1:4040" -ForegroundColor Yellow
}

Write-Host "Press Ctrl+C to stop. The ngrok log is at $ngrokLogPath`n" -ForegroundColor Red

try {
    Wait-Process -Id $nextProcess.Id, $ngrokProcess.Id
}
finally {
    foreach ($p in @($nextProcess, $ngrokProcess)) {
        if ($p -and -not $p.HasExited) {
            Stop-Process -Id $p.Id -Force
        }
    }
    Write-Host "All services stopped." -ForegroundColor Green
}
