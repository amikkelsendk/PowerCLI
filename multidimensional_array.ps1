<#
.SYNOPSIS
  Demonstrates how to create an Multidimensional array
.DESCRIPTION
  Demonstrates how to create an Multidimensional array
.INPUTS
  n/a 
.OUTPUTS
  Outputs to screen
.NOTES
  website:	      www.amikkelsen.com
  Author:         Anders Mikkelsen
  Creation Date:  2019-02-25
  
  Known bugs:
	n/a
.EXAMPLE
  N/A
#>

CLS

## Pre Powershell version 3.0
$arrMulti = @(
    New-Object PSObject -Property @{Name = "Dennis";  City = "New York"; Size = "M"}
    New-Object PSObject -Property @{Name = "Kenneth"; City = "Chicago"; Size = "S"}
)
#write $arrMulti

## Powershell version 3.0 and newer
$arrMultiNew = @(
    [PSCustomObject]@{Name = "Dennis";  City = "New York"; Size = "M"}
    [PSCustomObject]@{Name = "Kenneth"; City = "Chicago"; Size = "S"}
)
write $arrMultiNew