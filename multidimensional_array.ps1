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
  Updated Date:   2023-07-13
  Known bugs:
	n/a
.EXAMPLE
  N/A
#>

Clear-Host

# HashTable ( Lists of Dictionarys )
## Pre Powershell version 3.0
$arrMulti = @(
  New-Object PSObject -Property @{Name = "Dennis"; City = "New York"; Size = "M" }
  New-Object PSObject -Property @{Name = "Kenneth"; City = "Chicago"; Size = "S" }
)
$arrMulti

## Powershell version 3.0 and newer
$arrMultiNew = @(
  [PSCustomObject]@{Name = "Dennis"; City = "New York"; Size = "M" }
  [PSCustomObject]@{Name = "Kenneth"; City = "Chicago"; Size = "S" }
)
# or
$arrMultiNew = @(
  @{Name = "Dennis"; City = "New York"; Size = "M" }
  @{Name = "Kenneth"; City = "Chicago"; Size = "S" }
)
$arrMultiNew

# Example usage:
$arrMultiNew[0]
$arrMultiNew | Select-Object Name
$arrMultiNew | Where-Object { $_.Name -eq "Dennis" }
$arrMultiNew | ForEach-Object { $_.Size = "Medium" }
$arrMultiNew | Where-Object { $_.Size -eq "M" } | ForEach-Object { $_.Size = "Medium" }
$arrMultiNew += @{Name = "Chad"; City = "LA"; Size = "XL" }
( $arrMultiNew | Where-Object { $_.Name -eq "Dennis" } )["NewKey"] = "NewValue"
( $arrMultiNew | Where-Object { $_.Name -eq "Dennis" } ).Remove("NewKey")
$arrMultiNew | Get-Member
$arrMultiNew.ContainsKey("Dennis")

$arrMultiNew | ConvertTo-Json

##########################################################################################

# Nested HashTables
$arrNestedHashTables = @{}
$arrNestedHashTables["Cities"] = @{}
$arrNestedHashTables["Cities"]["Chicago"] = @{ Country = "USA"; Population = "8 mil" }
$arrNestedHashTables["Cities"]["New York"] = @{ Country = "USA"; Population = "15 mil" }
$arrNestedHashTables["County"] = @()
$arrNestedHashTables["Country"] += ${ Name = "USA"; Language = "English"}
$arrNestedHashTables["Country"] += ${ Name = "Germany"; Language = "German"}

# Example usage:
$arrNestedHashTables
$arrNestedHashTables.Cities
$arrNestedHashTables.Cities.Chicago | gm
$arrNestedHashTables.Cities.Chicago.Country
$arrNestedHashTables.Cities | Get-Member
$arrNestedHashTables.Cities | % { $_ }
( $arrNestedHashTables.Cities ).Keys -eq "Chicago"
( $arrNestedHashTables.Cities ).Contains("Chicago")
( $arrNestedHashTables.Cities ).ContainsKey("Chicago")
$arrNestedHashTables.Cities.Chicago.Country = "US"
$arrNestedHashTables["Cities"]["Chicago"]["Country"] = "USA"
$arrNestedHashTables["Cities"] = @{}
($arrNestedHashTables.Cities).Remove("Chicago")

$arrNestedHashTables | ConvertTo-Json