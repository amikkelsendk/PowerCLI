# https://www.jonathanmedd.net/2013/07/clone-a-vm-from-a-snapshot-using-powercli.html
# https://communities.vmware.com/t5/VMware-PowerCLI-Discussions/Cloning-a-VM-from-a-snapshot/td-p/1786675
# Clone issue
# https://communities.vmware.com/t5/VMware-vSphere-Discussions/Clone-VM-and-Retain-its-Snapshot/td-p/2246885

$strvCenter         = "<source vcenter fqdn>"
$strSourceVMName    = "VM001"
$strSourceSnapName  = "001"
$strTargetVMName    = "VM002"



Connect-VIServer -Server $strvCenter


$objSourceVM        = Get-VM -Name $strVMName
$objSourceSnap      = Get-Snapshot -VM $objSourceVM -Name $strSourceSnapName
$objSourceCluster   = Get-Cluster -VM $objSourceVM
$objSourceVMHost    = Get-VMHost -Name $objSourceVM.VMHost
$objSourceDatastore = Get-Datastore -Id ( $objSourceVM.DatastoreIdList  | Select-Object -First 1 )

$strTargetPortGroup = ( $objSourceVM | Get-NetworkAdapter )[0].NetworkName      # Expects only 1 NIC
$objTargetPortGroup = Get-VDPortgroup -Name $strTargetPortGroup -VDSwitch ( $objSourceVMHost | Get-VDSwitch )


## Clone VM
# Create LinkedClone VM based on specific Snapshot
$objTargetLinkedCloneVM = New-VM -Name "$( $objSourceSnap.VM.Name )-linkedClone" -VMHost $objSourceSnap.VM.VMHost -VM $objSourceSnap.VM -ReferenceSnapshot $objSourceSnap -LinkedClone

# Create VM based on a LinkedClone (Convert VM from LinkedClone to a VM)
$objTargetCloneVM = New-VM -Name $strTargetVMName -VMHost $objSourceSnap.VM.VMHost -VM $objTargetLinkedCloneVM

# Remove LinkedClone
Remove-VM -VM "$( $objSourceSnap.VM.Name )-linkedClone" -DeletePermanently -Confirm:$false
