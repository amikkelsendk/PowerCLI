<#
.SYNOPSIS
  Re-Enable SDRS on all VMs associated with a SDRS cluster 
.DESCRIPTION
  Reset overrides for SDRSAutomationLevel & KeepVMDKsTogether.
  SDRS must be enabled set to FullyAutomated for it to loadbalance VMs on SDRS datastores
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
  
  Thanks to Ryanjan & Vikas Shitole
  https://ryanjan.uk/2018/07/30/storage-drs-and-powercli-part-1-get-vm-overrides/
  https://github.com/vThinkBeyondVM/vThinkBVM-scripts/blob/master/Powershell-PowerCLI/SDRSVmOverrides.ps1
#>


cls
connect-viserver <vcenter server>

$StoragePod = Get-View -ViewType "StoragePod" -Filter @{"Name" = "<SDRS cluster name>"}
#$StoragePod.PodStorageDrsEntry.StorageDrsConfig.VmConfig

$VMOverrides = $StoragePod.PodStorageDrsEntry.StorageDrsConfig.VmConfig | Where-Object {
    -not (
        ($_.Enabled -eq $null) -and
        ($_.IntraVmAffinity -eq $null)
    )
}

foreach ($Override in $VMOverrides) {
    $row = '' | select VMName
	$vmMo = Get-View $Override.Vm

    if($Override.Enabled -ne $null){
	    $spec = New-Object VMware.Vim.StorageDrsConfigSpec
	    $spec.vmConfigSpec = New-Object VMware.Vim.StorageDrsVmConfigSpec[] (1)
	    $spec.vmConfigSpec[0] = New-Object VMware.Vim.StorageDrsVmConfigSpec
	    $spec.vmConfigSpec[0].operation = 'add'
	    $spec.vmConfigSpec[0].info = New-Object VMware.Vim.StorageDrsVmConfigInfo
        $spec.vmConfigSpec[0].info.enabled = $null
	    $spec.vmConfigSpec[0].info.vm = $Override.Vm;
        $spec.vmConfigSpec[0].info.IntraVmAffinity = $null;
	    $_this = Get-View -Id 'StorageResourceManager-StorageResourceManager'
        $_this.ConfigureStorageDrsForPod_Task($StoragePod.MoRef, $spec, $true)
	    Write-Host "SDRS is re-enabled on this VM :" $vmMo.Name 
    }
    else{
        Write-Host "SDRS was already set to Default on VM :" $vmMo.Name 
	}
}

disconnect-viserver * -confirm:$false