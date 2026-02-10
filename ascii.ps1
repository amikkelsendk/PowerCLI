## Get Character DEC
$thisChar = "a"
$thisDec = [byte][char]$thisChar
Write-Host "'$thisChar' in DEC is: $thisDec"

## Convert DEC into HEX
$thisHex = [System.Convert]::ToString( [byte][char]$thisDec, 16 )
Write-Host "'$thisChar' in HEX is: $thisHex"

## Convert HEX into DEC
$thisDec = [System.Convert]::ToString( [byte]$thisHex )
Write-Host "'$thisChar' in DEC converted from HEX is: $thisDec"

## Check if CHAR is in string
# -1 = NOT in string
# 0+ = in string
$myString = "This is a test string \ because why not"
$myString.IndexOf( $thisChar )

## Check if HEX is in string
# -1 = NOT in string
# 0+ = in string
$myString = "This is a test string \ because why not"
$myString.IndexOf( [System.Convert]::ToString( [char] 0x61 ) )



## Replace character or HEX (leading '0x') in string
$myString = "This is a / test string \ because why not"
$a         = [System.Convert]::ToString( [char] 0x61 ) # DEC: 97
$slash     = [System.Convert]::ToString( [char] 0x2F ) # DEC: 47
$backslash = [System.Convert]::ToString( [char] 0x5C ) # DEC: 92
$myString = $myString.Replace( $a, "A" )       # a to A
$myString = $myString.Replace( $slash, "--" )   # \ to --
$myString = $myString.Replace( $backslash, "||" )   # / to ||
$myString