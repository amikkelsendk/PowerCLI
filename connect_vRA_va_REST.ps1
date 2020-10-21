# Token via PostMan.com:
# https://vra4u.com/2020/06/26/vra-8-1-quick-tip-api-authentication/

# Sniplet via
# https://docs.vmware.com/en/vRealize-Orchestrator/8.1/com.vmware.vrealize.orchestrator-using-client-guide.doc/GUID-3C0CEB11-4079-43DF-B134-08C1D62EE3A4.html

cls

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


$token = "<xxxxx>"
$vRAUrl = 'https://vra8-fielddemo-emea.cmbu.local'
$response = Invoke-RestMethod -Uri ($vRAUrl + "/deployment/api/deployments/") -Headers @{'Authorization' = "Bearer $token"} -Method 'GET' 
 
Write-Host "Got response: $response"