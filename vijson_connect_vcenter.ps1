<#
.SYNOPSIS
    Code sample on on how to connect to vCenter, create a VM snapshot and get Task status, via VIJSON REST API
-DESCRIPTION
    Code sample on on how to connect to vCenter, create a VM snapshot and get Task status, via VIJSON REST API
-NOTES
    Website:        www.amikkelsen.com
    Author:         Anders Mikkelsen
    Creation Date:  2024-09-10

    Code is created based om William Lam's Shell example and example from Broadcom
    - https://github.com/lamw/vmware-scripts/blob/master/shell/create_snapshot_for_vm.sh
    - https://developer.broadcom.com/xapis/virtual-infrastructure-json-api/latest/
    
    Latest supported 'vc_api_release' version can be found in the TOP RIGHT of https://developer.broadcom.com/xapis/virtual-infrastructure-json-api/latest/
#>


## Variables ##
$vcenter_fqdn    = "<vcenter ip or fqdn>"
$username        = "administrator@vsphere.local"
$password        = "<password>"
$userpass        = "$($username):$($password)"
$vc_api_release  = "8.0.2.0"
$vm_id           = "vm-123"                      # ID of VM


## Fix for Self-Signed Certs 
If ( $PSVersionTable.PSVersion.ToString() -like "5.1.*" ) {
$code= @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
    Add-Type -TypeDefinition $code -Language CSharp
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}


# Get Session Manager MoRef ID
$uri = "https://$vcenter_fqdn/sdk/vim25/$vc_api_release/ServiceInstance/ServiceInstance/content"
$response = Invoke-WebRequest -Uri $uri -Method "GET"
If ( $response.StatusCode -eq 200 ) {
    $session_manager_moid = ( $response | ConvertFrom-Json ).sessionManager.Value
    Write-Host "SESSION_MANAGER_MOID: $session_manager_moid"
}
Else {
    Write-Error $response.StatusCode
    Write-Error $response.StatusDescription
}


# Get auth Session ID
$uri = "https://$vcenter_fqdn/sdk/vim25/$vc_api_release/SessionManager/$session_manager_moid/Login"
$auth_headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$auth_headers.Add("Content-Type", "application/json")
$payload = @{
    "userName" = $username
    "password" = $password
}
$response = Invoke-WebRequest -Uri $uri -Method "POST" -Headers $auth_headers -Body ($payload | ConvertTo-JSON)
If ( $response.StatusCode -eq 200 ) {
    $vijson_api_session_id = $response.Headers["vmware-api-session-id"]
    Write-Host "VIJSON_API_SESSION_ID: $vijson_api_session_id"
}
Else {
    Write-Error $response.StatusCode
    Write-Error $response.StatusDescription
}


# Create new snapshot
$uri = "https://$vcenter_fqdn/sdk/vim25/$vc_api_release/VirtualMachine/$vm_id/CreateSnapshotEx_Task"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")
$headers.Add("vmware-api-session-id", $vijson_api_session_id)
$payload = @{
    "name"        = "Snapshot 001"
    "description" = "Snapshot taken by VIJSON REST API"
    "memory"      = $false
}
$response = Invoke-WebRequest -Uri $uri -Method "POST" -Headers $headers -Body ($payload | ConvertTo-JSON)
If ( $response.StatusCode -eq 200 ) {
    Write-Host "Snapshot requested"
    if ( $response.Content ) {
        $snapshots_task = ( $response | ConvertFrom-Json )
        Write-Host "Task ID: $($snapshots_task.value)"
    }
    else {
        Write-Error "Snapshot request failed"
    }
}
Else {
    Write-Error $response.StatusCode
    Write-Error $response.StatusDescription
}


# Get Task status
$uri = "https://$vcenter_fqdn/sdk/vim25/$vc_api_release/Task/$($snapshots_task.value)/info"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", "application/json")
$headers.Add("Content-Type", "application/json")
$headers.Add("vmware-api-session-id", $vijson_api_session_id)
$response = Invoke-WebRequest -Uri $uri -Method "GET" -Headers $headers
If ( $response.StatusCode -eq 200 ) {
    $task = ( $response | ConvertFrom-Json )
    Write-Host "Task status: $($task.state)"
}
elseif ( $response.StatusCode -eq 500 ) {
    Write-Host "Task complete or deleted"
    Write-Host $response.StatusDescription
}
Else {
    Write-Error $response.StatusCode
    Write-Error $response.StatusDescription
}
