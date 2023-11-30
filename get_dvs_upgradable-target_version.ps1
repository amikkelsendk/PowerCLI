<#
    .SYNOPSIS
    Find what version a DVS can be upgraded to
    .DESCRIPTION
    Find what version a DVS can be upgraded to
    .INPUTS
    n/a 
    .OUTPUTS
    Outputs to screen
    .NOTES
    website:        www.amikkelsen.com
    Author:         Anders Mikkelsen
    Creation Date:  2023-11-20
    
    Tested on vSphere 8.0 U1
        
#>


# Get DVS target version

$Error.Clear()

$objDVS = Get-VDSwitch -Name "DSwitch"
$objDVS | Set-VDSwitch -Version "*" -ErrorAction:SilentlyContinue

If ( $Error.Count -ne 0 ) {
    $vdsError = $Error | Where-Object { $_ -like "*Set-VDSwitch*" } | Select-Object -First 1
    If ( $vdsError ) {
        $targetVer = $vdsError -Split "," | Select-Object -Last 1
        $targetVer = $targetVer.Trim()
        If ( $targetVer[$($targetVer.Length -1)] -eq "." ) {
            $targetVer = $targetVer.Substring(0, $targetVer.Length - 1)
        }
    }
}

Write-Host "Current version: $( $objDVS.Version )"
Write-Host "Target version:  $targetVer"

#Write-Host $vdsError 
