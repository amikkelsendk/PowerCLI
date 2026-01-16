<#
.SYNOPSIS
  Script shows host NTP & TimeDate info
.DESCRIPTION
  Script shows host NTP & TimeDate info
.INPUTS
  N/A
.OUTPUTS
  Host NTP & TimeDate info
.NOTES
  website:	      www.amikkelsen.com
  Author:         Anders Mikkelsen
  Creation Date:  2025-12-03
  
  Tested on vSphere 7.x, 8.x
#>

$server = "<vcsa01.yourdomain.dom>"

Connect-VIServer -Server $server

Clear-Host

$arrOutput = @()

$arrVMHosts = Get-VMHost | Sort-Object Name

Foreach ( $objVMHost in $arrVMHosts ) {
    
    $objNtpService  = $objVMHost | Get-VmHostService | Where-Object { $_.key -eq "ntpd" }
    $objNtpFirewall = $objVMHost | Get-VMHostFirewallException | Where-Object { $_.Name -eq "NTP client" }
    $morefDateTime  = Get-View $objVMHost.ExtensionData.ConfigManager.DateTimeSystem

    $arrOutput += [PSCustomObject]@{
        Host               = $objVMHost.Name;
        DateTime           = $morefDateTime.QueryDateTime();
        TimeZone           = $morefDateTime.DateTimeInfo.TimeZone.Name;
        NtpServer          = $objVMHost | Get-VMHostNtpServer; 
        NtpServiceRunning  = $objNtpService.Running; 
        NtpServicePolicy   = $objNtpService.Policy; 
        NtpFirewallEnabled = $objNtpFirewall.Enabled; 
        #NtpServiceRunning  = $objNtpFirewall.ServiceRunning;
    }

    $objNtpService  = $null
    $objNtpFirewall = $null
    $morefDateTime  = $null
}

Disconnect-VIServer -Server $server -Confirm:$false -Force

$arrOutput | FT -AutoSize
