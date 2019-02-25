<#
.SYNOPSIS
  Demonstrates how to read form a JSOn file and filter in the result
.DESCRIPTION
  Demonstrates how to read form a JSOn file and filter in the result
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
 
$strWorkingDir = (Get-Item -Path ".\").FullName                     # Get the current working DIR, where this script is located
$strJSONFile   = "$strWorkingDir\read_from_json.json"


## Read  the JSON file
$arrJSON = Get-Content -Raw -Path "$strJSONFile" | ConvertFrom-Json 
# $arrJSON = Get-Content -Path $strJSONFile | Out-String | ConvertFrom-Json 

## Show and filter on the JSON array
foreach($objJSON in ($arrJSON | Where-Object {$_.City -ne "Seattle"})){
   write $objJSON
   # write $objJSON.Name
}