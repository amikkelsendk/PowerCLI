<#
.SYNOPSIS
  Script shows VM count per OS
.DESCRIPTION
  Script shows VM count per OS
.INPUTS
  N/A
.OUTPUTS
  OS Count
.NOTES
  website:	      www.amikkelsen.com
  Author:         Anders Mikkelsen
  Creation Date:  2025-11-27
  
  Tested on vSphere 7.x, 8.x
#>

$server = "<vcsa01.yourdomain.dom>"

Connect-VIServer -Server $server

Get-VM -Server $Server | Select-Object -Property @{N="Configured OS";E={$_.ExtensionData.Config.GuestFullName}} | Group-Object "Configured OS" | Select-Object Count, Name

Disconnect-VIServer -Server $server -Confirm:$false -Force
