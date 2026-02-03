<#
.SYNOPSIS
    Generates a compliance report for a specific list of Intune-managed devices.
.DESCRIPTION
    This script imports a list of device names from a text file, queries Microsoft Graph 
    for their current compliance state, OS, and primary user, and exports the data to CSV.
.PARAMETER ListPath
    The path to the .txt file containing device names (one per line). Defaults to ListLaptops.txt.
.NOTES
    Author: William Richardson
    Date: 03/02/2026
    Required Permissions: DeviceManagementManagedDevices.Read.All
#>

# Configuration
$ReportPath = "C:\Temp"
$InputFile  = "ListLaptops.txt"
$ErrorActionPreference = "Stop"

# --- Environment Validation ---

# Ensure Report Directory exists
if (!(Test-Path -Path $ReportPath)) {
    Write-Host "[!] Error: Report path '$ReportPath' not found. Please create it or adjust the script." -ForegroundColor Red
    return
}

# Verify Microsoft Graph Module
if (!(Get-Module -ListAvailable Microsoft.Graph)) {
    Write-Host "[!] Error: Microsoft.Graph module is missing." -ForegroundColor Red
    Write-Host "[i] Run: Install-Module Microsoft.Graph -Scope CurrentUser" -ForegroundColor Cyan
    return
}

# Verify Input File
if (!(Test-Path -Path $InputFile)) {
    Write-Host "[!] Error: Input file '$InputFile' not found in script directory." -ForegroundColor Red
    return
}

# --- Execution ---
try {
    # Connect with specific scope for Managed Devices
    Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All" -NoWelcome

    $deviceNames = Get-Content -Path $InputFile | Where-Object { ![string]::IsNullOrWhiteSpace($_) }
    Write-Host "[*] Loaded $($deviceNames.Count) device names for processing.`n" -ForegroundColor Cyan

    $Results  = @()
    $NotFound = @()

    foreach ($name in $deviceNames) {
        $currentName = $name.Trim()
        Write-Host "Checking: $currentName..." -ForegroundColor Gray

        try {
            # Query Graph via Filter (Best practice for performance)
            $device = Get-MgDeviceManagementManagedDevice -Filter "deviceName eq '$currentName'" `
                      -Property "id,deviceName,userPrincipalName,operatingSystem,complianceState"

            if (-not $device) {
                Write-Host "  [-] Device not found in Intune." -ForegroundColor Yellow
                $NotFound += $currentName
                continue
            }

            foreach ($d in $device) {
                $Results += [PSCustomObject]@{
                    DeviceName        = $d.DeviceName
                    UserPrincipalName = $d.UserPrincipalName
                    OperatingSystem   = $d.OperatingSystem
                    ComplianceState   = $d.ComplianceState
                    ManagedDeviceId   = $d.Id
                    AuditDate         = Get-Date -Format "yyyy-MM-dd HH:mm"
                }
            }
        }
        catch {
            Write-Host "  [!] Error querying $currentName : $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    # --- Export Results ---
    if ($Results.Count -gt 0) {
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $csvPath   = Join-Path $ReportPath "IntuneComplianceReport_$timestamp.csv"

        $Results | Sort-Object DeviceName | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
        Write-Host "`n[+] Success: Results exported to $csvPath" -ForegroundColor Green
    }
    else {
        Write-Host "`n[!] No data found for the provided list." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "`n[!] Critical Script Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    # Optional: Disconnect-MgGraph
}