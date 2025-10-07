# Update Service with All Cookie Files
# Run this script whenever you add or remove cookie files

$ServiceName = "FacebookMessengerBot"
$NSSMPath = "C:\Users\Administrator\Downloads\realchatapp\nssm-2.24\win64\nssm.exe"
$PythonPath = "C:\Users\Administrator\AppData\Local\Programs\Python\Python312\python.exe"
$ScriptPath = "C:\Users\Administrator\Downloads\realchatapp\messenger_playwright_multi.py"
$WorkingDir = "C:\Users\Administrator\Downloads\realchatapp"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "UPDATE SERVICE COOKIE FILES" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Find all cookie files (exclude image_tracking and image_analysis_cache)
$CookieFiles = Get-ChildItem "$WorkingDir\facebook_cookies*.json" | 
    Where-Object {$_.Name -notmatch "image_tracking|image_analysis"} | 
    Select-Object -ExpandProperty Name

if ($CookieFiles.Count -eq 0) {
    Write-Host "ERROR: No cookie files found!" -ForegroundColor Red
    pause
    exit 1
}

Write-Host "Found $($CookieFiles.Count) cookie file(s):" -ForegroundColor Green
$CookieFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }
Write-Host ""

# Build the command arguments
$CookieArgs = $CookieFiles -join " "
$FullArgs = "`"$ScriptPath`" --cookies $CookieArgs --poll 10"

Write-Host "New command will be:" -ForegroundColor Yellow
Write-Host "python.exe $FullArgs`n" -ForegroundColor Gray

$confirm = Read-Host "Do you want to update the service? (yes/no)"
if ($confirm -ne "yes") {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host "`nStopping service..." -ForegroundColor Yellow
& $NSSMPath stop $ServiceName
Start-Sleep -Seconds 3

Write-Host "Removing old service..." -ForegroundColor Yellow
& $NSSMPath remove $ServiceName confirm

Write-Host "Installing service with new cookie list..." -ForegroundColor Green
$InstallCmd = "install $ServiceName `"$PythonPath`" $FullArgs"
$InstallArgs = @(
    "install",
    $ServiceName,
    $PythonPath,
    $ScriptPath,
    "--cookies"
) + $CookieFiles + @("--poll", "10")

& $NSSMPath $InstallArgs

Write-Host "Configuring service..." -ForegroundColor Green
& $NSSMPath set $ServiceName AppDirectory $WorkingDir
& $NSSMPath set $ServiceName Start SERVICE_AUTO_START
& $NSSMPath set $ServiceName AppEnvironmentExtra "HEADLESS=true" "PLAYWRIGHT_BROWSERS_PATH=C:\Users\Administrator\AppData\Local\ms-playwright"
& $NSSMPath set $ServiceName AppStdout "$WorkingDir\logs\service_output.log"
& $NSSMPath set $ServiceName AppStderr "$WorkingDir\logs\service_error.log"
& $NSSMPath set $ServiceName AppRestartDelay 15000

Write-Host "Starting service..." -ForegroundColor Green
& $NSSMPath start $ServiceName
Start-Sleep -Seconds 3

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "SERVICE UPDATED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

Get-Service -Name $ServiceName | Select-Object Status, StartType, Name
Write-Host ""
