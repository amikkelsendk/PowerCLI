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

$strvCenter     = "<vcenter server>"
$strSDRSCluster = "<SDRS cluster name>"

connect-viserver $strvCenter

#$StoragePod = Get-View -ViewType "StoragePod" -Filter @{"Name" = $strSDRSCluster}              # Without RegEx anchor points, filter acts like a wildcard
$StoragePod = Get-View -ViewType "StoragePod" -Filter @{"Name" = "^$strSDRSCluster$"}           # RegEx anchor points added, for Exact Match
#$StoragePod.PodStorageDrsEntry.StorageDrsConfig.VmConfig

if($StoragePod.Count -eq 1)
{
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
}
else{
    Write-Host "Found $($StoragePod.Count) storage clusters... Only expection 1" -ForegroundColor Red
}

disconnect-viserver * -confirm:$false