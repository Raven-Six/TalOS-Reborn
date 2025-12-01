# Network Diagnostic Script for TalOS Server
# Run this after starting your server

Write-Host "TalOS Server - Network Diagnostics" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# 1. Check if server is running
Write-Host "1. Checking if TalOS server is running on port 3003..." -ForegroundColor Yellow
$serverRunning = netstat -ano | findstr ":3003" | findstr "LISTENING"
if ($serverRunning) {
    Write-Host "SUCCESS: Server is running and listening on port 3003" -ForegroundColor Green
    Write-Host $serverRunning
} else {
    Write-Host "ERROR: Server is NOT running on port 3003" -ForegroundColor Red
    Write-Host "Please start your server first!" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit
}

Write-Host ""

# 2. Get local IP addresses
Write-Host "2. Your network IP addresses:" -ForegroundColor Yellow
$networkIPs = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*"}
foreach ($ip in $networkIPs) {
    Write-Host "   $($ip.IPAddress) - $($ip.InterfaceAlias)" -ForegroundColor White
}

$primaryIP = ($networkIPs | Where-Object {$_.IPAddress -like "192.168.*" -or $_.IPAddress -like "10.*"} | Select-Object -First 1).IPAddress
if ($primaryIP) {
    Write-Host ""
    Write-Host "Primary IP for local network: $primaryIP" -ForegroundColor Green
}

Write-Host ""

# 3. Check firewall rules
Write-Host "3. Checking Windows Firewall rules..." -ForegroundColor Yellow
$firewallRules = Get-NetFirewallRule -DisplayName "TalOS*" -ErrorAction SilentlyContinue
if ($firewallRules) {
    Write-Host "SUCCESS: TalOS firewall rules found:" -ForegroundColor Green
    $firewallRules | ForEach-Object {
        Write-Host "   - $($_.DisplayName): Enabled=$($_.Enabled)" -ForegroundColor White
    }
} else {
    Write-Host "WARNING: No TalOS firewall rules found!" -ForegroundColor Red
    Write-Host "   Run setup-firewall.ps1 as Administrator to add firewall rules" -ForegroundColor Yellow
}

Write-Host ""

# 4. Test localhost connection
Write-Host "4. Testing localhost connection..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3003" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-Host "SUCCESS: Server responds on localhost" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Server not responding on localhost" -ForegroundColor Red
    Write-Host "   $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# 5. Test IP connection
if ($primaryIP) {
    Write-Host "5. Testing connection via IP ($primaryIP)..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "http://$($primaryIP):3003" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        Write-Host "SUCCESS: Server responds on $primaryIP" -ForegroundColor Green
        Write-Host "   Other devices should be able to connect!" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Server not responding on $primaryIP" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "   This means other devices CANNOT connect!" -ForegroundColor Yellow
        Write-Host "   Possible causes:" -ForegroundColor Yellow
        Write-Host "   - Windows Firewall is blocking the connection" -ForegroundColor Yellow
        Write-Host "   - Third-party antivirus/firewall is interfering" -ForegroundColor Yellow
        Write-Host "   - Network adapter configuration issue" -ForegroundColor Yellow
    }
}

Write-Host ""

# 6. Check network profile
Write-Host "6. Checking network profile..." -ForegroundColor Yellow
$networkProfile = Get-NetConnectionProfile
Write-Host "   Network: $($networkProfile.Name)" -ForegroundColor White
Write-Host "   Category: $($networkProfile.NetworkCategory)" -ForegroundColor White
if ($networkProfile.NetworkCategory -eq "Public") {
    Write-Host "   WARNING: Network is set to Public - this may cause stricter firewall rules" -ForegroundColor Yellow
    Write-Host "   Consider changing to Private if this is a trusted network" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Diagnostic complete!" -ForegroundColor Green
Write-Host ""

if ($primaryIP) {
    Write-Host "To connect from other devices, use:" -ForegroundColor Cyan
    Write-Host "  http://$($primaryIP):3003" -ForegroundColor Green
}

Write-Host ""
Write-Host "If connection still fails from other devices:" -ForegroundColor Yellow
Write-Host "1. Make sure firewall rules are added (run setup-firewall.ps1 as Admin)" -ForegroundColor White
Write-Host "2. Temporarily disable third-party antivirus to test" -ForegroundColor White
Write-Host "3. Check if your router has AP isolation enabled" -ForegroundColor White
Write-Host "4. Make sure both devices are on the same network" -ForegroundColor White

Write-Host ""
Read-Host "Press Enter to exit"
