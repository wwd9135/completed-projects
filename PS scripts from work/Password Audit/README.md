# Cred-Audit-Toolkit: Local Password & Policy Auditor

This repository contains a collection of PowerShell-based tools designed to audit local account security, password complexity, and credential hygiene on Windows endpoints. It is intended for Blue Teamers and System Administrators to identify "low-hanging fruit" vulnerabilities that could lead to lateral movement.



## Security Audit Logic
The script performs a non-destructive audit of the local Security Accounts Manager (SAM) and evaluates system configurations against common attack vectors:

* **Password Age Analysis:** Identifies stale accounts that haven't rotated credentials in 90+ days.
* **Administrative Enumeration:** Lists all accounts with local `Administrator` privileges to detect "Admin sprawl."
* **Reversible Encryption Check:** Queries the registry to ensure `ClearTextPassword` storage is disabled.
* **Policy Compliance:** Compares local `MinimumPasswordLength` and `PasswordHistoryCount` against the Organization's baseline.

## 🚀 Usage

> **Note:** This script requires **Administrator** privileges to query high-integrity registry keys and account metadata.

```powershell
# 1. Open PowerShell as Administrator
# 2. Bypass execution policy for the current session
Set-ExecutionPolicy Bypass -Scope Process

# 3. Run the audit
.\PasswordAudit.ps1
