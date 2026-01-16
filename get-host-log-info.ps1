<#
.SYNOPSIS
  Script shows host logging info
.DESCRIPTION
  Script shows host logging info
.INPUTS
  N/A
.OUTPUTS
  Host logging info
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
    
    $arrOutput += [PSCustomObject]@{
        Host            = $objVMHost.Name; 
        VpxaLogLevel    = ($objVMHost | Get-AdvancedSetting -Name "Vpx.Vpxa.config.log.level").Value; 
        SyslogLogLevel  = ($objVMHost | Get-AdvancedSetting -Name "Syslog.global.logLevel").Value; 
        SyslogLogHost   = ($objVMHost | Get-AdvancedSetting -Name "Syslog.global.logHost").Value; 
        SyslogLogDir    = ($objVMHost | Get-AdvancedSetting -Name "Syslog.global.logDir").Value; 
        SyslogLogRotate = ($objVMHost | Get-AdvancedSetting -Name "Syslog.global.defaultRotate").Value; 
        SyslogLogSize   = ($objVMHost | Get-AdvancedSetting -Name "Syslog.global.defaultSize").Value; 
    }
}

Disconnect-VIServer -Server $server -Confirm:$false -Force

$arrOutput | ft
