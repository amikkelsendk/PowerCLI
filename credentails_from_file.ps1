<#
.SYNOPSIS
    Create password file and read into a Credentail variable
.DESCRIPTION
    Create password file and read into a Credentail variable
.NOTES
    website:        www.amikkelsen.com
    Author:         Anders Mikkelsen
    Creation Date:  2024-05-15

    Credits To: 
    - https://www.pdq.com/blog/secure-password-with-powershell-encrypting-credentials-part-1/
#>

# Export SecureString
# Must be done on the target computer while logged in as the user to create password file for
$FilePath = "C:\Scripts\pwdkey.txt"
Read-Host "Enter Password" -AsSecureString |  ConvertFrom-SecureString | Out-File $FilePath


# Creating SecureString object with Get-Content and ConvertTo-SecureString
$UserName = "<username>"
$MyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName, (Get-Content $FilePath | ConvertTo-SecureString)