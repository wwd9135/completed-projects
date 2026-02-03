# Cred-Audit-Toolkit: Local Password & Policy Auditor

This repository contains two PowerShell-based tools designed to audit local account security, password complexity, and credential hygiene on Windows endpoints. It is intended for System Administrators to identify "low-hanging fruit" vulnerabilities that could lead to lateral movement.

## Security Audit Logic
AuditPreRequisites.ps1 is designed to perform basic security audit checks, I wont include the full script my company uses to audit as it's tech stack specific, but this gives an idea, use a script to loop through AD/ entra devices, perform a non-destructive audit of the local Security Accounts Manager (SAM) and evaluates system configurations against common attack vectors:
* **Password Age Analysis:** Identifies stale accounts that haven't rotated credentials in 90+ days.
* **Administrative Enumeration:** Lists all accounts with local `Administrator` privileges to detect "Admin sprawl."
* **Reversible Encryption Check:** Queries the registry to ensure `ClearTextPassword` storage is disabled.
* **Policy Compliance:** Compares local `MinimumPasswordLength` and `PasswordHistoryCount` against the Organization's baseline.

From here run the AuditAction.ps1:
* **

## Usage
> **Note:** This script requires **Administrator** privileges to query high-integrity registry keys and account metadata.

```powershell
# 1. Open PowerShell as Administrator
# 2. Bypass execution policy for the current session
Set-ExecutionPolicy Bypass -Scope Process

# 3. Run the audit
.\PasswordAudit.ps1
