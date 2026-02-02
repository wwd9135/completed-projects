# overview
A lightweight, standalone PowerShell utility designed for SysAdmins and Security Analysts to diagnose Windows Update failures and verify system component integrity.

Unlike generic troubleshooters, this script queries the Windows Event Log (Provider: WindowsUpdateClient) to extract specific HRESULT error codes and maps them to known root causes such as proxy blocks, permission denials, or component store corruption.

## Features
-Service Health Audit: Verifies the status of wuauserv, bits, cryptsvc, and trustedinstaller.
- Event Log Parsing: Extracts the last 5 failure events directly from the System log to identify specific Hex error codes.
- HRESULT Translation: Built-in logic to interpret common codes like 0x80244017 (Proxy/Auth) and 0x80073712 (CBS Corruption).
- Component Store Check: Inspects the Registry for pending repair flags or "Reboot Pending" states that block update orchestration.
- Environment Validation: Checks for disk space thresholds and system-level blockers.
## Installation & Usage
- Clone the repository:
  Bashgit clone https://github.com/YOUR-USERNAME/WinUpdate-Diagnostic-Tool.git
  cd WinUpdate-Diagnostic-Tool
- Execution:The script requires administrative privileges to query the System Event Logs and Service Manager.
  Run from an elevated PowerShell prompt:PowerShellSet-ExecutionPolicy Bypass -Scope Process
.\WUDT.ps1
## Why this is useful for Security
From a security perspective, an unpatched system is a vulnerable system. Windows Update failures are often the first sign of:

- Malware Persistence: Certain strains disable wuauserv to prevent security patches.
- Network Interference: Improperly configured Egress filters or Man-in-the-Middle (MitM) proxies often break the Windows Update handshake.
- Disk Exhaustion: A common vector for Denial of Service (DoS) at the endpoint level.
