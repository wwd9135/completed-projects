# 🔐 MBAM Replacement Project

## Overview
Microsoft BitLocker Administration and Monitoring (MBAM) has transitioned to a legacy solution. Historically, MBAM streamlined BitLocker procedures by allowing users to reset PINs without requiring local administrative rights, significantly reducing help desk overhead.

## The Challenge
The deprecation of MBAM without a direct native replacement introduced several critical gaps:
* **User Self-Service:** No method for users to self-reset forgotten BitLocker PINs.
* **Build Process Failures:** No streamlined way to reset PINs when issues occur during the initial device imaging/build phase.
* **Privilege Management:** No standardized method to reset PINs without an administrative account being logged into the remote device.

## Project Solution
I developed a custom GUI-based solution to replace MBAM functionality. This tool consolidated **seven legacy scripts** into a single, unified application that is now part of the standard operating procedure for Help Desk and IT Desk teams.

### Deployment Architecture
* **Packaging:** The application is packaged as a **Win32 app** using the **PSADT4** (PowerShell App Deployment Toolkit) framework.
* **Delivery:** Deployed via **Microsoft Intune**.
* **Automation:** Triggered as a mandatory installation or on-demand repair using specific Intune detection and requirement scripts.
* **Security:** The solution underwent a formal security audit to ensure no vulnerabilities were introduced to the endpoint.

## Technical Composition
The package logic is organized into three primary tiers:

1. **PSADT4 Framework:** Manages the deployment lifecycle, performs environment pre-checks, and handles installation stages.
2. **GUI Logic (`mod.psm1`):** A custom Windows Forms interface designed to capture user input and provide real-time feedback.
3. **Complexity Logic (`mod.psm1`):** A robust validation engine that enforces PIN security policies, including:
    * **Enhanced Character Checks:** Requirements for two or more character types.
    * **Pattern Filtering:** Identifies and blocks sequential (1234) or repeating (1111) numbers.
    * **Dictionary Filtering:** Checks against a "black-list" of known weak or common PINs.
    * **Length Requirements:** Enforces minimum/maximum character counts.

## Limitations
* **Environment Specific:** The logic is optimized specifically for **PSADT4** and **Intune** workflows.
* **Hardware Requirements:** Requires a **TPM + PIN** configuration. It is not intended for environments using only TPM or Windows Hello for Business.

## Security & Defense in Depth
This application contributes to an organization's **Defense in Depth** strategy by:
* Reducing the need for Local Admin account sprawl.
* Preventing the bypass or abuse of help desk procedures.
* Enforcing cryptographic best practices through automated complexity checks.

> [!TIP]
> To maximize effectiveness, pair this tool with a verified identity challenge-response procedure at the Help Desk to prevent social engineering attacks during PIN resets.