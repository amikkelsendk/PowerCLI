<#
  .SYNOPSIS
    Script initializes newly added disks on a Windows machine and formats them with maximum size
  .DESCRIPTION
    Script initializes newly added disks on a Windows machine and formats them with maximum size
  .INPUTS
    N/A
  .NOTES
    Author:         Anders Mikkelsen
    Creation Date:  2021-12-23
    GitHub:         https://github.com/amikkelsendk
    Twitter:        @AMikkelsenDK
    
    Tested on:
    - Windows Server 2019

    Requirements:
    Must run with administrative priviliges 

    Credits to:
    https://stackoverflow.com/questions/54564566/powershell-script-to-initialize-all-new-drives-format-and-give-them-labels-in
    https://4sysops.com/archives/managing-disks-with-powershell/
#>

# Rescan Storage/Disks
Update-HostStorageCache

# Get list of new disks
$arrNewDisks = Get-Disk | Where-Object{$_.OperationalStatus -eq "Offline" -and $_.PartitionStyle -eq "RAW"}

Foreach($objDisk In $arrNewDisks)
{
  # Get disk number
  $thisDiskNo = $objDisk.Number

  # Initialize / Create partition / Assign drive letter
  $objPartition = Get-Disk -Number $thisDiskNo | Initialize-Disk -PartitionStyle "GPT" -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize
  
  # Format partition
  Format-Volume -DriveLetter $objPartition.DriveLetter -FileSystem "NTFS" -NewFileSystemLabel "Disk $thisDiskNo" -Confirm:$false

}
