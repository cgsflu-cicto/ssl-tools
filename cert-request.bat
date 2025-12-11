<# :
@echo off & cd /d "%~dp0" & cls
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (gc '%~f0' -Raw)"
pause & exit /b
#>

# check if config.cnf file exists
if (-not (Test-Path "cert-config.cnf")) {
    Write-Host "Error: cert-config.cnf file not found!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# check if request folder exists otherwise create it
if (-not (Test-Path "request")) {
    New-Item -ItemType Directory -Path "request" | Out-Null
}

# check if files already exist
$csrFile = "request/request.csr"
$keyFile = "request/private.key"
if ((Test-Path $csrFile) -or (Test-Path $keyFile)) {
    Write-Host "Warning! The following files already exist:" -ForegroundColor Yellow
    if (Test-Path $csrFile) { Write-Host "  - $csrFile" -ForegroundColor Yellow }
    if (Test-Path $keyFile) { Write-Host "  - $keyFile" -ForegroundColor Yellow }
    
    $response = Read-Host "`nOverwrite existing files? (Y/N)"
    if ($response -ne 'Y' -and $response -ne 'y') {
        Write-Host "Operation cancelled.`n" -ForegroundColor Red
        exit 0
    }
}

# output to request folder
openssl req -new -nodes -out request/request.csr -keyout request/private.key -config cert-config.cnf -verbose
Write-Host "`nCreated request/request.csr" -ForegroundColor Green
Write-Host "Created request/private.key`n" -ForegroundColor Green