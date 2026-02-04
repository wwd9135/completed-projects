# Overview
Combination of KQL queries for defender to identify devices missing patches & create an exportable list of their IP addresses & Device Names.
A powerShell script that pings each of these devices, To be used in combination with IntuneComplianceCheck script.
The outcome of this combination is checking a device has network access, is present in intune, gather relevant data regarding last update times etc to plan next steps.

Future steps:
Create a script to utilize the ServiceNow connector to Graph, then we can have Defender- Intune- serviceNow data being collected and will remove a lot of the manual labour needed to cross reference between devices.

