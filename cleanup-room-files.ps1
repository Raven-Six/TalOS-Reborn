# Find and Clean Corrupted Room Files
# This script will find and optionally delete empty or corrupted JSON files in the rooms directory

Write-Host "TalOS - Room File Cleanup Utility" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Get the TalOS data directory
$appDataDir = $env:APPDATA
if (!$appDataDir) {
    if ($env:HOME) {
        $appDataDir = Join-Path $env:HOME ".local/share"
    }
}

$talosDir = Join-Path $appDataDir "TalOS"
$roomsPath = Join-Path $talosDir "data\rooms"

Write-Host "Checking rooms directory: $roomsPath" -ForegroundColor Yellow
Write-Host ""

if (!(Test-Path $roomsPath)) {
    Write-Host "ERROR: Rooms directory not found at $roomsPath" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# Get all JSON files in the rooms directory
$jsonFiles = Get-ChildItem -Path $roomsPath -Filter "*.json"

Write-Host "Found $($jsonFiles.Count) JSON files in rooms directory" -ForegroundColor White
Write-Host ""

$corruptedFiles = @()
$emptyFiles = @()

foreach ($file in $jsonFiles) {
    $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
    
    # Check if file is empty or just whitespace
    if ([string]::IsNullOrWhiteSpace($content)) {
        $emptyFiles += $file
        Write-Host "EMPTY: $($file.Name)" -ForegroundColor Red
        continue
    }
    
    # Try to parse as JSON
    try {
        $null = $content | ConvertFrom-Json -ErrorAction Stop
        # Write-Host "OK: $($file.Name)" -ForegroundColor Green
    } catch {
        $corruptedFiles += $file
        Write-Host "CORRUPTED: $($file.Name) - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  Total files: $($jsonFiles.Count)" -ForegroundColor White
Write-Host "  Empty files: $($emptyFiles.Count)" -ForegroundColor $(if ($emptyFiles.Count -gt 0) { "Red" } else { "Green" })
Write-Host "  Corrupted files: $($corruptedFiles.Count)" -ForegroundColor $(if ($corruptedFiles.Count -gt 0) { "Red" } else { "Green" })
Write-Host ""

$problemFiles = $emptyFiles + $corruptedFiles

if ($problemFiles.Count -eq 0) {
    Write-Host "No problems found! All room files are valid." -ForegroundColor Green
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit
}

Write-Host "Problem files found:" -ForegroundColor Yellow
foreach ($file in $problemFiles) {
    Write-Host "  - $($file.FullName)" -ForegroundColor White
}

Write-Host ""
$response = Read-Host "Do you want to DELETE these problem files? (yes/no)"

if ($response -eq "yes") {
    Write-Host ""
    Write-Host "Deleting problem files..." -ForegroundColor Yellow
    
    foreach ($file in $problemFiles) {
        try {
            Remove-Item -Path $file.FullName -Force
            Write-Host "  Deleted: $($file.Name)" -ForegroundColor Green
        } catch {
            Write-Host "  ERROR deleting $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "Cleanup complete!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "No files were deleted." -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Press Enter to exit"
