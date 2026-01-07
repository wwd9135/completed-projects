This script contains relatively simple PowerShell code designed to reset identified weak passwords of windows AD user accounts.
Audit methods to deduce which accounts have weak passwords include the following official tools:
1/ Microsoft Security Compliance Toolkit 
2/ DSInternals PowerShell Module
3/ Find non official tools at own risk

**Important considerations:**
When using the stated audit methods it's important to not store this data in plain text or at all,
Users will ask advice on why their password is weak, dont oblige as this could be intercepted and allow the users account to be compromised.

Essential pre-requesites:
__main__.ps1 relies on 'Src' folder having correct input
Create a CSV of the users AD username & email in two simple columns, add to Src Data.csv

After this in place the script will immediately enable 'Change password at next logon' on all accounts inside Data.csv, and provide a list of successful 
and unsuccessful additions, review this carefully, naturally if you were to audit a thousand devices like this script was designed for, then you would come across
servers & locked prod accounts etc perhaps 1-3% of accounts wont be resetted.
