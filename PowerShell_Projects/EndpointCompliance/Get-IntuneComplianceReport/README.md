# Intune Compliance Reporter
A specialized PowerShell utility for gathering bulk compliance data from Microsoft Intune based on an external asset list. 

## Use Case
System Administrators often receive lists of specific assets from HR or Procurement that need immediate compliance verification. Rather than searching the Intune GUI manually for 50+ devices, this script automates the retrieval of:
* **Compliance State** (Compliant, Non-Compliant, Grace Period, etc.)
* **Primary User UPN**
* **Operating System**
* **Managed Device ID**

## Requirements
* **Microsoft Graph PowerShell SDK:** `Install-Module Microsoft.Graph`
* **Permissions:** You must have the `DeviceManagementManagedDevices.Read.All` permission granted in your tenant.
* **Input File:** A file named `ListLaptops.txt` in the same directory as the script, containing one device name per line.

## Usage
1. Populate `ListLaptops.txt` with your target device names.
2. Run the script:
   ```powershell
   .\Get-IntuneComplianceReport.ps1

## Extras
Option to switch properties on the following line:
- $device = Get-MgDeviceManagementManagedDevice -Filter "deviceName eq '$currentName'" `
                      -Property "id,deviceName,userPrincipalName,operatingSystem,complianceState"
Also optional to use all users instead of a for loop and pulling from a text list:
- $AllDevices = Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/beta/devices?$filter=managementType ne null&$count=true&$select=id' -Headers @{ConsistencyLevel = "eventual"}

                    