<# :
@echo off & cd /d "%~dp0" & cls
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (gc '%~f0' -Raw)"
pause & exit /b
#>

# check for .p7b file
if (-not (Test-Path "*.p7b")) {
    Write-Host "Error: PKCS7 (.p7b) file not found!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# check if converted folder exists otherwise create it
if (-not (Test-Path "converted")) {
    New-Item -ItemType Directory -Path "converted" | Out-Null
}

# get .p7b file
$p7bFile = Get-ChildItem -Filter *.p7b | Select-Object -First 1

# extract CN from the certificate
$subjectLine = openssl pkcs7 -print_certs -in $p7bFile.FullName -noout | Select-String "subject" | Select-Object -First 1
$cnMatch = $subjectLine -match 'CN\s*=\s*([^,]+)'
if ($cnMatch) {
    $baseName = $Matches[1].Trim() -replace '^\*\.', ''
} else {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($p7bFile.Name)
}

$pemFile = "converted\$baseName.fullchain.pem"
$chainFile = "converted\$baseName.chain.pem"
$keyFile = "converted\$baseName.key"

# extract certificates without subject/issuer lines
$tempFile = [System.IO.Path]::GetTempFileName()
openssl pkcs7 -print_certs -in $p7bFile.FullName -out $tempFile

# filter out subject and issuer lines, and empty lines, keep only certificates
$certContent = Get-Content $tempFile | Where-Object { $_ -notmatch '^subject=' -and $_ -notmatch '^issuer=' -and $_.Trim() -ne '' }
$certContent | Out-File $pemFile -Encoding ASCII
Write-Host "Converted $($p7bFile.Name)"
Write-Host "  - $pemFile" -ForegroundColor Green

# create chain.pem (first two certificates)
$certBlocks = ($certContent -join "`n") -split '(?=-----BEGIN CERTIFICATE-----)'
if ($certBlocks.Count -gt 2) {
    ($certBlocks[0..2] -join "`n").Split("`n") | Where-Object { $_.Trim() -ne '' } | Out-File $chainFile -Encoding ASCII
} elseif ($certBlocks.Count -eq 2) {
    ($certBlocks -join "`n").Split("`n") | Where-Object { $_.Trim() -ne '' } | Out-File $chainFile -Encoding ASCII
}
Write-Host "Extracted"
Write-Host "  - $chainFile" -ForegroundColor Green

# check for .key file in request folder and process it
$possibleKeyFiles = Get-ChildItem -Path "request" -Filter "*.key" -ErrorAction SilentlyContinue
if ($possibleKeyFiles) {
    $sourceKey = $possibleKeyFiles | Select-Object -First 1
    openssl rsa -in $sourceKey.FullName -out $keyFile *> $null
    Write-Host "Processed request\$($sourceKey.Name)"
    Write-Host "  - $keyFile" -ForegroundColor Green
}

Remove-Item $tempFile
Write-Host ""