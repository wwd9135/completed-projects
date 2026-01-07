<#
This script uses the PSAppDeployToolkit framework to deploy and execute a secure BitLocker startup PIN configuration.

It runs with administrative privileges via the Intune PSAppDeployToolkit deployment model (SYSTEM context),
and has been security reviewed with all identified issues and some remediated.

The script presents a Windows Forms GUI that enforces organisational BitLocker PIN policies and securely
collects user input before applying the configuration.

This implementation supersedes and replaces the legacy 'Set-BitLockerPIN.ps1' script.
Security audit performed by Greg Butler & rest of OffSec team, actioned by William Richardson - January 2026.
#>


<#.SYNOPSIS
PSAppDeployToolkit - This script performs the installation or uninstallation of an application(s).

.DESCRIPTION
- The script is provided as a template to perform an install, uninstall, or repair of an application(s).
- The script either performs an "Install", "Uninstall", or "Repair" deployment type.
- The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.

The script imports the PSAppDeployToolkit module which contains the logic and functions required to install or uninstall an application.

PSAppDeployToolkit is licensed under the GNU LGPLv3 License - (C) 2025 PSAppDeployToolkit Team (Sean Lillis, Dan Cunningham, Muhammad Mashwani, Mitch Richters, Dan Gough).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License\
for more details. You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

.PARAMETER DeploymentType
The type of deployment to perform.

.PARAMETER DeployMode
Specifies whether the installation should be run in Interactive (shows dialogs), Silent (no dialogs), or NonInteractive (dialogs without prompts) mode.

NonInteractive mode is automatically set if it is detected that the process is not user interactive.

.PARAMETER AllowRebootPassThru
Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.

.PARAMETER TerminalServerMode
Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Desktop Session Hosts/Citrix servers.

.PARAMETER DisableLogging
Disables logging to file for the script.

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -DeployMode Silent

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -AllowRebootPassThru

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -DeploymentType Uninstall

.EXAMPLE
Invoke-AppDeployToolkit.exe -DeploymentType "Install" -DeployMode "Silent"

.INPUTS
None. You cannot pipe objects to this script.

.OUTPUTS
None. This script does not generate any output.

.NOTES
Toolkit Exit Code Ranges:
- 60000 - 68999: Reserved for built-in exit codes in Invoke-AppDeployToolkit.ps1, and Invoke-AppDeployToolkit.exe
- 69000 - 69999: Recommended for user customized exit codes in Invoke-AppDeployToolkit.ps1
- 70000 - 79999: Recommended for user customized exit codes in PSAppDeployToolkit.Extensions module.

.LINK
https://psappdeploytoolkit.com

#>

[CmdletBinding()]
param
(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall', 'Repair')]
    [PSDefaultValue(Help = 'Install', Value = 'Install')]
    [System.String]$DeploymentType,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
    [PSDefaultValue(Help = 'Interactive', Value = 'Interactive')]
    [System.String]$DeployMode,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$AllowRebootPassThru,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$TerminalServerMode,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$DisableLogging
)

##================================================
## MARK: Variables
##================================================

$adtSession = @{
    # App variables.
    AppVendor = 'Met Office'
    AppName = 'Set BitLocker Pin'
    AppVersion = ''
    AppArch = ''
    AppLang = 'EN'
    AppRevision = '01'
    AppSuccessExitCodes = @(0)
    AppRebootExitCodes = @(1641, 3010)
    AppScriptVersion = '1.0.0'
    AppScriptDate = '2025-06-01'
    AppScriptAuthor = 'William richardson'

    # Install Titles (Only set here to override defaults set by the toolkit).
    InstallName = 'Set BitLocker PIN'
    InstallTitle = 'Set BitLocker PIN'

    # Script variables.
    DeployAppScriptFriendlyName = $MyInvocation.MyCommand.Name
    DeployAppScriptVersion = '4.0.6'
    DeployAppScriptParameters = $PSBoundParameters
}
# Module contains input filtering logic & all GUI related code.
$ModulePath = Join-Path $PSScriptRoot "Files\mod.psm1"
Import-Module $ModulePath -Force -ErrorAction Stop

function Install-ADTDeployment {
    ##================================================
    ## MARK: Pre-Install
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType
    $buttonChoice = Show-ADTInstallationPrompt `
    -Title 'Set BitLocker PIN Code' `
    -Message "BitLocker is a Windows feature providing encryption.
BitLocker requires a PIN code that must be entered every time your computer is started up. This PIN code is of your own choice.
`nWhen you click 'I'm Ready' a text box will appear. When prompted, please enter an alphanumeric PIN code of 8 characters or more, then click 'Set PIN' to complete the process." `
        -Icon Warning `
        -PersistPrompt `
        -ButtonMiddleText "I'm Ready" `
        -ButtonRightText "Cancel"
    
    Write-ADTLogEntry -Message "User selected: $buttonChoice"
    If ($buttonChoice -eq "Cancel") {
        Write-ADTLogEntry -Message "User canceled installation at initial popup."
        Exit 1602  
    }
    BitLockerGuiLauncher

    if ($global:UserCancelled) {
        Write-ADTLogEntry -Message "User canceled installation during popup."
        Exit 1602  
    }

    ##================================================
    ## MARK: Installation
    ##================================================
    # Important section: Modify BitLocker PIN code
    try {
        $BitLockerVolumes = Get-BitLockerVolume | Where-Object { $_.VolumeStatus -eq "FullyEncrypted" }
        if (-not $BitLockerVolumes) {
            Write-ADTLogEntry "No BitLocker volumes found."
            Exit 1
        }

        foreach ($Vol in $BitLockerVolumes) {
            $MountPoint = $Vol.MountPoint
            Write-ADTLogEntry "Processing drive $MountPoint ..."

            Suspend-BitLocker -MountPoint $MountPoint -RebootCount 1
            Write-ADTLogEntry "Suspended BitLocker on $MountPoint"

            $Protector = $Vol.KeyProtector | Where-Object { $_.KeyProtectorType -eq "TpmPin" }
            if ($Protector) {
                Write-ADTLogEntry "Removing existing TPM+PIN protector..."
                Remove-BitLockerKeyProtector -MountPoint $MountPoint -KeyProtectorId $Protector.KeyProtectorId
            } else {
                Write-ADTLogEntry "No TPM+PIN protector found, skipping remove step."
            }

            try {
                Add-BitLockerKeyProtector -MountPoint $MountPoint -TpmAndPinProtector -Pin $global:securePin
                Write-ADTLogEntry "New TPM+PIN protector added successfully on $MountPoint"
            }
            catch {
                Write-ADTLogEntry "Failed to add TPM+PIN protector: $_"
                Exit 1
            }

            Resume-BitLocker -MountPoint $MountPoint
            Write-ADTLogEntry "Resumed BitLocker on $MountPoint"
        }

        Show-ADTInstallationPrompt -Message "BitLocker PIN updated successfully." -ButtonRightText "OK"
        Exit 0
    }
    catch {
        Write-ADTLogEntry "Failure while modifying BitLocker code. $_"
        Exit 1
    }

    ##================================================
    ## MARK: Post-Install
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"
    Show-ADTInstallationPrompt -Title 'Set BitLocker PIN Code' -Icon Shield -NoWait `
        -Message 'You have successfully reset your BitLocker PIN code. This is now required whenever your computer starts up.' `
        -ButtonMiddleText 'Finish'
}

    function Uninstall-ADTDeployment
    {
        ##================================================
        ## MARK: Pre-Uninstall
        ##================================================
        $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

        ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing.
        Show-ADTInstallationWelcome -CloseProcesses iexplore -CloseProcessesCountdown 60

        ## Show Progress Message (with the default message).
        Show-ADTInstallationProgress

        ## <Perform Pre-Uninstallation tasks here>


        ##================================================
        ## MARK: Uninstall
        ##================================================
        $adtSession.InstallPhase = $adtSession.DeploymentType

        ## Handle Zero-Config MSI uninstallations.
        if ($adtSession.UseDefaultMsi)
        {
            $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
            if ($adtSession.DefaultMstFile)
            {
                $ExecuteDefaultMSISplat.Add('Transform', $adtSession.DefaultMstFile)
            }
            Start-ADTMsiProcess @ExecuteDefaultMSISplat
        }

        ## <Perform Uninstallation tasks here>


    ##================================================
    ## MARK: Post-Uninstallation
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    ## <Perform Post-Uninstallation tasks here>
}

function Repair-ADTDeployment
{
    ##================================================
    ## MARK: Pre-Repair
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"
    ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing.
    Show-ADTInstallationWelcome -CloseProcesses iexplore -CloseProcessesCountdown 60
    ## Show Progress Message (with the default message).
    Show-ADTInstallationProgress
    
    ##================================================
    ## MARK: Repair
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    ## Handle Zero-Config MSI repairs.
    if ($adtSession.UseDefaultMsi)
    {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile)
        {
            $ExecuteDefaultMSISplat.Add('Transform', $adtSession.DefaultMstFile)
        }
        Start-ADTMsiProcess @ExecuteDefaultMSISplat
    }

    ##================================================
    ## MARK: Post-Repair
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

   
}


##================================================
## MARK: Initialization
##================================================

# Set strict error handling across entire operation.
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
Set-StrictMode -Version 2

# Import the module and instantiate a new session.
try
{
    $moduleName = if ([System.IO.File]::Exists("$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1"))
    {
        Get-ChildItem -LiteralPath $PSScriptRoot\PSAppDeployToolkit -Recurse -File | Unblock-File -ErrorAction Ignore
        "$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1"
    }
    else
    {
        'PSAppDeployToolkit'
    }
    Import-Module -FullyQualifiedName @{ ModuleName = $moduleName; Guid = '8c3c366b-8606-4576-9f2d-4051144f7ca2'; ModuleVersion = '4.0.6' } -Force
    try
    {
        $iadtParams = Get-ADTBoundParametersAndDefaultValues -Invocation $MyInvocation
        $adtSession = Open-ADTSession -SessionState $ExecutionContext.SessionState @adtSession @iadtParams -PassThru
    }
    catch
    {
        Remove-Module -Name PSAppDeployToolkit* -Force
        throw
    }
}
catch
{
    $Host.UI.WriteErrorLine((Out-String -InputObject $_ -Width ([System.Int32]::MaxValue)))
    exit 60008
}


##================================================
## MARK: Invocation
##================================================

try
{
    Get-Item -Path $PSScriptRoot\PSAppDeployToolkit.* | & {
        process
        {
            Get-ChildItem -LiteralPath $_.FullName -Recurse -File | Unblock-File -ErrorAction Ignore
            Import-Module -Name $_.FullName -Force
        }
    }
    & "$($adtSession.DeploymentType)-ADTDeployment"
    Close-ADTSession
}
catch
{
    Write-ADTLogEntry -Message ($mainErrorMessage = Resolve-ADTErrorRecord -ErrorRecord $_) -Severity 3
    Show-ADTDialogBox -Text $mainErrorMessage -Icon Stop | Out-Null
    Close-ADTSession -ExitCode 60001
}
finally
{
    Remove-Module -Name PSAppDeployToolkit* -Force
}


# SIG # Begin signature block
# MIIO1wYJKoZIhvcNAQcCoIIOyDCCDsQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUpnYebmm5rqbqeNGLPHiQXwSy
# 8wCgggwsMIIF0TCCA7mgAwIBAgITKgAACAJDoqOnJzRXWQABAAAIAjANBgkqhkiG
# 9w0BAQsFADBdMRIwEAYKCZImiZPyLGQBGRYCdWsxEzARBgoJkiaJk/IsZAEZFgNn
# b3YxGTAXBgoJkiaJk/IsZAEZFgltZXRvZmZpY2UxFzAVBgNVBAMTDk1PLUlzc3Vp
# bmctQ0EyMB4XDTI1MDUxNTA5MTU1NVoXDTI2MDUxNTA5MjU1NVowHDEaMBgGA1UE
# AxMRRGlnaXRhbCBXb3JrcGxhY2UwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQDQU6GFioyq7Pbj8wvuqwFMhAymFGEOAkmqaMzcdK37d6wbRhBYqlCOsOoM
# dBI5TIWw1xhN7ekZ4tzqO4AkWEGc+IFUIJVhkISu200uruJxypJ0qAOvaWMszof8
# gqDtrDSCdPfCWw1mGejM52W19I729c1wz0DLT20HYafaa2ejAC7hLIo5+2lNEANN
# qjvEYB5qMVqkwlPdoXCO03e2p1ZyTg0dfAhRolrTtPactTmFlqIrGt9P5/1XEumJ
# /BoKpQuHi+RU5b2Ap2ujnt7RQ+bpKqsQjPKF4ms6z908gVlH7GMi8t+4qqd5wpYh
# 55vE7B6vztaKjcVTH4zzdBkaq2c9AgMBAAGjggHJMIIBxTA9BgkrBgEEAYI3FQcE
# MDAuBiYrBgEEAYI3FQiU/VmDldtVhYGFEoKnjHWH9P8ogSGGmPQYgY7gawIBZAIB
# BjATBgNVHSUEDDAKBggrBgEFBQcDAzAOBgNVHQ8BAf8EBAMCB4AwGwYJKwYBBAGC
# NxUKBA4wDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUK/KiXtrDYR9QcyLBpxdyIlfM
# 08wwLAYDVR0RBCUwI4EhZGlnaXRhbHdvcmtwbGFjZUBtZXRvZmZpY2UuZ292LnVr
# MB8GA1UdIwQYMBaAFKvgcHlN+epDhfucS49+LDoxlAQ8MEoGA1UdHwRDMEEwP6A9
# oDuGOWh0dHA6Ly9jcmwubWV0b2ZmaWNlLmdvdi51ay9DZXJ0RW5yb2xsL01PLUlz
# c3VpbmctQ0EyLmNybDCBhwYIKwYBBQUHAQEEezB5MEgGCCsGAQUFBzAChjxodHRw
# Oi8vY3JsLm1ldG9mZmljZS5nb3YudWsvQ2VydEVucm9sbC9NTy1Jc3N1aW5nLUNB
# MigxKS5jcnQwLQYIKwYBBQUHMAGGIWh0dHA6Ly9vY3NwLm1ldG9mZmljZS5nb3Yu
# dWsvb2NzcDANBgkqhkiG9w0BAQsFAAOCAgEAAt5rPnDMbtljHbm2Bu726SDqYsYI
# UJq1SMGZsbnuUnMqI+N/cNz+cAJmV3EDFp3F3svCNXizesfvH+CKgCkFiH38bAC/
# 4gZOphn7szZqPdOia0DspGPmS4Pzo4y/uLSsWgU+q9vQZqd2FgLp55I6OMnbzEIS
# Q2+LaV+R8Z4rFX0SlBpmCJaxQ9W8oqfSqtaNNRDqWRC5dyCGkzaJpjqHy2MyrYcI
# rfMlWvZJv0B7ufLxttxNtHg4CRbbx7LEzDiwqix5ytFMPz/m2dHOywL1R1UtPO51
# JdEKClvekEF33kO0TFp/mL02dKqZjnAmtZCHqM/zgvBiw1XzdVJJsgbcVWLrmM7q
# ED0GX982oKH4tpoB8Ye6o34gQix+D+eAR0JDApiQkdksLVhPo/C6Q+5+kwSME0YQ
# Lm9F29AKv2phBOdppNymBeLC2ybnkn4ranNrx04vJylEBKGxufIPTnHSvzBPu4Cq
# omX4cbgupu1qXc/vT3kKp3SgewRgsf20/yJWsWSJHm4HKNYYXDUkUjFs2H/roS3N
# ftrRP9eO97seIhRmEPS+jqPmDDKcKysPNSu2wHlvMYiKMEULwA6HyZB6tFhEv1uY
# 2XIAKEs4c63MpUA+BNfP7qRiOjtyg3xBAyVAPrspyJjD2y9bcKWEebpT2fnD+pwz
# WGtaJbp3DHKlTPYwggZTMIIEO6ADAgECAhMhAAAABAiDy6+efeoTAAAAAAAEMA0G
# CSqGSIb3DQEBCwUAMBYxFDASBgNVBAMTC01PLVJvb3QtQ0ExMB4XDTIzMTEzMDEw
# MjcwMFoXDTI4MTEzMDEwMzcwMFowXTESMBAGCgmSJomT8ixkARkWAnVrMRMwEQYK
# CZImiZPyLGQBGRYDZ292MRkwFwYKCZImiZPyLGQBGRYJbWV0b2ZmaWNlMRcwFQYD
# VQQDEw5NTy1Jc3N1aW5nLUNBMjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAKxuFROg9mCaXUboJsUUaZ3WJu9swDdKMjEn+0lBA7wRJtyXHNIPld/S37jV
# ozqlWj0KeIOHnPfsq6dFWJjvRbtlYJWSwugwVL7wnj1OuvuotECVhWx+r0FpTmgA
# lVO6lEiRHbVDNcCYJUv7lQIqYviLJn1eXnMZOsQ/BfzbETgdoSdeyXrv/ebCO8Ys
# 5Q+2loIdGAlVZnp1VJphveO7DkaYTkwO83oGUc2lG42ihW4zL1zhqF1wWfY2Y/Mc
# POVUNGWyBMV18Pm/5UX7pZOkodtX+6s/wKJFtl8l3Ayrl/hgu8hBUXMCFmthEXeq
# hjRGX65eJxP+75WvdeO1NZgtaiGGyLLyLXF6qTpQxSjzb5mDftFxBG2WT1C1xLY9
# ezGvvkioNBX3QpFRFP21RoCQNnkorJoKd3kTg/Pxmuf5axVD57HTe8M5tBA/7vQS
# lNLu4G7cyTTrXyRom34785v9hX0VL8QxxvupjTI+HcGu6mYh/N2TXAMxOOywnYYn
# TVoaxyX4UiV1ALhMZzPlVLXeF/vfoBkZMycabQumttIA98WhHQ2dc9yoPTyFCt5h
# F3wmZ5HfgOz9DdEJjE06fFSkWW4IObAWRCiC/N9Lhfc89t2Q9koUtNEWmV5UED5Y
# o5C9l4TF5O7TPjG+Q9ZUhuY1rds6kI0pbjTmNCCV/lq53YMpAgMBAAGjggFRMIIB
# TTAQBgkrBgEEAYI3FQEEAwIBATAjBgkrBgEEAYI3FQIEFgQUzc7JXFo6X2cgSGfm
# K5IgHSl0n/EwHQYDVR0OBBYEFKvgcHlN+epDhfucS49+LDoxlAQ8MBkGCSsGAQQB
# gjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/
# MB8GA1UdIwQYMBaAFJThh/3jdh49ZgABx9KuLIGOG0V3MEcGA1UdHwRAMD4wPKA6
# oDiGNmh0dHA6Ly9jcmwubWV0b2ZmaWNlLmdvdi51ay9DZXJ0RW5yb2xsL01PLVJv
# b3QtQ0ExLmNybDBSBggrBgEFBQcBAQRGMEQwQgYIKwYBBQUHMAKGNmh0dHA6Ly9j
# cmwubWV0b2ZmaWNlLmdvdi51ay9DZXJ0RW5yb2xsL01PLVJvb3QtQ0ExLmNydDAN
# BgkqhkiG9w0BAQsFAAOCAgEAfSHxvXop9tReOGU9IX8UcWgnQjRytymoJeAB1Lei
# Jdae8tWKJ9JRXb37NwsKSvz0sCehb3NzAXHhmAuSYdR6GG5A+OmdorWOOGKtxteE
# GofhJ2Xs+WP593M1u0cSnP9LQUGS8eE/13tFZmnXA7ToXg1AXcI2XMkb4u3tUvYO
# 9hGfn/wWb15OYMpxgRW6d5xsA+QNZwo2PzcH9GKg2SbhLX8lAmcRqJaXWnvouqFf
# B/j9iCOITMQERPHMQNUoEZd4qP/NL6Z6N0jg06RzpHrZCSoqmJ3I8QoMmHEAut+W
# /bQ5WdX5qGlAk5MGC0vZ8iUQHyXSzY94dndkhLA4hdZV5kZGXFxsgM54VrybNVqb
# qPW27L0JpSILmerFcxAw5iRDx4qwa6R1hgbYK948vgXutIX4Y3SUvhUBFaHClw9y
# VyfK6QRVcQE0ddAchCz0Whohf9lez8/jhs87CK5WFqbt/6ltRNNIT9KzwB8jSp6r
# QFaqGV40SotLrH4TnJA470tEeoIw8luB42783zWkEM6lj5wQk8M+JGAXGlvFwpiC
# bb3g7nC+R+I0PrnQ6SwWk8WTDlvd9FkwWzEHw+j/7oZ7voG6yTj4eaOP0Ve1NU3C
# KOK6n4KPyU1gEeI5RV4XuJPWSlbIyOg8NA1AaqA8lhYerQDb25x/dMAS/nuwrnIO
# P3ExggIVMIICEQIBATB0MF0xEjAQBgoJkiaJk/IsZAEZFgJ1azETMBEGCgmSJomT
# 8ixkARkWA2dvdjEZMBcGCgmSJomT8ixkARkWCW1ldG9mZmljZTEXMBUGA1UEAxMO
# TU8tSXNzdWluZy1DQTICEyoAAAgCQ6Kjpyc0V1kAAQAACAIwCQYFKw4DAhoFAKB4
# MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQB
# gjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkE
# MRYEFKhWjnFg4nfgbBlGgSJh1PhCbNBCMA0GCSqGSIb3DQEBAQUABIIBAF3m36/K
# EQLswKmYZILc41AfeltG1mftm9Sr4+I7OAqOWMTuhYRcn64IFYGZh0bUYIwcfW09
# Y/6sozEKEHhjphqPnPOcmkPXMPvYXl0OeuZeCfyNf3VhpKOp6b/oHJJVGPDBGFlh
# U89yho5I74UvruOHE2YXgv66HQu3X9wmvajLTtvgVCd3V8U+xOwChxXtWorBeSJA
# CYHeB+T5idSlXyDoiFccucOM9fOpc7XBhC86a6kvuMbwPQjJ8ZBZRCMb9aRjJ7z6
# nQspTeUI98Ri87vGh28ca3dUihRks8/Fg4J94I4qWHwpWiC2cjrqYCNxvZO6LI8u
# /qSNm/Gu4HFBs38=
# SIG # End signature block
