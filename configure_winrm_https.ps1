<#
.SYNOPSIS
    Configure computer to accept WinRm HTTPS
.DESCRIPTION
    Configure computer to accept WinRm HTTPS
.NOTES
    website:	      www.amikkelsen.com
    Author:         Anders Mikkelsen
    Creation Date:  2024-05-15

    Credits To: # https://www.visualstudiogeeks.com/devops/how-to-configure-winrm-for-https-manually
#>

# Run commands on the computer to enable WINRM HTTPS on
# Must be executed with admin priviliges

# What listner is currently configured
winrm enumerate winrm/config/listener

# Create HTTPS cert
$thisHostname = (hostname).ToLower()
$thisDomain   = ($env:USERDNSDOMAIN).ToLower()
$thisFQDN     = "$thisHostname.$thisDomain"
$certLifetime = 5       # years
$myCert = New-SelfSignedCertificate -CertStoreLocation cert:\localmachine\my -DnsName ($thisFQDN, $thisHostname) -NotAfter (get-date).AddYears($certLifetime) -Provider "Microsoft RSA SChannel Cryptographic Provider" -KeyLength 2048

# Configure WinRM HTTPS listner
winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname="' + $thisFQDN + '"; CertificateThumbprint="' + $myCert.Thumbprint + '"}'

# Add new WinRM HTTPS Listener firewall rule
$thisPort = "5986"
netsh advfirewall firewall add rule name="Windows Remote Management (HTTPS-In)" dir=in action=allow protocol=TCP localport=$thisPort



########################

# Test new WinRM HTTPS connection
# Form another PC run below
$winrmPort      = "5986"
$cred           = Get-Credential
$targetHostname = "<hostname>"
$sOptions       = New-PSSessionOption -SkipCACheck
Enter-PSSession -ComputerName $targetHostname -Port $winrmPort -Credential $cred -SessionOption $sOptions -UseSSL
