<#
Howto mount an ISO file from an Content Library
#>

## - Variables - ##
$vmName = "vm001"
$contentLibraryName = "ContentLibrary01"
$isoName = "isofile_name"       # With out "".iso"


## - Logic - ##
$objVM = Get-VM -Name $vmName 

$objConLib = Get-ContentLibrary -Name $contentLibraryName
$objConLibItem = Get-ContentLibraryItem -ContentLibrary $objConLib -Name $isoName -ItemType:iso

$objConLibDatastore = Get-Datastore -Name $objConLib.Datastore
New-PSDrive -Name DS -PSProvider VimDatastore -Root '\' -Location $objConLibDatastore | Out-Null
$strConLibItemIsoPath = Get-ChildItem -Path "DS:" -Recurse -Filter "$( $( $objConLibItem.Name ).Replace('.iso','') )*.iso" | Select-Object -ExpandProperty DatastoreFullPath | Where-Object {$_ -like "*$( $objConLibItem.Id )*" }
Remove-PSDrive -Name DS -Confirm:$false | Out-Null

## Mounting
$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
$change = New-Object VMware.Vim.VirtualDeviceConfigSpec
$change.Operation = [Vmware.vim.VirtualDeviceConfigSpecOperation]::edit
$dev = ( $objVM | Get-CDDrive ).ExtensionData
$dev.Backing = New-Object VMware.Vim.VirtualCdromIsoBackingInfo
$dev.Backing.FileName = $strConLibItemIsoPath
$change.Device += $dev
$change.Device.Connectable.Connected = $true
$change.Device.Connectable.StartConnected = $true
$spec.DeviceChange = $change
$objVM.ExtensionData.ReconstartfigVM( $spec )
