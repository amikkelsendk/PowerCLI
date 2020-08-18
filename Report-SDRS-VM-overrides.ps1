<#
.SYNOPSIS
  Reports on VM where SDRS overrides are configured 
.DESCRIPTION
  Reports on VM where SDRS overrides are configured 
.INPUTS
  n/a 
.OUTPUTS
  Outputs to screen
.NOTES
  website:	      www.amikkelsen.com
  Author:         Anders Mikkelsen
  Creation Date:  2020-08-18
  
  Tested on vSphere 6.7 U3
	
  1. Change <vcenter server> to you own vCenter
  2. Change <SDRS cluster name> to your own SDRS cluster
  
  Thanks to Ryanjan
  https://ryanjan.uk/2018/07/30/storage-drs-and-powercli-part-1-get-vm-overrides/
#>

cls
connect-viserver <vcenter>

$StoragePod = Get-View -ViewType "StoragePod" -Filter @{"Name" = "<SDRS cluster name>"}
#$StoragePod.PodStorageDrsEntry.StorageDrsConfig.VmConfig

$VMOverrides = $StoragePod.PodStorageDrsEntry.StorageDrsConfig.VmConfig | Where-Object {
    -not (
        ($_.Enabled -eq $null) -and
        ($_.IntraVmAffinity -eq $null)
    )
}

Switch ($StoragePod.PodStorageDrsEntry.StorageDrsConfig.PodConfig.DefaultVmBehavior) {
    "automated" {$DefaultVmBehavior = "Default (Fully Automated)"}
    "manual" {$DefaultVmBehavior = "Default (No Automation (Manual Mode))"}
}

Switch ($StoragePod.PodStorageDrsEntry.StorageDrsConfig.PodConfig.DefaultIntraVmAffinity) {
    $true {$DefaultIntraVmAffinity = "Default (Yes)"}
    $false {$DefaultIntraVmAffinity = "Default (No)"}
}

foreach ($Override in $VMOverrides) {
    [PSCustomObject]@{
        VirtualMachine = (Get-VM -Id $Override.Vm).Name 
        SDRSAutomationLevel = Switch ($Override.Enabled) {
            $true {"Fully Automated"}
            $false {"Disabled"}
            $null {$DefaultVmBehavior}
        }
        KeepVMDKsTogether = Switch ($Override.IntraVmAffinity) {
            $true {"Yes"}
            $false {"No"}
            $null {$DefaultIntraVmAffinity}
        }
    }
}

disconnect-viserver * -confirm:$false