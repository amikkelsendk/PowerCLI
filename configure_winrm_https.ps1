<#
.SYNOPSIS
    Configure computer to accept WinRm HTTPS
.DESCRIPTION
    Configure computer to accept WinRm HTTPS
.NOTES
    website:        www.amikkelsen.com
    Author:         Anders Mikkelsen
    Creation Date:  2024-05-15

    Credits To: 
    - https://www.visualstudiogeeks.com/devops/how-to-configure-winrm-for-https-manually
    - https://4sysops.com/archives/powershell-remoting-over-https-with-a-self-signed-ssl-certificate/

    - https://learn.microsoft.com/en-us/powershell/module/microsoft.wsman.management/enable-wsmancredssp?view=powershell-7.4#examples
    - https://kaloferov.com/blog/using-credssp-with-the-vco-powershell-plugin/
    - https://kaloferov.com/blog/vro-securing-your-powershell-execution-and-password-in-vro-skkb1035/


#>

# Run commands on the computer to enable WINRM HTTPS on
# Must be executed with admin priviliges

# What listner is currently configured
winrm enumerate winrm/config/listener

# Remove HTTP Listner - If required !!
Get-ChildItem WSMan:\Localhost\listener | Where-Object -Property Keys -eq "Transport=HTTP" | Remove-Item -Recurse

# Create HTTPS cert
$thisHostname = (hostname).ToLower()
$thisDomain   = ($env:USERDNSDOMAIN).ToLower()
$thisFQDN     = "$thisHostname.$thisDomain"
$certLifetime = 5       # years
$myCert       = New-SelfSignedCertificate -CertStoreLocation cert:\localmachine\my -DnsName ($thisFQDN, $thisHostname) -NotAfter (get-date).AddYears($certLifetime) -Provider "Microsoft RSA SChannel Cryptographic Provider" -KeyLength 2048

# Configure WinRM HTTPS listner
winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname="' + $thisFQDN + '"; CertificateThumbprint="' + $myCert.Thumbprint + '"}'

# Add new WinRM HTTPS Listener firewall rule
$thisPort = "5986"
netsh advfirewall firewall add rule name="Windows Remote Management (HTTPS-In)" dir=in action=allow protocol=TCP localport=$thisPort

# Disable WinRM HTTP Listener firewall rule - If required !!
Disable-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)"

### Only needed to enable Multi-Hop Support
#Enable-WSManCredSSP -Role "Server"



########################

# Test new WinRM HTTPS connection
# Form another PC run below
$winrmPort      = "5986"
$cred           = Get-Credential
$targetHostname = "<hostname>"
$sOptions       = New-PSSessionOption -SkipCACheck
Enter-PSSession -ComputerName $targetHostname -Port $winrmPort -Credential $cred -SessionOption $sOptions -UseSSL
