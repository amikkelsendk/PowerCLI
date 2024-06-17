<#
  .SYNOPSIS
    Script to bypass PowerShell multi-hop problem, without using CredSSP
    Can be used in VMware Automation Pipelines ("PowerShell" Tasks) (WinRM)
  .DESCRIPTION
    Script to bypass PowerShell multi-hop problem, without using CredSSP
  .INPUTS
    N/A
  .NOTES
    Author:         Anders Mikkelsen
    Creation Date:  2024-05-29
    GitHub:         https://github.com/amikkelsendk
    Twitter:        @AMikkelsenDK
    
    Tested on:
    - Windows Server 2019
    - VMware Automation 8.16.2
    - PowerShell 5.1 
    - PowerShell 7.4

    IMPORTANT !!!!
    Ensure WinRM HTTP & HTTPS is enabled
    Make sure UAC is disabled or set to "Never Notify" for the target script/util server

    Credits to:
    https://www.progress.com/blogs/the-infamous-double-hop-problem-in-powershell
    https://4sysops.com/archives/solve-the-powershell-multi-hop-problem-without-using-credssp/
    https://www.syxsense.com/syxsense-securityarticles/windows_policies/syx-1016-11188.html

    https://answers.microsoft.com/en-us/windows/forum/all/disable-uac-using-powershell/6f37a6f6-fedc-475d-ad4b-cf724d6d91bf
#>

#### Create a new Session Configuration ###
# Must be run/executed with administrative priviliges 
# Must be run for each PowerShell version you want to be able to conect with 5.1 &or 7.4 (run in each required console)
$SessionConfigName = "AdCheck"
$CredUserName = "<domain>\<username>"
Register-PSSessionConfiguration -Name $SessionConfigName -RunAsCredential $CredUserName -Force

# If above command produces an error - to Disable "Disallow WinRM from storing RunAs credentials", follow the link below
# https://www.syxsense.com/syxsense-securityarticles/windows_policies/syx-1016-11188.html


### Check if created and what PowerShell version it's configured under ###
Get-PSSessionConfiguration


### Test fix ###
# Create a file to test with 
# Example:
# Path:     c:\get_ad.ps1
# Content:  Get-ADDomainController

# Get Credentials
$MyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $CredUserName, $( Read-Host "Enter Password for user: $CredUserName" -AsSecureString |  ConvertFrom-SecureString )

# Run script via WinRM (should NOT work)
Invoke-Command -ComputerName localhost -Credential $MyCredential -ScriptBlock { powershell.exe -File "c:\get_ad.ps1" }

# Run script via WinRM (should work)
Invoke-Command -ComputerName localhost -Credential $MyCredential -ScriptBlock { powershell.exe -File "c:\get_ad.ps1" } -ConfigurationName $SessionConfigName
