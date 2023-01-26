<#
    Credits to :    https://roderikdeblock.com/
    Author:         RODERIK DE BLOCK
    URL:            https://roderikdeblock.com/automate-the-complete-capturing-process-using-app-volumes-tools/


    Procedure:
    - Connect vCenter
    - Revert Snapshot
    - Start VM
    - Start Capture process
    - Install Application
    - End Capture Process
    - Copy Files to App Volumes Manager
    - Upload files to Datastore
    - Import Application + Package in manager
    - Remove Files from App Volumes Manager
    - Revert Snapshot
    - Disconnect vCenter

    Prepare the capturing machine
    In the following example I installed the App Volumes Tools on a Windows 10 20h2 Operating System. According to the vmware documentation, the machine must meet the following prerequisites:

    - Ensure that you start a new capture every time on a clean virtual machine.
    - Ensure that the User Account Control (UAC) in Windows is disabled.
    - You must run the command-line capture program as an administrator.
    - Ensure that the command-line capture program utility is installed at C:\Program Files (x86)\VMware\AppCapture.
    - Configure WINRM for the communication between the Capturing VM and the machine which will start the script.
    
    In this example I also provided the virtual machine with the following requirements:
    - Autologon for Administrator enabled (to record the entire process)
    - Chocolatey installed
    - PowerCLI installed to Start and Stop the VM and als to revert the VM to the right snapshot
    - The App Volumes tool is very easy to use. I only needed a few lines of script to start the capture process, install the applications “VLC” and finish the capture process as you can see below.
#>


#Application Name (The installation name known by Chocolatey)
$App              = "vlc" 

#vCenter + VM variables
$Vcenter          = '<Your_Vcenter_Server>'
$Vcenter_User     = "<Your_Vcenter_User>"
$Vcenter_Password = "<Your_Vcenter_Password>"
$Package_VM       = "<Your_Package_VM>"
$Snapshot         = "<Your_Snapshot"

#WinRM variables
$WinRMUser        = "<Your_WinRMUser>" #Domain\User
$WinRMPassword    = ConvertTo-SecureString "<Your_WinRM_PAssword>" -AsPlainText -Force
$WinRMCred        = New-Object System.Management.Automation.PSCredential -ArgumentList ($WinRMUser, $WinRMPassword)

#App Volumes variables
$AppVolServer     = "<Your_App_Volumes_Server>"
$AppVolUser       = "<Your_App_Volumes_User>"
$AppVolPassword   = "<Your_App_Volumes_Passwird"

$Datacenter       = '<Your_DataCenter>'
$Datastore        = '<Your_DataStore>' 
<#I found the datastore UID by using this command:
 $Body = @{
        _       = 1619177827157 
}
$GETDS = Invoke-WebRequest -WebSession $Login -Method get -Uri https://$AppVolServer/cv_api/datastores -Body $Body
$GETDS.content | ConvertFrom-Json | select package_storage #>
$file             = 'files[]'
$files            = 'packages_templates/' + $app +  '_workstation.vmdk'

#Connect to vCenter Server
Write-Host "Connect to Vcenter Server" -ForegroundColor Green
Connect-VIServer -Server $Vcenter -User $Vcenter_User  -Password $Vcenter_Password

#Revert capturing VM to package snapshot
Write-Host "Reverting the capturing VM to the right snapshot" -ForegroundColor Green
Set-VM -VM $Package_VM -SnapShot $Snapshot -Confirm:$false

#Start- capturing VM
Write-Host "Starting the capturing VM" -ForegroundColor Green
Get-VM -Name $Package_VM | Start-VM

#Waiting for WIRM
Write-Host "Waiting for WINRM" -ForegroundColor Green 
DO {$svservice = Invoke-Command -ComputerName $Package_VM -ScriptBlock {Get-Service -Name svservice} -Credential $WinRMCred
    }Until($svservice.Status -like "running")

Write-Host "Almost ready to start....." -ForegroundColor Green
sleep -Seconds 60

#Starting, Installing and Finalizing the App Volumes Capture Process
Write-Host "Capturing, Installing and Finalizing are initiated" -ForegroundColor Green
$Destination   = "\\" + $AppVolServer + "\C$\Program Files (x86)\CloudVolumes\Manager\ppv\packages_templates"
Invoke-Command -ComputerName w10-tools -ScriptBlock  {  Start-AVAppCapture -Name $using:App ;
                                                        choco install $using:App -y;
                                                        Stop-AVTask } -Credential $WinRMCred


#Waiting until the VM is available after the reboot
write-host "VM is restarting and finalizing the Capture Process........" -ForegroundColor Green
sleep -Seconds 30
DO {$WinRMService = Invoke-Command -ComputerName $Package_VM -ScriptBlock {Get-Service -Name WinRM} -Credential $WinRMCred | Out-Null
    }Until($WinRMService.status -ne 'running')

#Waiting until the VMDK and JSON files are created
Write-host "Waiting for VMDK and JSON files are created" -ForegroundColor Green
$TestPath = "C:\Programdata\VMware\AppCapture\appvhds\" + $app + "_workstation.vmdk"
Do {$VMDKPresent = Invoke-Command -ComputerName w10-tools -ScriptBlock {Test-Path -Path $using:TestPath} -Credential $WinRMCred
}While($VMDKPresent -like 'False')

sleep -Seconds 10

#Copy .JSON + .VMDK to App Volumes Management Server
Write-Host "Copy .JSON + .VMDK to App Volumes Manager" -ForegroundColor Green
$share  = "\\" + $AppVolServer + "\C$\Program Files (x86)\CloudVolumes\Manager\ppv\packages_templates" 
Invoke-Command -ComputerName $Package_VM -Credential $WinRMCred -ScriptBlock {
    $drive = New-PSDrive -PSProvider FileSystem -Root $using:share -Name AppVol -Credential $using:winrmcred
    $JSON = "C:\ProgramData\vmware\appcapture\appvhds\" + $using:App + ".json"
    $VMDK = "C:\ProgramData\vmware\appcapture\appvhds\" + $using:App + "_workstation.vmdk"
    Copy-Item  -Path $JSON -Destination AppVol:\ 
    Copy-Item  -Path $VMDK -Destination AppVol:\ 
    Pop-Location
    Remove-PSDrive $drive
}
Write-Host ".JSON + .VMDK copied App Volumes Manager" -ForegroundColor Green

#Logging on to App Volumes Server
Write-Host "Logging in to App Volumes Manager" -ForegroundColor Green
$Body = @{
        username = $AppVolUser
        password = $AppVolPassword
}

#Ignore Certificate errors while I am not trusting the default App Volumes certificate
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

$LoggingIn = Invoke-WebRequest -SessionVariable Login -Method Post -Uri https://$AppVolServer/cv_api/sessions -Body $Body 
Write-Host $LoggingIn.Content -ForegroundColor Green
Set-Variable -Name Login -Value $Login -Scope global

#Uploading VMDK and JSON to Datastore
Write-Host "Uploading VMDK and JSON to Datastore" -ForegroundColor Green
$Body = @{
        datastore = $Datastore
        $file     = $files  
}
$Upload = Invoke-WebRequest -WebSession $Login -Method Post -Uri https://$AppVolServer/cv_api/volumes/preload -Body $Body
Write-Host $Upload.content -ForegroundColor Green

#Waiting for JSON and VMDK while they are uploading to the App Volumes Manager
Write-Host ".JSON and .VMDK are being uploaded to the App Volumes Manager" -ForegroundColor Green
DO {$pending_jobs = ((Invoke-WebRequest -WebSession $Login -Method Get -Uri "https://$AppVolServer/cv_api/jobs/pending").content | ConvertFrom-Json)
    }UNTIL($pending_jobs.pending -eq "0")
Write-Host "Files are succesfully uploaded" -ForegroundColor Green

#Importing Application/Package from datastore
write-host "Importing Application/Package from datastore to App Volumes Manager" -ForegroundColor Green
$AVDatacenter  = 'data[datacenter]'
$AVDatastore = 'data[datastore]'
$Path        = 'data[path]' 
$Delay       = 'data[delay]'

$Body = @{
        $AVDatacenter = $Datacenter
        $AVDatastore  = $Datastore
        $Path         = "appvolumes/packages_templates"
        $Delay        = "true"
        
}
$Import = Invoke-WebRequest -WebSession $Login -Method Post -Uri https://$AppVolServer/app_volumes/app_products/import -Body $Body
Write-Host $Import.Content -ForegroundColor Green

#Importing Application and Package from Datastore
Write-Host "Application and Package are being imported in App Volumes Manager" -ForegroundColor Green
DO {$pending_jobs = ((Invoke-WebRequest -WebSession $Login -Method Get -Uri "https://$AppVolServer/cv_api/jobs/pending").content | ConvertFrom-Json)
   }UNTIL($pending_jobs.pending -eq "0")
write-host "Application and Package are succesfully imported in App Volumes Manager" -ForegroundColor Green

#Removing  .JSON + .VMDK from the App Volumes Management Server 
Write-Host "Removing .JSON + .VMDK from the App Volumes Manager" -ForegroundColor Green
$share  = "\\" + $AppVolServer + "\C$\Program Files (x86)\CloudVolumes\Manager\ppv\packages_templates" 
Invoke-Command -ComputerName $Package_VM -Credential $WinRMCred -ScriptBlock {
    $drive = New-PSDrive -PSProvider FileSystem -Root $using:share -Name AppVol -Credential $using:winrmcred
    $JSON = "AppVol:\" + $using:App + ".json"
    $VMDK = "AppVol:\" + $using:App + "_workstation.vmdk"
    Remove-Item  -Path $JSON  -Force
    Remove-Item  -Path $VMDK  -Force
    Pop-Location
    Remove-PSDrive $drive
}

#Revert capture VM to capture snapshot
write-host "Revert capture VM to capture snapshot" -ForegroundColor Green
Set-VM -VM $Package_VM -SnapShot $Snapshot -Confirm:$false

#Diconnect from vCenter
write-host "Diconnect from vCenter" -ForegroundColor Green
Disconnect-VIServer -Server $Vcenter -Confirm:$false

Write-Host "###################################################################################################" -ForegroundColor Green
Write-Host "###################################################################################################" -ForegroundColor Green
Write-Host "##    The Application is succesfully captured and is now availabe in the App Volumes Manager     ##" -ForegroundColor Green
Write-Host "###################################################################################################" -ForegroundColor Green
Write-Host "###################################################################################################" -ForegroundColor Green