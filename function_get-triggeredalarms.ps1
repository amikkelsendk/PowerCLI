Function Get-TriggeredAlarms{
    <#
    .NOTES
    ===========================================================================
    Created by:    Anders Mikkelsen
    Website:       www.amikkelsen.com
    Twitter:       @AMikkelsenDK

    Tested on:     VCSA 7.0 U1
    ===========================================================================
    .DESCRIPTION
        This function returns all triggered alarms
    .PARAMETER AlarmName
        Name of the alarm, as listed in vCenter
        Wildcards are build-in so no need to add *
        If not supplied, it will return all triggered alarms
    .EXAMPLE
        Get-TriggeredAlarms -AlarmName "Host memory usage"
        Get-TriggeredAlarms -AlarmName "memory"
        Get-TriggeredAlarms
    #>

    Param(
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()]
        [String]$AlarmName
    )

    $thisReturn = @()

    $alarmMgr = Get-View AlarmManager -Server $global:DefaultVIServer

    Get-Datacenter | Where-Object {$_.ExtensionData.TriggeredAlarmState} | %{
        $objDatacenter = $_
    
        $objDatacenter.ExtensionData.TriggeredAlarmState | %{
            $objAlarm = $_

            If(Get-AlarmDefinition -Id $objAlarm.Alarm | Where-Object{$_.Name -like "*$AlarmName*"}){
                $thisReturn += $objAlarm
            }
        }
    }

    Return $thisReturn
}
