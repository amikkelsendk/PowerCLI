<#
  .SYNOPSIS
    Script resizes a partition, if it has been expanded with 1GB or more - sets to MAX size
  .DESCRIPTION
    Script resizes a partition, if it has been expanded with 1GB or more - sets to MAX size
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
    https://www.controlup.com/script-library-posts/extend-a-logical-disk-to-maximum-partition-size-for-that-volume/
#>

# Rescan Storage/Disks
Update-HostStorageCache

# Get list of disks
$arrDisks = Get-Disk | Where-object{$_.OperationalStatus -eq "Online" -and $_.PartitionStyle -eq "GPT"}

Foreach($objDisk In $arrDisks ){
  Write-Host "Disk: $($objDisk.Number)"
  $arrPartitions = $objDisk | Get-Partition

  Foreach( $objPartition In $arrPartitions){
    $thisPartitionDriveLetter = $objPartition.DriveLetter
    $thisPartitionDiskSize = $objPartition.Size
      
    If($thisPartitionDriveLetter){
      Write-Host "  DriveLetter:  $thisPartitionDriveLetter"
      Write-Host "  Current Size: $thisPartitionDiskSize"
      
      $thisPartitionDiskMaxSize = (Get-PartitionSupportedSize -DriveLetter $thisPartitionDriveLetter).SizeMax

      # Only if new size is 1GB larger 
      $thisSizeGB    = [math]::Round($thisPartitionDiskSize/1024/1024/1024, 2)
      $thisSizeMaxGB = [math]::Round($thisPartitionDiskMaxSize/1024/1024/1024, 2)

      If($thisSizeGB -lt $thisSizeMaxGB){
        # Resize partition to MAX
        Write-Host "  New size:     $thisPartitionDiskMaxSize"
        Resize-Partition -DriveLetter $thisPartitionDriveLetter -Size $thisPartitionDiskMaxSize -Confirm:$false
      }
    }
  }
}
