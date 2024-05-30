<#
.SYNOPSIS
    Create password file and read into a Credentail variable
.DESCRIPTION
    Create password file and read into a Credentail variable
.NOTES
    website:        www.amikkelsen.com
    Author:         Anders Mikkelsen
    Creation Date:  2024-05-30

    Credits To: 
    - https://www.pdq.com/blog/secure-password-with-powershell-encrypting-credentials-part-1/
    - https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/convertfrom-securestring
#>

###############################
#### Without Decrypter Key ####
###############################

# Export SecureString
# Must be done on the target computer while logged in as the user to create password file for
$FilePath = "C:\Scripts\pwdkey.txt"
Read-Host "Enter Password" -AsSecureString | ConvertFrom-SecureString | Out-File $FilePath


# Creating SecureString object with Get-Content and ConvertTo-SecureString
$UserName = "<username>"
$MyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName, ( Get-Content -Path $FilePath | ConvertTo-SecureString )




###############################
####  With Decrypter Key   ####
###############################

# Export SecureString
# Must be done on the target computer while logged in as the user to create password file for
# Key is 192-bit  Byte[] Array
# Example
# $Key = (3,4,2,3,56,34,254,222,1,1,2,23,42,54,33,233,1,34,2,7,6,5,35,43)
# !!!!! Note Key, as it WILL be required to decrypt the SecureString !!!!!

$EncryptKey = ( 1..24 | %{ [byte]( Get-Random -Max 256 ) } )       # Generate random 192-bit Byte Array
$FilePath = "C:\Scripts\pwdkeyencrypted.txt"
Read-Host "Enter Password" -AsSecureString | ConvertFrom-SecureString -Key $EncryptKey | Out-File $FilePath
Write-Host "Decrypt Key: `n'($( $EncryptKey -join(",") ))'"

# Use an already encrypted securestring to create a Credential variable
$UserName = "<username>"
#$DecryptKey = $EncryptKey
$DecryptKey      = (3,4,2,3,56,34,254,222,1,1,2,23,42,54,33,233,1,34,2,7,6,5,35,43)
$MyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName, ( Get-Content -Path $FilePath | ConvertTo-SecureString -Key $DecryptKey )

# Test Decryption
$SecurePassword = Get-Content -Path $FilePath | ConvertTo-SecureString -Key $DecryptKey
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
Write-Host "Decrypted password is: '$UnsecurePassword'"
