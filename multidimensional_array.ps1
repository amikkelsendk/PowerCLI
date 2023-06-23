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
  Updated Date:   2023-06.23
  Known bugs:
	n/a
.EXAMPLE
  N/A
#>

Clear-Host

# HashTable
## Pre Powershell version 3.0
$arrMulti = @(
    New-Object PSObject -Property @{Name = "Dennis";  City = "New York"; Size = "M"}
    New-Object PSObject -Property @{Name = "Kenneth"; City = "Chicago"; Size = "S"}
)
$arrMulti

## Powershell version 3.0 and newer
$arrMultiNew = @(
    [PSCustomObject]@{Name = "Dennis";  City = "New York"; Size = "M"}
    [PSCustomObject]@{Name = "Kenneth"; City = "Chicago"; Size = "S"}
)
$arrMultiNew


# Nested HashTables
$arrNestedHashTables = @{}
$arrNestedHashTables["Cities"] = @{}
$arrNestedHashTables["Cities"]["Chicago"] = @{ Country = "USA"; Population = "8 mil" }
$arrNestedHashTables["Cities"]["New York"] = @{ Country = "USA"; Population = "15 mil" }

#$arrNestedHashTables
#$arrNestedHashTables.Cities
#$arrNestedHashTables.Cities.Chicago
#$arrNestedHashTables.Cities.Chicago.Country