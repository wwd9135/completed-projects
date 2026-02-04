<#
.SYNOPSIS
    Generates a compliance report for a specific list of Defender-managed devices.
.DESCRIPTION
    This script imports a list of device names from a text file, queries https://graph.microsoft.com/v1.0/security/alerts
    Created to gather data regarding specific KB's, devices deleted from all other data sources
.PARAMETER ListPath
    The path to the .txt file containing device names (one per line). Defaults to ListLaptops.txt.
.NOTES
    Author: William Richardson
    Date: 04/02/2026
    Required Permissions: Connect-MgGraph -Scopes "Security.Read.All"
#>

# Configuration
$ReportPath = "C:\Temp"
$InputFile  = "ListLaptops.txt"
$ErrorActionPreference = "Stop"


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


# Connect to graph, check permissions and privledges are what they need to be for the entire script to run.
try {
    # Query Graph via Filter (Best practice for performance)
            $device = Get-MgDeviceManagementManagedDevice -Filter "deviceName eq '$currentName'" `
                      -Property "id,deviceName,userPrincipalName,operatingSystem,complianceState"

            if (-not $device) {
                Write-Host "  [-] Device not found in Intune." -ForegroundColor Yellow
                $NotFound += $currentName
                continue
            }
}
catch {
    Write-Host "`n[!] Critical Script Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    # Optional: Disconnect-MgGraph
}


# Verify device list path is valid and actually present
if (!(Test-Path -Path $ReportPath)) {
    Write-Host "[!] Error: Report path '$ReportPath' not found. Please create it or adjust the script." -ForegroundColor Red
    return
}

# Data desired:
# 