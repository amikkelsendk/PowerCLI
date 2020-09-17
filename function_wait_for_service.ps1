Function wait_for_service {
<#
    .NOTES
    ===========================================================================
    Created by:    Anders Mikkelsen
    Organization:  NetIT Services
    Twitter:       @AMikkelsenDK
    ===========================================================================
    .DESCRIPTION
        This function waits for a service to get to a certain state
    .PARAMETER ServiceName
        The name of a Windows service
    .PARAMETER ServiceStatus
        The service state you want to wait for 
    .PARAMETER MaxRetries
        How many retries do you want before exiting
    .PARAMETER SleepIntervalSec
        Seconds between retries
    .EXAMPLE
        wait_for_service -ServiceName "servicename" -ServiceStatus "Stopped"
    .EXAMPLE
        wait_for_service -ServiceName "servicename" -ServiceStatus "Running" -MaxRetries 10 -SleepIntervalSec 5
#>
    param (
        [Parameter(Mandatory=$true)][String]$ServiceName,
        [Parameter(Mandatory=$true)][String]$ServiceStatus,
        [Parameter(Mandatory=$false)][Integer]$MaxRetries=20,
        [Parameter(Mandatory=$false)][Ingeter]$SleepIntervalSec=5
    )
    ## Wait until service is in the correct state ($ServiceStatus)
    DO{
        $thisTestCase = (Get-Service $ServiceName | Where-Object {$_.Status -eq $thisServiceStatus}).Count
        $MaxRetries--
        Start-Sleep -Seconds $SleepIntervalSec 
    } 
    UNTIL ($thisTestCase -eq 0 -OR $MaxRetries -eq 0) 
    
    ## Return
    IF($MaxRetries -eq 0){
        RETURN "Max Retries reached, operation was not completed"
    }
    ELSE{
        RETURN "Service '$ServiceName' is now: $ServiceStatus"
    }
}
