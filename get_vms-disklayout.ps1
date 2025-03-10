<#
.SYNOPSIS
    Script retrieves each VM's disklayout (via VMTools) and maps the OS mount-points to the corresponding virtual Harddisk
.DESCRIPTION
    Script retrieves each VM's disklayout (via VMTools) and maps the OS mount-points to the corresponding virtual Harddisk
.INPUTS
    N/A
.OUTPUTS
    Sorted list of VM's and their disklayout
.NOTES
    website:	    www.amikkelsen.com
    Author:         Anders Mikkelsen
    Creation Date:  2025-03-10
    
    Tested on vSphere 8.0U3
#>

# Variables
$vCenter = "<vCenter FQDN or IP>"

# Connect VI Server
Connect-VIServer -Server $vCenter

# Get VM list
$arrDiskLayout = @()
$arrVMs = Get-VM
ForEach ( $objVM in $arrVMs ) {
    Write-Host $objVM.Name -ForegroundColor Cyan
    $arrVMDisks = $null
    $arrVMDisks = $objVM | Get-VMGuestDisk
    Foreach ( $objVMDisk in $arrVMDisks ) {
        $tmpData = $objVMDisk | Select-Object DiskPath, @{ Name='CapacityGB'; Expression={ [math]::Round( $_.CapacityGB ,2 ) } }
        $objVMDK = $null
        $objVMDK = Get-HardDisk -VMGuestDisk $objVMDisk -ErrorAction:SilentlyContinue
        If ( $objVMDK ) {
            $tmpData | Add-Member -MemberType noteProperty -Name "DiskName" -Value $objVMDK.Name
            $tmpData | Add-Member -MemberType noteProperty -Name "Filename" -Value $objVMDK.Filename
            $tmpData | Add-Member -MemberType noteProperty -Name "Parent" -Value $objVMDK.Parent
            $tmpData | Add-Member -MemberType noteProperty -Name "ParentId" -Value ( $objVMDK.ParentId ).Replace("VirtualMachine-", "" )
            $tmpData | Add-Member -MemberType noteProperty -Name "VMDKCapacityGB" -Value $objVMDK.CapacityGB

            $arrDiskLayout += $tmpData | Sort-Object DiskPath
        }
    }
}

# Disconnect VI Server
DisConnect-VIServer -Server $vCenter -Confirm:$false -Force

# Display results
$arrDiskLayout | Select-Object Parent, ParentId, DiskPath, CapacityGB, DiskName, VMDKCapacityGB, Filename | Sort-Object Parent, DiskName, DiskPath 
