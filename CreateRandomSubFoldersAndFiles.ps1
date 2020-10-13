<#
.SYNOPSIS
  Script to generate test data. Random subfolders and random files pr folder
.DESCRIPTION
  Script to generate test data. Random subfolders and random files pr folder
.INPUTS
  n/a 
.OUTPUTS
  Execution time and file, folder & size info
.NOTES
  website:	      www.amikkelsen.com
  Author:         Anders Mikkelsen
  Creation Date:  2020-08-24
  
  1. Change $intMaxSubFolders, $intMaxFolderDepth & $intMaxFilesPrFolder accordingly
  2. Change $APP_INSTANCE_FOLDER or use $PSScriptRoot
  3. Add specific subfolders "$tmpAPP_INSTANCE_FOLDER"
  4. If needed change MAX file size - $randomFileSize
  
#>

Clear-Host

#$APP_INSTANCE_FOLDER = "C:\Scripts\Test-Data"
$APP_INSTANCE_FOLDER = $PSScriptRoot
$intFilesPrFolder = Get-Random -Minimum 1 -Maximum 3

$tmpAPP_INSTANCE_FOLDER = @("$APP_INSTANCE_FOLDER\log")
#$tmpAPP_INSTANCE_FOLDER += @("$APP_INSTANCE_FOLDER\tmp")

$stopwatch =  [system.diagnostics.stopwatch]::StartNew()

################# VARIABLES ############

$intMaxSubFolders    = 9
$intMaxFolderDepth   = 9
$intMaxFilesPrFolder = 50

########################################

$arrFolders = @()
$intTotalFileCount = 0
$intTotalFoldersCount = 0
$intTotalBytes = 0
$maxSubFolders = Get-Random -Minimum 1 -Maximum $intMaxSubFolders

foreach($folder in $tmpAPP_INSTANCE_FOLDER)
{
    # Generate subfolders
    for ($x=0;$x -lt $MaxSubFolders; $x++)
    {
        $maxDepth = Get-Random -Minimum 1 -Maximum $intMaxFolderDepth
        $thisPath = ""
        for ($xx=0;$xx -lt $maxDepth; $xx++)
        {
            $thisPath += "\$xx"            
        }
        $arrFolders += @("\$x$thisPath")
    }
    $maxDepth = $null

    # For each subfolder create random files in each
    foreach($newFolder in $arrFolders)
    {

        $thisFolderArray = $newFolder -split("\\")
        for ($i=0;$i -lt $thisFolderArray.Count; $i++)
        {
            $strTmp = ""
            for ($ii=0;$ii -le $i; $ii++)
            {
                if(($thisFolderArray[$ii]).length -gt 0 ){
                    $strTmp += "\"+$thisFolderArray[$ii]
                }
            }


            if($strTmp.Length -gt 0)
            {
                # Create Folder
                New-Item $folder$strTmp -Force -ItemType Directory | Out-Null
                $intTotalFoldersCount ++

                # Create Files
                $intFilesPrFolder = Get-Random -Minimum 1 -Maximum $intMaxFilesPrFolder
                for ($ii=0;$ii -lt $intFilesPrFolder; $ii++)
                {
                    $randomFileSize = Get-Random -Minimum 100 -Maximum (1024*1024)
                    $out = new-object byte[] $randomFileSize; 
                    (new-object Random).NextBytes($out); 
                    [IO.File]::WriteAllBytes("$folder$strTmp\filename_$ii.log", $out);
                    $intTotalFileCount ++
                    $intTotalBytes += $randomFileSize
                }
            }
        }
    } 
}


$stopwatch.Stop()
Write-Host $stopwatch.Elapsed -ForegroundColor Magenta
Write-Host "Total Files created:   $intTotalFileCount" -ForegroundColor Green
Write-Host "Total Folders created: $intTotalFoldersCount" -ForegroundColor Green
Write-Host "Total MB created:      $([math]::Round(($intTotalBytes/1MB),2))" -ForegroundColor Green