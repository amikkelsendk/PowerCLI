<#
.SYNOPSIS
  Commands to configure VMHost settings
.DESCRIPTION
  Commands to configure VMHost settings
.INPUTS
  N/A
.OUTPUTS
  N/A
.NOTES
  website:	      www.amikkelsen.com
  Author:         Anders Mikkelsen
  Creation Date:  2024-07-22
  
  Tested on vSphere 8

  Credits to:
  - https://captainvops.com

#>

#############
## - NTP - ##
#############
# Get
Get-VMHost | Sort-Object Name | Select-Object Name, @{N=”Cluster”;E={$_ | Get-Cluster}}, @{N=”Datacenter”;E={$_ | Get-Datacenter}}, @{N=“NTPServiceRunning“;E={($_ | Get-VmHostService | Where-Object {$_.key-eq “ntpd“}).Running}}, @{N="IncomingPorts";E={($_ | Get-VMHostFirewallException | Where-Object {$_.Name -eq "NTP client"}).IncomingPorts}}, @{N="OutgoingPorts";E={($_ | Get-VMHostFirewallException | Where-Object {$_.Name -eq "NTP client"}).OutgoingPorts}}, @{N="Protocols";E={($_ | Get-VMHostFirewallException | Where-Object {$_.Name -eq "NTP client"}).Protocols}}, @{N=“StartupPolicy“;E={($_ | Get-VmHostService | Where-Object {$_.key-eq “ntpd“}).Policy}}, @{N=“NTPServers“;E={$_ | Get-VMHostNtpServer}}, @{N="Date&Time";E={(get-view $_.ExtensionData.configManager.DateTimeSystem).QueryDateTime()}} | format-table -autosize

# Add NTP server
Get-VMHost | Add-VMHostNtpServer -NtpServer "pool.ntp.org"

# Remove NTP server
Get-VMHost | Remove-VMHostNtpServer -NtpServer "pool.ntp.org" -Confirm:$false

# Set service startup
# on        = Start and stop with host
# off       = start and stop manually
# automatic = start and stop with port usage
Get-VMHost | Get-VmHostService | Where-Object {$_.key -eq "ntpd"} | Set-VMHostService -policy "on"

# Replace all current NTP servers and updating firewall & startup type, incl stopping an starting NTPD service
$newNTPServers    = ("pool.ntp.org")
$newServicePolicy = "on"
Get-VMHost |  Where-Object { $_.ConnectionState -eq "Connected" } | ForEach-Object {
  $thisHost = $_
  Write-Host "Updating: $thisHost" -ForegroundColor Cyan
  $thisHostNtpList = $thisHost | Get-VMHostNtpServer
  $thisHost | Get-VMHostService | Where-Object { $_.key -eq "ntpd" } | Stop-VMHostService -Confirm:$false
  $thisHost | Remove-VMHostNtpServer -NtpServer $thisHostNtpList -Confirm:$false
  $thisHost | Add-VMHostNtpServer -NtpServer $newNTPServers -WarningAction:SilentlyContinue
  $thisHost | Get-VmHostService | Where-Object { $_.key -eq "ntpd" } | Set-VMHostService -Policy $newServicePolicy 
  $thisHost | Get-VMHostFirewallException | Where-Object { $_.Name -eq "NTP client" } | Set-VMHostFirewallException -Enabled:$true 
  $thisHost | Get-VMHostService | Where-Object { $_.key -eq "ntpd" } | Start-VMHostService
}
