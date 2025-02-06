## Create Credentials
$userName       = "<domain\username>"
$userPasswd     = "**********"
$credentials    = New-Object -TypeName System.Management.Automation.PSCredential( $userName, $( ConvertTo-SecureString -String $userPasswd -AsPlainText -Force ) )
#$credentials = Get-Credential -Message "vCenter Credentials"


## Connect vCenter
$vcenterServer = "<vcenter server>"
Connect-VIServer -Server $vcenterServer -Credential $credentials 


## -- Wait for VM Tools to start 
$targetComputer = "<vm name in vCenter>"
$objVM          = Get-VM -Name $targetComputer
# Start VM
$objVM | Start-VM | Wait-Tools
# Waits for the VM Tools of the VM to start. If VM Tools do not load after 180 seconds, the operation is aborted.
$objVM | Wait-Tools -TimeoutSeconds 180
# Restart VM and wait for VM Tools to load
$objVM | Restart-VMGuest | Wait-Tools


## -- Run command on guest VM
# https://developer.broadcom.com/powercli/latest/vmware.vimautomation.core/commands/invoke-vmscript
$targetComputer     = "<vm name in vCenter>"
$guestUserName      = "<domain\username>"
$guestUserPasswd    = "**********"
$objVM              = Get-VM -Name $targetComputer
$guestCredentials   = New-Object -TypeName System.Management.Automation.PSCredential( $guestUserName, $( ConvertTo-SecureString -String $guestUserPasswd -AsPlainText -Force ) )

# Bat command
$script             = "dir c:\"
$scriptType         = "Bat"
Invoke-VMScript -VM $objVM -ScriptText $script -ScriptType $scriptType -GuestCredential $guestCredentials


# PowerShell
# https://grzegorzkulikowski.info/2020/06/25/invoke-vmscript-getting-object-out-of-it/
$script     = "Get-ChildItem -Path 'C:\' | ConvertTo-Json"
$scriptType = "PowerShell"
$result     = Invoke-VMScript -VM $objVM -ScriptText $script -ScriptType $scriptType -GuestCredential $guestCredentials

$script     = @'
  ( Get-Disk | 
    Select-Object @{ l="ComputerName"; e={ $env:COMPUTERNAME } }, 
        Number, 
        @{ name='Size (GB)'; expr={ [int]($_.Size/1GB) } }, PartitionStyle ) | 
    ConvertTo-Json
'@
$scriptType = "PowerShell"
$result     = Invoke-VMScript -VM $objVM -ScriptText $script -ScriptType $scriptType -GuestCredential $guestCredentials
$result.ScriptOutput | ConvertFrom-Json


## -- Copy files to guest VM
# https://developer.broadcom.com/powercli/latest/vmware.vimautomation.core/commands/copy-vmguestfile
$targetComputer     = "<vm name in vCenter>"
$guestUserName      = "<domain\username>"
$guestUserPasswd    = "**********"
$sourceFiles        = ( "C:\testfile001.txt", "C:\testfile002.txt" )
$destinationPath    = "C:\temp"
$objVM              = Get-VM -Name $targetComputer

# Copy local files to the guest virtual machine
Get-Item -FilePath $sourceFiles | Copy-VMGuestFile -Destination $destinationPath -VM $objVM -LocalToGuest -Force -Credential $guestCredentials

# Copy files from the guest virtual machine to a local directory.
Copy-VMGuestFile -Source $sourceFiles -Destination $destinationPath -VM $objVM -GuestToLocal -Force -Credential $guestCredentials


## Disconnect-VIServer
Disconnect-VIServer * -Confirm:$false
