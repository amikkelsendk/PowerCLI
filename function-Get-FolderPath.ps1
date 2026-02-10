<#
.SYNOPSIS
    Get the full folder path of a list of VMs
.DESCRIPTION
    Get the full folder path of a list of VMs
.INPUTS
    n/a 
.OUTPUTS
    Outputs to screen
.NOTES
    Website:	    www.amikkelsen.com
    Author:         Anders Mikkelsen
    Creation Date:  2026-02-10
    
.EXAMPLE
    Get-VM | Get-VMFolderPath | Format-Table -AutoSize
    Get-VMFolderPath -VM ( Get-VM -Name "<vmname>" )
#>


Function Get-VMFolderPath {
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true )]
        [VMware.VimAutomation.ViCore.Impl.V1.VM.UniversalVirtualMachineImpl[]] $VM
    )

    Process {
        Foreach ( $objVM in $VM ) {
            $folder = $objVM.Folder
            $pathParts = @()

            # Walk up the folder hierarchy
            While ( $folder -and $folder.Name -ne "vm") {
                $pathParts += $folder.Name
                $folder = $folder.Parent
            }

            # Reverse to get root-to-leaf order
            $fullPath = ( $pathParts | Sort-Object -Descending ) -join "/"

            [PSCustomObject]@{
                VMName     = $objVM.Name
                FolderPath = $fullPath
            }
        }
    }
}
