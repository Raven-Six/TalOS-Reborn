# TalOS Server - Firewall Configuration Script
# Run this script as Administrator

Write-Host "TalOS Server - Adding Firewall Rules" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click on PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Remove existing rules if they exist
Write-Host "Removing existing TalOS firewall rules (if any)..." -ForegroundColor Yellow
Remove-NetFirewallRule -DisplayName "TalOS Server - Port 3003" -ErrorAction SilentlyContinue
Remove-NetFirewallRule -DisplayName "TalOS Vite Dev Server - Port 5173" -ErrorAction SilentlyContinue

# Add firewall rule for TalOS server (port 3003)
Write-Host "Adding firewall rule for TalOS Server (TCP port 3003)..." -ForegroundColor Green
try {
    New-NetFirewallRule -DisplayName "TalOS Server - Port 3003" `
                        -Direction Inbound `
                        -Protocol TCP `
                        -LocalPort 3003 `
                        -Action Allow `
                        -Profile Any `
                        -Enabled True `
                        -ErrorAction Stop
    Write-Host "✓ Successfully added firewall rule for port 3003" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to add firewall rule for port 3003: $_" -ForegroundColor Red
}

# Add firewall rule for Vite dev server (port 5173)
Write-Host "Adding firewall rule for Vite Dev Server (TCP port 5173)..." -ForegroundColor Green
try {
    New-NetFirewallRule -DisplayName "TalOS Vite Dev Server - Port 5173" `
                        -Direction Inbound `
                        -Protocol TCP `
                        -LocalPort 5173 `
                        -Action Allow `
                        -Profile Any `
                        -Enabled True `
                        -ErrorAction Stop
    Write-Host "✓ Successfully added firewall rule for port 5173" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to add firewall rule for port 5173: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Firewall configuration complete!" -ForegroundColor Green
Write-Host ""

# Display current IP addresses
Write-Host "Your local IP addresses:" -ForegroundColor Cyan
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*"} | ForEach-Object {
    Write-Host "  - $($_.IPAddress)" -ForegroundColor White
}

Write-Host ""
Write-Host "You can now access TalOS from other devices using:" -ForegroundColor Yellow
$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -like "192.168.*" -or $_.IPAddress -like "10.*"} | Select-Object -First 1).IPAddress
if ($localIP) {
    Write-Host "  http://$($localIP):3003" -ForegroundColor Green
}

Write-Host ""
Read-Host "Press Enter to exit"
