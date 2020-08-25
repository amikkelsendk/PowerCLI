<#
.SYNOPSIS
  Reports unused datastore clusters
.DESCRIPTION
  Reports unused datastore clusters
.INPUTS
  N/A
.OUTPUTS
  List of unused datastore clusters
.NOTES
  website:	      www.amikkelsen.com
  Author:         Anders Mikkelsen
  Creation Date:  2020-08-25
  
  Tested on vSphere 6.7 U3
	
  1. Change <vcenter server> to you own vCenter
    
#>
cls

$strvCenter     = "<vcenter server>"

connect-viserver $strvCenter

    Get-DatastoreCluster | Where-Object{$_.CapacityGB -le 0} | FT -AutoSize

disconnect-viserver * -confirm:$false