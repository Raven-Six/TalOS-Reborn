# Simple Firewall Rule - Run as Administrator
# This creates a very permissive rule to allow ALL traffic on port 3003

$ruleName = "TalOS-Port-3003-Allow-All"

# Remove existing rule if present
Remove-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue

# Create new rule - allow ALL traffic on port 3003
New-NetFirewallRule -DisplayName $ruleName `
                    -Direction Inbound `
                    -Protocol TCP `
                    -LocalPort 3003 `
                    -Action Allow `
                    -Profile Any `
                    -Enabled True

Write-Host ""
Write-Host "Firewall rule added successfully!" -ForegroundColor Green
Write-Host "Rule: $ruleName" -ForegroundColor Cyan
Write-Host "This allows ALL incoming TCP traffic on port 3003" -ForegroundColor Yellow
Write-Host ""

# Verify the rule was created
$rule = Get-NetFirewallRule -DisplayName $ruleName
if ($rule) {
    Write-Host "Verification: Rule exists and is enabled" -ForegroundColor Green
    Write-Host ""
    Write-Host "Now try accessing your server from another device" -ForegroundColor Cyan
} else {
    Write-Host "ERROR: Rule was not created" -ForegroundColor Red
}

Read-Host "Press Enter to exit"
