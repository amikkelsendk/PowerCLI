<#
.SYNOPSIS
  Deploy OVF with specific OVF properties
.DESCRIPTION
  Deploy OVF with specific OVF properties
.INPUTS
  N/A
.NOTES
  Author:         Anders Mikkelsen
  Creation Date:  2021-05-11
  GitHub:	      https://github.com/amikkelsendk
  Twitter:        @AMikkelsenDK
  
  Tested on vSphere:
  - 6.7 U3
  - 7.0

  Example is for a "Nested_ESXi7.0u1_Appliance_Template_v1.ovf" from https://williamlam.com/nested-virtualization/nested-esxi-virtual-appliance
#>

# Deployment & OVF options
$strVC             = "<vcenter IP or FQDN>" 
$strVCUser         = "administrator@vsphere.local"
$strVCUserPassword = "<password>"

$strDataCenter     = "MyDatacenter"
$strCluster        = "MyCluster"

$strNetworkPG      = "vDS_Vlan30_lab"
$strNetworkPGMgmtVLAN = 0

$strDatastore      = "vsanDatastore"

$strVMName         = "MyOvfVm01"
$strRootPWD        = "VMware1!"
$strIP             = "192.168.1.190"
$strNetmask        = "255.255.255.0"
$strGateway        = "192.168.1.1"
$strDNS            = "192.168.1.10"
$strDomain         = "lab.local"
$strNTP            = "192.168.1.1"
$strSYSLOG         = "192.168.1.1"

$strPathOVF = "https://download3.vmware.com/software/vmw-tools/nested-esxi/Nested_ESXi7.0u1_Appliance_Template_v1.ova"

## -- Logic -- ##

$objvCenter = connect-viserver $strVC -user $strVCUser -Password $strVCUserPassword

if($objvCenter){
    
    $objOVFConfig = Get-OvfConfiguration -OVF $strPathOVF

    $objDataCenter = Get-Datacenter -Name $strDataCenter
    $objCluster = $objDataCenter | Get-Cluster -Name $strCluster
    $objVMHost = $objCluster | Get-VMHost | Where-Object{$_.ConnectionState -eq "Connected"} | Sort-Object Name | Select-Object -First 1
    $objDatastore = $objVMHost | Get-Datastore -Name $strDatastore

    ## vDS
    $objNetworkPG = $objVMHost | Get-VirtualPortGroup -Name $strNetworkPG -Standard -ErrorAction SilentlyContinue
    if(-not ($objNetworkPG)){
        ## dVS
        $objNetworkPG = $objVMHost | Get-VDSwitch | Get-VDPortgroup -Name $strNetworkPG -ErrorAction SilentlyContinue   
    }
    if(-Not ($objNetworkPG)){
        Throw "Network PortGroup '$strNetworkPG' not found.."
    }

    ## OVF Config
    $objOVFConfig.NetworkMapping.VM_Network.Value = $objNetworkPG.Name
    $objOVFConfig.Common.guestinfo.hostname.Value = $strVMName
    $objOVFConfig.Common.guestinfo.ipaddress.Value = $strIP
    $objOVFConfig.Common.guestinfo.netmask.Value = $strNetmask
    $objOVFConfig.Common.guestinfo.gateway.Value = $strGateway
    $objOVFConfig.Common.guestinfo.vlan.Value = $strNetworkPGMgmtVLAN
    $objOVFConfig.Common.guestinfo.dns.Value = $strDNS
    $objOVFConfig.Common.guestinfo.domain.Value = $strDomain
    $objOVFConfig.Common.guestinfo.ntp.Value = $strNTP
    $objOVFConfig.Common.guestinfo.syslog.Value = $strDYSLOG
    $objOVFConfig.Common.guestinfo.password.Value = $strRootPWD
    $objOVFConfig.Common.guestinfo.ssh.Value = $true
    $objOVFConfig.Common.guestinfo.createvmfs.Value = $false

    
    Import-VApp -Name $strVMName -OvfConfiguration $objOVFConfig -Source $strPathOVF -VMHost $objVMHost -Datastore $objDatastore -DiskStorageFormat Thin -Confirm:$false
    $objTemplate = Get-ContentLibraryItem | Where-Object{$_.Name -like "*7.0u1*"}
   
    $objTemplate | New-VM -Name $strVMName -VMHost $objVMHost -Portgroup $objNetworkPG -Datastore $objDatastore

    Disconnect-VIServer -Server $strVC -Confirm:$false -Force 
}
Else{
    Throw "Unable to connect to vCenter '$strVC'"
}