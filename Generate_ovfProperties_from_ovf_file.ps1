<#
.SYNOPSIS
    Script generates the ovfProperties, needed for VCF Automation BluePrints (Cloud Templates) .
    It will populate any default values
.DESCRIPTION
    Script generates the ovfProperties, needed for VCF Automation BluePrints (Cloud Templates) .
    It will populate any default values
.INPUTS
     N/A
.OUTPUTS
    To screen, can be copyed and pasted into VCF Automation
.NOTES
  website:	      www.amikkelsen.com
  Author:         Anders Mikkelsen
  Creation Date:  2025-04-14
  
  Tested on:
  - vSphere 8
  - VCF Automaton 8.18.x
#>


# Connect vCenter
Connect-VIServer "<your vcenter>"

# Get OVA/OVF congig
$ovfConfig = Get-OvfConfiguration "<full path to ova/ovf>"

# Create output
$strOutput = "ovfProperties:"
Foreach ( $common in $ovfConfig.Common.psobject.Properties ) {
    $thisKey = $ovfConfig.Common.$($common.name).Key
    $thisValue = $ovfConfig.Common.$($common.name).DefaultValue
    $strOutput += "`n    - key:   $thisKey"
    $strOutput += "`n    - value: '$thisValue'"
}
$strOutput

# Disconnect vCenter
Disconnect-VIServer * -Confirm:$false
