# MBAM-Replacement-Solution

A modern BitLocker administration and PIN management framework designed to replace Microsoft BitLocker Administration and Monitoring (MBAM) ahead of its **July 2026 deprecation**.

This solution provides a custom GUI for end-user PIN management while enforcing security complexity requirements that exceed the native capabilities of `manage-bde.exe` or `changeBdePin.exe`.


## Architecture & Core Logic

The solution is decoupled into a modular framework for better maintainability and security auditing:

* **Logic Engine (`Files/mod.psm1`):** A PowerShell module containing the primary GUI code and the validation regex for PIN complexity.
* **Wrapper:** Utilizes the **PowerShell App Deployment Toolkit (PSADT)** to handle Intune installation states and user interaction.
* **Validation:** Implements checks for:
    * Minimum/Maximum PIN length.
    * Enhanced PIN complexity (preventing sequential or repeating patterns).
    * Validation against known weak/common PIN lists.

## Deployment Options

The project is optimized for **Microsoft Intune** deployment using the Win32 app model:

1.  **Automatic Rollout:** Force-deployed to devices missing recovery keys or failing compliance.
2.  **Self-Service:** Published to the **Company Portal**, allowing users to rotate their own PINs without calling the Helpdesk.

## Security Audit & Compliance

Unlike the native Windows "Change PIN" UI, this tool was built with a focus on compliance-driven environments:

* **Hardened Input:** Sanitizes user input to prevent command injection during the `manage-bde` handoff.
* **Audit Logging:** Logs attempts and validation failures to local event logs for SIEM ingestion.
* **Deprecation Readiness:** Specifically engineered to provide parity with MBAM features (Key Rotation, PIN enforcement) that are being phased out by Microsoft.

## Repository Structure

```text
├── AppDeployToolkit/    # PSADT core files
├── Files/
│   └── mod.psm1         # Core Module (GUI & Validation)
├── Deploy-Application.ps1 # Entry point for Intune
└── README.md

## Usage
To deploy via Intune, package the root folder into an .intunewin file using Deploy-Application.exe as the install command.
