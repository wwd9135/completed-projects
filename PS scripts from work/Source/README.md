Intune Firmware & Driver Patching Template
This repository provides a template for deploying firmware, driver, or software updates via Microsoft Intune.
How It Works

Place your update files in the Files folder.
Update the invoke-app script:

Modify the file paths and filenames to match your update package.


Compress the folder into a Win32 Intune package.
Upload the package as an Intune app and assign it to the desired device groups.

Key Notes
The main customization required is updating hardcoded file paths in the script to point to your specific update package.
This template has been successfully used across multiple devices and software updates.

