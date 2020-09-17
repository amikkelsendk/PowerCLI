function Get-VCSAHealth {
<#
    .NOTES
    ===========================================================================
    Created by:    Anders Mikkelsen
    Organization:  NetIT Services
    Twitter:       @AMikkelsenDK

    Tested on:     VCSA 6.7 U3
    ===========================================================================
    .DESCRIPTION
        This function returns the health state of the VCSA services
    .PARAMETER vCenterServer
        vCenter Server FQDN or IP
    .PARAMETER Credentials
        PS Credentials for vCenter Server
    .EXAMPLE
        Get-VCSAHealth -vCenterServer myvcsa.test.local -Credentials Get-Credential

    Known Issues:
    Ensure to Enable TLS 1.0, 1.1 & 1.2
    Run:
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
#>

    param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
        [String]$vCenterServer,
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Credentials
    )

    # Crazy code to trust all certs so we don`t fail on SSL/TLS, thanks google
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

    $healthHash = @{}

    # Authentication
    try
    {
        $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credentials.UserName+':'+$Credentials.GetNetworkCredential().Password))
        $head = @{
            'Authorization' = "Basic $auth"
        }
        $r = Invoke-WebRequest -Uri "https://$($vCenterServer)/rest/com/vmware/cis/session" -Method Post -Headers $head 
        $token = (ConvertFrom-Json $r.Content).value
        # Authenticated session token
        $session = @{'vmware-api-session-id' = $token}
    }
    catch
    {
        write-host ($_.Exception.Message) -ForegroundColor red
        Break
    }

    # Get health 
    try 
    {
        $healthHash.Add("APPLIANCE_MGMT",(ConvertFrom-Json (Invoke-WebRequest -Uri "https://$($vCenterServer)/rest/appliance/health/applmgmt" -Method Get -Headers $session).Content).Value)
        $healthHash.Add("SYSTEM",(ConvertFrom-Json (Invoke-WebRequest -Uri "https://$($vCenterServer)/rest/appliance/health/system" -Method Get -Headers $session).Content).Value)
        $healthHash.Add("CPU", (ConvertFrom-Json (Invoke-WebRequest -Uri "https://$($vCenterServer)/rest/appliance/health/load" -Method Get -Headers $session).Content).Value)
        $healthHash.Add("MEMORY", (ConvertFrom-Json (Invoke-WebRequest -Uri "https://$($vCenterServer)/rest/appliance/health/mem" -Method Get -Headers $session).Content).Value)
        $healthHash.Add("SWAP", (ConvertFrom-Json (Invoke-WebRequest -Uri "https://$($vCenterServer)/rest/appliance/health/swap" -Method Get -Headers $session).Content).Value)
        $healthHash.Add("STORAGE", (ConvertFrom-Json (Invoke-WebRequest -Uri "https://$($vCenterServer)/rest/appliance/health/storage" -Method Get -Headers $session).Content).Value)
        $healthHash.Add("DATABASE_STORAGE",(ConvertFrom-Json (Invoke-WebRequest -Uri "https://$($vCenterServer)/rest/appliance/health/database-storage" -Method Get -Headers $session).Content).Value)
        $healthHash.Add("VCSA_UPDATES",(ConvertFrom-Json (Invoke-WebRequest -Uri "https://$($vCenterServer)/rest/appliance/health/software-packages" -Method Get -Headers $session).Content).Value)
    }
    catch 
    {
        write-host "Following error occured while collecting health data from $($vCenterServer) : $($_.Exception.Message)" -ForegroundColor red
        Break
    }

    Return $healthHash
}

Get-VCSAHealth -vCenterServer "<vCenter server name>" -Credentials (Get-Credential)