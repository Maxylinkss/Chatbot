# Facebook Messenger Bot Service Management Script
# This script helps you manage your bot service easily

$ServiceName = "FacebookMessengerBot"
$NSSMPath = "C:\Users\Administrator\Downloads\realchatapp\nssm-2.24\win64\nssm.exe"

function Show-Menu {
    Clear-Host
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "Facebook Messenger Bot Service Manager" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Start Service" -ForegroundColor Green
    Write-Host "2. Stop Service" -ForegroundColor Yellow
    Write-Host "3. Restart Service" -ForegroundColor Magenta
    Write-Host "4. Check Service Status" -ForegroundColor Blue
    Write-Host "5. View Service Logs (Output)" -ForegroundColor Cyan
    Write-Host "6. View Service Logs (Errors)" -ForegroundColor Red
    Write-Host "7. View Live Logs (tail -f)" -ForegroundColor White
    Write-Host "8. Remove Service" -ForegroundColor DarkRed
    Write-Host "Q. Quit" -ForegroundColor Gray
    Write-Host ""
}

function Start-BotService {
    Write-Host "Starting service..." -ForegroundColor Green
    & $NSSMPath start $ServiceName
    Start-Sleep -Seconds 2
    Get-Service -Name $ServiceName | Select-Object Status, StartType, Name
}

function Stop-BotService {
    Write-Host "Stopping service..." -ForegroundColor Yellow
    & $NSSMPath stop $ServiceName
    Start-Sleep -Seconds 2
    Get-Service -Name $ServiceName | Select-Object Status, StartType, Name
}

function Restart-BotService {
    Write-Host "Restarting service..." -ForegroundColor Magenta
    & $NSSMPath restart $ServiceName
    Start-Sleep -Seconds 2
    Get-Service -Name $ServiceName | Select-Object Status, StartType, Name
}

function Get-BotStatus {
    Write-Host "Service Status:" -ForegroundColor Blue
    Get-Service -Name $ServiceName | Select-Object Status, StartType, Name, DisplayName | Format-List
    Write-Host ""
    Write-Host "NSSM Status:" -ForegroundColor Blue
    & $NSSMPath status $ServiceName
}

function Show-OutputLogs {
    $LogPath = "C:\Users\Administrator\Downloads\realchatapp\logs\service_output.log"
    if (Test-Path $LogPath) {
        Write-Host "Last 50 lines of output log:" -ForegroundColor Cyan
        Get-Content $LogPath -Tail 50
    } else {
        Write-Host "No output log found." -ForegroundColor Red
    }
}

function Show-ErrorLogs {
    $LogPath = "C:\Users\Administrator\Downloads\realchatapp\logs\service_error.log"
    if (Test-Path $LogPath) {
        Write-Host "Last 50 lines of error log:" -ForegroundColor Red
        Get-Content $LogPath -Tail 50
    } else {
        Write-Host "No error log found." -ForegroundColor Red
    }
}

function Show-LiveLogs {
    $LogPath = "C:\Users\Administrator\Downloads\realchatapp\logs\service_error.log"
    Write-Host "Showing live logs (Ctrl+C to exit)..." -ForegroundColor White
    if (Test-Path $LogPath) {
        Get-Content $LogPath -Wait -Tail 20
    } else {
        Write-Host "No log file found." -ForegroundColor Red
    }
}

function Remove-BotService {
    Write-Host "WARNING: This will remove the service completely!" -ForegroundColor Red
    $confirm = Read-Host "Are you sure? (yes/no)"
    if ($confirm -eq "yes") {
        & $NSSMPath stop $ServiceName
        & $NSSMPath remove $ServiceName confirm
        Write-Host "Service removed." -ForegroundColor Green
    } else {
        Write-Host "Cancelled." -ForegroundColor Yellow
    }
}

# Main loop
do {
    Show-Menu
    $choice = Read-Host "Select an option"
    
    switch ($choice) {
        '1' { Start-BotService }
        '2' { Stop-BotService }
        '3' { Restart-BotService }
        '4' { Get-BotStatus }
        '5' { Show-OutputLogs }
        '6' { Show-ErrorLogs }
        '7' { Show-LiveLogs }
        '8' { Remove-BotService }
        'Q' { return }
        default { Write-Host "Invalid option, please try again." -ForegroundColor Red }
    }
    
    if ($choice -ne 'Q') {
        Write-Host ""
        Write-Host "Press any key to continue..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
} while ($choice -ne 'Q')

Write-Host "Goodbye!" -ForegroundColor Cyan
