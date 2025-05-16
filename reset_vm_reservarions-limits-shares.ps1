<#
    Script resets ALL vCPU & vMEM:
    - Reservations
    - Limits
    - Shares
#>

$arrVMs = Get-VM

Clear-Host

Foreach( $objVM in $arrVMs ) {
    $boolReconfigure = $false
    $spec = new-object VMware.Vim.VirtualMachineConfigSpec
    $spec.memoryAllocation = New-Object VMware.Vim.ResourceAllocationInfo
    $spec.cpuAllocation = New-Object VMware.Vim.ResourceAllocationInfo

    # Memory - MemoryReservationLockedToMax
    If ( $objVM.ExtensionData.Config.MemoryReservationLockedToMax -eq $true ) {
        $boolReconfigure = $true
        $guestConfig = New-Object VMware.Vim.VirtualMachineConfigSpec
        $guestConfig.memoryReservationLockedToMax = $false
        $objVM.ExtensionData.ReconfigVM_task( $guestConfig )
        $guestConfig = $null
        $objVM | Get-VMResourceConfiguration | Set-VMResourceConfiguration -MemReservationMB 0
    }

    # Memory - Reservations
    If ( $objVM.ExtensionData.ResourceConfig.MemoryAllocation.Reservation -ne 0 ) {
        $boolReconfigure = $true
        $spec.memoryAllocation.Reservation = 0
    }
    # Memory - Limit
    If ( $objVM.ExtensionData.ResourceConfig.MemoryAllocation.Limit -ne -1 ) {
        $boolReconfigure = $true
        $spec.memoryAllocation.Limit = -1
    }

    # Memory - Shares
    If ( $objVM.ExtensionData.ResourceConfig.MemoryAllocation.Shares.Level -ne "normal" ) {
        $boolReconfigure = $true
        $spec.memoryAllocation.Shares = New-Object VMware.Vim.SharesInfo
        $spec.memoryAllocation.Shares.Level =  "normal"
    }

    # CPU - Reservation
    If ( $objVM.ExtensionData.ResourceConfig.CpuAllocation.Reservation -ne 0 ) {
        $boolReconfigure = $true
        $spec.cpuAllocation.Reservation = 0
    }
                                            
    # CPU - Limit
    If ( $objVM.ExtensionData.ResourceConfig.CpuAllocation.Limit -ne -1 ) {
        $boolReconfigure = $true
        $spec.cpuAllocation.Limit = -1
    }

    # CPU - Shares
    If ( $objVM.ExtensionData.ResourceConfig.CpuAllocation.Shares.Level -ne "normal" ) {
        $boolReconfigure = $true
        $spec.cpuAllocation.Shares = New-Object VMware.Vim.SharesInfo
        $spec.CpuAllocation.Shares.Level =  "normal"
    }

    # Reconfigure
    If ( $boolReconfigure -eq $true ) {
        Write-Host "Reconfiguring: $($objVM.Name)" -ForegroundColor Magenta
        ( Get-View -ViewType VirtualMachine -Filter @{"Name" = $objVM.Name} | Where-Object{ $_.Name -eq $objVM.Name }).ReconfigVM_Task($spec)
        $boolReconfigure = $false
    }
    # Clean up
    $spec = $null
}
