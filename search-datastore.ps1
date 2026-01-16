$datastoreName = "vsanDatastore SSD Storage vSAN01"

## - Logic - ##
$objDatastore = Get-Datastore -Name $datastoreName
$session = New-PSDrive -Name DS -PSProvider VimDatastore -Root '\' -Location $objDatastore 
$arrIsoFiles = Get-ChildItem -Path "DS:" -Recurse -Filter "*.iso" | Select-Object -ExpandProperty DatastoreFullPath 
Remove-PSDrive -Name DS -Confirm:$false | Out-Null
