function Remove-UnwantedCharacters
{
    <#
        .NOTES
        ===========================================================================
        Created by:    Anders Mikkelsen
        Date:          15/02/2021
        GIT:           https://github.com/amikkelsendk
        Twitter:       @AMikkelsenDK
        ===========================================================================

        .SYNOPSIS
            Removes/replaces all unwanted characters in a string
        .DESCRIPTION
            Removes/replaces all unwanted characters in a string
        .EXAMPLE
            Remove-UnwantedCharacters -String <String to remove chararacters from> 
        .EXAMPLE
            Remove-UnwantedCharacters -String <String to remove chararacters from> -RemoveHEX
    #>

    Param (
        [Parameter(Mandatory=$true)][String]$String,
        [Parameter(Mandatory=$false)][Switch]$RemoveHEX
    )

    $tmpString = $String
    $tmpString = $tmpString -replace "`r`n",'`n' 
    $tmpString = $tmpString -replace "`n","" 
    $tmpString = $tmpString -replace "`r","" 

    # Remove/Replace HEX characters
    If($RemoveHEX)
    {
        # https://www.systutorials.com/ascii-table-and-ascii-code/
        $tmpString = $tmpString -replace ([char] 0x73, "s") 
        $tmpString = $tmpString -replace ([char] 0xd6, "oe")
        $tmpString = $tmpString -replace ([char] 0xf6, "oe")
        $tmpString = $tmpString -replace ([char] 0xc4, "aa")
        $tmpString = $tmpString -replace ([char] 0xe4, "aa") 
    }
    write-host " $string  ------  $tmpString " -ForegroundColor magenta
    Return $tmpString.Trim()
}