$Port   = 8085
$Folder = $PSScriptRoot
if (-not $Folder) { $Folder = Get-Location }
$UIFile = Join-Path $Folder "dissertation-ui-V2.html"
$URL    = "http://localhost:$Port/dissertation-ui-V2.html"

if (-not (Test-Path $UIFile)) {
    Write-Host "ERROR: dissertation-ui-V2.html not found in $Folder" -ForegroundColor Red
    exit 1
}

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   Dissertation Supervisor AI - UI Server" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Serving from : $Folder" -ForegroundColor Gray
Write-Host "Open this URL: $URL" -ForegroundColor Green
Write-Host ""
Write-Host "Press Ctrl+C to stop the server." -ForegroundColor Gray
Write-Host ""

Start-Process $URL
python -m http.server $Port --directory $Folder

