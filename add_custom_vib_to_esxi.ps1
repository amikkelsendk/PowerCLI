<#
.SYNOPSIS
  Script adds additional VMware Software package to ESXi installation media and outputs a new ZIP and ISO including the new package
.DESCRIPTION
  Script adds additional VMware Software package to ESXi installation media and outputs a new ZIP and ISO including the new package

  Script was tested by adding the "USB Network Native Driver for ESXi" (https://flings.vmware.com/usb-network-native-driver-for-esxi#instructions)
  to a ESXi 7.0b ZIP offline bundle.
.INPUTS
  N/A
.OUTPUTS
  VMware vSphere ESXi installation ISO and ZIP bundle
.NOTES
  website:	      www.amikkelsen.com
  Author:         Anders Mikkelsen
  Creation Date:  2020-09-21
  
  Tested on vSphere 7.0b

#>
Clear-Host

$strESXiZipPath = "C:\temp\VMware-ESXi-7.0b-16324942-depot.zip"
$strESXiAdditionalPackage = "C:\temp\ESXi700-VMKUSB-NIC-FLING-39035884-component-16770668.zip"
$strOutPutFilePath   = "C:\temp"

## Import modules
try {
    Get-Module -ListAvailable VMware.ImageBuilder | Import-module -Force
    Get-Module -ListAvailable VMware.ImageBuilder | Import-module -Force    
}
catch {

    throw "Required modules not avaiable"
}

## Clean the deck
Get-EsxSoftwareDepot | Remove-EsxSoftwareDepot

## Add ESX Software depo
Add-EsxSoftwareDepot -DepotUrl $strESXiZipPath

## Select Image profile
$objBaseProfile = Get-EsxImageProfile |  Select-Object * | Sort-Object Name -Descending | Out-GridView -Title "Choose which Image Profile you want to base the new build on:" -PassThru
if(($objBaseProfile.Name).Length -lt 1){
    exit
}

## Create new Image Profile name & outputfile name
$strDefaultProfileName = $objBaseProfile.Name + "-Custom"
$objCustomProfile = New-EsxImageProfile -Name $strDefaultProfileName -CloneProfile $objBaseProfile.Name -Vendor $objBaseProfile.Vendor -Description $objBaseProfile.Description -Confirm:$false  

## Add additional Package to depo
Add-EsxSoftwareDepot -DepotUrl $strESXiAdditionalPackage

## Add Software Package
Add-EsxSoftwarePackage -ImageProfile $strDefaultProfileName -SoftwarePackage vmkusb-nic-fling -Force:$true 

## Export to ZIP & ISO
Export-EsxImageProfile -ImageProfile $strDefaultProfileName -FilePath "$strOutPutFilePath\$strDefaultProfileName.iso" -ExportToIso -Force
Export-EsxImageProfile -ImageProfile $strDefaultProfileName -FilePath "$strOutPutFilePath\$strDefaultProfileName.zip" -ExportToBundle -Force

## Get list of installed VIBs
(Get-EsxImageProfile -Name $strDefaultProfileName).VibList | Sort-Object Vendor, Name