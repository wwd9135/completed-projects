# This script is designed to Ping a list of devices found using the defender KQL scripts in this folder.
# It will feed back a simple table showing which devices are reachable and which arent.
# Tip- it's logical to assess which data you need to scan, if a lot of it is 169.254 or public IPv4's (link local IPv4 addresses) may as well remove them from the data source.

# Requires ImportExcel module: Install-Module ImportExcel -Scope CurrentUser
$path = "IPAddresses.xlsx"

# Helper: choose the most useful IP from the JSON array for a device
function Get-BestIpFromJson {
    param(
        [Parameter(Mandatory)]
        [string]$Json
    )
    if ([string]::IsNullOrWhiteSpace($Json)) { return $null }

    try {
        $arr = $Json | ConvertFrom-Json
    }
    catch {
        # Not valid JSON
        return $null
    }

    if (-not $arr) { return $null }

    # Normalize to array in case it's a single object
    if ($arr -isnot [System.Collections.IEnumerable]) { $arr = @($arr) }

    # Strategy:
    # 1) Prefer AddressType 'Private' or 'Public'
    # 2) Else take first non-link-local
    # 3) Else fall back to first entry
    $preferred = $arr | Where-Object { $_.AddressType -in @('Private','Public') }
    if ($preferred) { return $preferred | Select-Object -First 1 }

    $nonLinkLocal = $arr | Where-Object { $_.IPAddress -notlike '169.254.*' }
    if ($nonLinkLocal) { return $nonLinkLocal | Select-Object -First 1 }

    return $arr | Select-Object -First 1
}

# Optional: IPv4 sanity check (since JSON already supplies an IP, this is extra safety)
$ipv4 = '^(?:\d{1,3}\.){3}\d{1,3}$'

# Import Excel as objects (do NOT pipe to Format-Table)
$rows = Import-Excel -Path $path

$results = foreach ($row in $rows) {
    $device = $row.DeviceName
    $rawJson = $row.IPAddresses

    $chosen = Get-BestIpFromJson -Json $rawJson

    if (-not $chosen) {
        [pscustomobject]@{
            DeviceName   = $device
            ChosenIP     = $null
            AddressType  = $null
            Reachable    = $false
            Reason       = 'No usable IP / invalid JSON'
            TimeStamp    = (Get-Date)
        }
        continue
    }

    $ip = $chosen.IPAddress
    $addrType = $chosen.AddressType

    if ($ip -notmatch $ipv4) {
        [pscustomobject]@{
            DeviceName   = $device
            ChosenIP     = $ip
            AddressType  = $addrType
            Reachable    = $false
            Reason       = 'Not a valid IPv4 format'
            TimeStamp    = (Get-Date)
        }
        continue
    }

    # Skip 169.254.* unless you explicitly want to test link-local
    if ($ip -like '169.254.*') {
        [pscustomobject]@{
            DeviceName   = $device
            ChosenIP     = $ip
            AddressType  = $addrType
            Reachable    = $false
            Reason       = 'Link-local skipped'
            TimeStamp    = (Get-Date)
        }
        continue
    }

    $isUp = Test-Connection -TargetName $ip -Count 2 -Quiet -ErrorAction SilentlyContinue

    [pscustomobject]@{
        DeviceName   = $device
        ChosenIP     = $ip
        AddressType  = $addrType
        Reachable    = $isUp
        Reason       = if ($isUp) { 'OK' } else { 'No reply' }
        TimeStamp    = (Get-Date)
    }
}

# Show results
$results | Sort-Object DeviceName | Format-Table -AutoSize
