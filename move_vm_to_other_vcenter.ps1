# https://www.jonathanmedd.net/2013/07/clone-a-vm-from-a-snapshot-using-powercli.html
# https://communities.vmware.com/t5/VMware-PowerCLI-Discussions/Cloning-a-VM-from-a-snapshot/td-p/1786675
# Clone issue
# https://communities.vmware.com/t5/VMware-vSphere-Discussions/Clone-VM-and-Retain-its-Snapshot/td-p/2246885

$strSourcevCenter   = "<source vcenter fqdn>"
$strSourceVMName    = "CloneTest01"
$strSourceSnapName  = "001"

$strTargetvCenter   = "<target vcenter fqdn>"
$strTargetPortGroup = "VLAN2022"
$objTargetCluster   = "Cluster01"


## SOURCE
$objSourceVC        = Connect-VIServer -Server $strSourcevCenter
$objSourceVM        = Get-VM -Name $strSourceVMName -Server $objSourceVC
$objSourceSnap      = Get-Snapshot -VM $objSourceVM -Name $strSourceSnapName -Server $objSourceVC
$objSourceCluster   = Get-Cluster -VM $objSourceVM -Server $objSourceVC
$objSourceVMHost    = Get-VMHost -Name $objSourceVM.VMHost -Server $objSourceVC
$objSourceDatastore = Get-Datastore -Id ( $objSourceVM.DatastoreIdList  | Select-Object -First 1 ) -Server $objSourceVC


## TARGET
$objTargetVC        = Connect-VIServer -Server $strTargetvCenter
$objTargetCluster   = Get-Cluster -Name $objTargetCluster -Server $objTargetVC
$objTargetVMHost    = ( $objTargetCluster | Get-VMHost -Server $objTargetVC  | Get-Random )
$objTargetDatastore = $objTargetCluster | Get-Datastore -name "vsanDatastore SSD Storage" -Server $objTargetVC
$objTargetPortGroup = Get-VDPortgroup -Name $strTargetPortGroup -VDSwitch ( $objTargetVMHost | Get-VDSwitch ) -Server $objTargetVC


## MOVE VM
# Create LinkedClone VM based on spwcific Snapshot
$objTargetLinkedCloneVM = New-VM -Name "$( $objSourceSnap.VM.Name )-linkedClone" -VMHost $objSourceSnap.VM.VMHost -VM $objSourceSnap.VM -ReferenceSnapshot $objSourceSnap -LinkedClone -Server $objSourceVC
# Create VM based on a LinkedClone (Convert VM from LinkedClone to a VM)
$objTargetCloneVM = New-VM -Name "$( $objSourceSnap.VM.Name )-Clone" -VMHost $objSourceSnap.VM.VMHost -VM $objTargetLinkedCloneVM -Server $objSourceVC
Remove-VM -VM "$( $objSourceSnap.VM.Name )-linkedClone" -DeletePermanently -Confirm:$false -Server $objSourceVC
# Move Cloned VM to target vCenter
$splatMoveVM = @{
    VM             = $objTargetCloneVM
    NetworkAdapter = ( $objTargetCloneVM | Get-NetworkAdapter )
    PortGroup      = $objTargetPortGroup
    Destination    = $objTargetVMHost
    Datastore      = $objTargetDatastore
}
Move-VM @splatMoveVM


## RESULT 
# ==> NO SNAPSHOTS RETAINED when CLONING
# ==> SNAPSHOTS RETAINED during MOVE 
