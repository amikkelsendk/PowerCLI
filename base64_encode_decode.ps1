<#
.SYNOPSIS
  Demonstrates how to encode & decode a Base64 string
.DESCRIPTION
  Demonstrates how to encode & decode a Base64 string
.INPUTS
  n/a 
.OUTPUTS
  Outputs to screen
.NOTES
  website:	      www.amikkelsen.com
  Author:         Anders Mikkelsen
  Creation Date:  2023-07-13
  Updated Date:   2024-10-18
  Known bugs:
	n/a

  Credits To: https://www.educba.com/powershell-base64/
.EXAMPLE
  N/A
#>

Clear-Host

$StringToBase64Endode = "TextToEncode"

## Encode
# $Base64EncodedString = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($StringToBase64Endode))
# or 
$Base64EncodedString = [Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($StringToBase64Endode))
# or
#$Base64EncodedString = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($StringToBase64Endode))

## Decode
#$Base64DecodedString = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Base64EncodedString))
# or
$Base64DecodedString = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($Base64EncodedString))
# or
#$Base64DecodedString = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Base64EncodedString))

If ( $StringToBase64Endode -eq $Base64DecodedString ) {
    Write-Host "Strings are the same: $Base64DecodedString" -ForegroundColor Green
}
Else {
    Write-Error "Strings does not match"
}
