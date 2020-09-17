<#
.SYNOPSIS
  These functions can be used to manipulate vSphere licenses
  Many thanks to Michael Munk Lassen (@munklarsen - https://twitter.com/munklarsen) for below functions
.DESCRIPTION
  Below functions can
  - View Licenses
  - Add Licenses
  - Remove Licenses
  - Add custom named labels to vSphere licenses
  - Remove custom named labels
.INPUTS
  n/a 
.OUTPUTS
  Outputs to screen
.NOTES
  Website:	  www.amikkelsen.com
  Author:         Anders Mikkelsen
  Creation Date:  2019-01-28
  
  Known bugs:
	n/a
.EXAMPLE
  N/A
#>

function vSphere-LicenseView {
    param([string]$licenseKey)
    $servInstance = Get-View ServiceInstance
    $licenseManager = Get-View $servInstance.content.licenseManager
    
    if($licenseKey) {
        return $licenseManager.Licenses | Where-Object ({$_.LicenseKey -eq $licenseKey})
    } else {
        return $licenseManager.Licenses
    }
}

function vSphere-LicenseAdd {
    param([Parameter(Mandatory=$true)] [string]$licenseKey)
    $servInstance = Get-View ServiceInstance
    $licenseManager = Get-View $servInstance.content.licenseManager
    $licenseManager.AddLicense($licenseKey,$null)
}

function vSphere-LicenseRemove {
    param([Parameter(Mandatory=$true)] [string]$licenseKey)
    $licenseUsage = vSphere-LicenseView -licenseKey $licenseKey
    if($licenseUsage.Used -eq "0") {
        $servInstance = Get-View ServiceInstance
        $licenseManager = Get-View $servInstance.content.licenseManager
        $licenseManager.RemoveLicense($licenseKey)
    } else {
        return "Error: License in use"
    }
}

function vSphere-LicenseLabelSet {
    param([Parameter(Mandatory=$true)] [string]$licenseKey, [Parameter(Mandatory=$true)] [string]$licenseKeyLabelKey, [Parameter(Mandatory=$true)] [string]$licenseKeyLabelValue)
    $servInstance = Get-View ServiceInstance
    $licenseManager = Get-View $servInstance.content.licenseManager
    ($licenseManager.Licenses | Where-Object ({$_.LicenseKey -eq $licenseKey})).licenseKey
    $licenseManager.UpdateLicenseLabel(($licenseManager.Licenses | Where-Object ({$_.LicenseKey -eq $licenseKey})).licenseKey, $licenseKeyLabelKey, $licenseKeyLabelValue)
}

function vSphere-LicenseLabelRemove {
    param([Parameter(Mandatory=$true)] [string]$licenseKey, [Parameter(Mandatory=$true)] [string]$licenseKeyLabelKey)
    $servInstance = Get-View ServiceInstance
    $licenseManager = Get-View $servInstance.content.licenseManager
    ($licenseManager.Licenses | Where-Object ({$_.LicenseKey -eq $licenseKey})).licenseKey
    $licenseManager.RemoveLicenseLabel(($licenseManager.Licenses | Where-Object ({$_.LicenseKey -eq $licenseKey})).licenseKey, $licenseKeyLabelKey)
}


Connect-VIServer 192.168.1.200 -User "administrator@vsphere.local" -Password "xxxxxx"

  ## Uncomment the function you need and replace the licensekey "00000-00000-00000-00000-00000" with your own ##
  #vSphere-LicenseView
  #vSphere-LicenseView -licenseKey "00000-00000-00000-00000-00000"
  #vSphere-LicenseAdd -licenseKey "00000-00000-00000-00000-00000"
  #vSphere-LicenseRemove -licenseKey "00000-00000-00000-00000-00000"
  #vSphere-LicenseLabelSet -licenseKey "00000-00000-00000-00000-00000" -licenseKeyLabelKey "MyCustomNote" -licenseKeyLabelValue "TEST1234"
  #vSphere-LicenseLabelRemove -licenseKey "00000-00000-00000-00000-00000" -licenseKeyLabelKey "MyCustomNote"

Disconnect-VIServer -Confirm:$false
