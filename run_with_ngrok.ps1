# PowerShell helper to run the Flask backend and expose it via ngrok.
# Usage:
#   1) Ensure ngrok is installed and authenticated: ngrok config add-authtoken <TOKEN>
#   2) Run this script from the repo root: .\run_with_ngrok.ps1
#   3) Copy the printed public URL (https://<random>.ngrok-free.app) into the Android BASE_URL.

$ErrorActionPreference = "Stop"

# --- Settings ---
$port = 5000
$backendPath = Join-Path $PSScriptRoot "BackEnd\main.py"
$ngrokLogPath = Join-Path $PSScriptRoot "ngrok.log"

# Prefer local venv Python if it exists.
$pythonCmd = "D:\DATN_DACS\V1\Storage DATN\V1\DATN\.venv\Scripts\python.exe"
if (-not (Test-Path $pythonCmd)) {
    throw "Python not found at $pythonCmd"
}

if (-not (Test-Path $backendPath)) {
    throw "Cannot find backend file at $backendPath"
}

$ngrokExe = "C:\Users\hau09\ngrok\ngrok.exe"
if (-not (Test-Path $ngrokExe)) {
    throw "ngrok is not found at $ngrokExe. Please check the path."
}

Write-Host "`n[1/3] Starting Flask backend on port $port..."
$env:PATH = "C:\Program Files\Common Files\microsoft shared\ClickToRun;" + $env:PATH
$flaskProcess = Start-Process -FilePath $pythonCmd -ArgumentList "`"$backendPath`"" -NoNewWindow -PassThru

# Give the server a moment to start.
Start-Sleep -Seconds 3

Write-Host "[2/3] Starting ngrok http $port..."
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
    Write-Host "[3/3] Ngrok public URL (use as BASE_URL in Android): $publicUrl" -ForegroundColor Green
}
else {
    Write-Host "[3/3] Ngrok started. If the URL is not shown, open the local dashboard: http://127.0.0.1:4040" -ForegroundColor Yellow
}

Write-Host "`nPress Ctrl+C to stop. The ngrok log is at $ngrokLogPath`n"

try {
    Wait-Process -Id $flaskProcess.Id, $ngrokProcess.Id
}
finally {
    foreach ($p in @($flaskProcess, $ngrokProcess)) {
        if ($p -and -not $p.HasExited) {
            Stop-Process -Id $p.Id -Force
        }
    }
}
