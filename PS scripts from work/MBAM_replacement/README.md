MBAM Replacement Solution:
This project provides a modern replacement for Microsoft BitLocker Administration and Monitoring (MBAM), which will be deprecated in July 2026.

Key Features
Enhanced Security:
Custom GUI enforcing stricter password hygiene than native Microsoft tools (e.g., manage-bde or changeBdePin.exe).
Supports enhanced PIN complexity, length requirements, and checks for weak password patterns.

Audited for Security:
The script has undergone a security review to ensure compliance and robustness.

Architecture
Deployment:
Uses PowerShell App Deployment Toolkit (PSADT) as a wrapper for seamless Intune deployment.

Core Logic:
Main functionality resides in Files/mod.psm1, which contains the GUI and complexity validation logic.

Integration:
Fully implementable via Intune:
As an automatic rollout feature.
Or as an on-demand app available in the Company Portal.
