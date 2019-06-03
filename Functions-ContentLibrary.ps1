<#
Thanks to:
- William Lam: https://www.virtuallyghetto.com/2017/07/vsphere-content-library-powercli-community-module.html
- Stuart: http://notesofascripter.com/2018/12/18/how-add-vm-content-library-powercli/
#>

clear

Function Get-ContentLibrary {
    <#
        .NOTES
        ===========================================================================
        Created by:    William Lam
        Organization:  VMware
        Blog:          www.virtuallyghetto.com
        Twitter:       @lamw
        ===========================================================================
        .DESCRIPTION
            This function lists all available vSphere Content Libaries
        .PARAMETER LibraryName
            The name of a vSphere Content Library
        .EXAMPLE
            Get-ContentLibrary
        .EXAMPLE
            Get-ContentLibrary -LibraryName Test
    #>
        param(
            [Parameter(Mandatory=$false)][String]$LibraryName
        )
    
        $contentLibraryService = Get-CisService com.vmware.content.library
        $LibraryIDs = $contentLibraryService.list()
    
        $results = @()
        foreach($libraryID in $LibraryIDs) {
            $library = $contentLibraryService.get($libraryID)
    
            # Use vCenter REST API to retrieve name of Datastore that is backing the Content Library
            # Updated by AMikkelsenDK to not thrown error when library is not backed by an vCenter Datastore
            $datastoreService = [void](Get-CisService com.vmware.vcenter.datastore)
            if($datastoreService){
                $datastore = $datastoreService.get($library.storage_backings.datastore_id)
            }
    
            if($library.publish_info.published) {
                $published = $library.publish_info.published
                $publishedURL = $library.publish_info.publish_url
                $externalReplication = $library.publish_info.persist_json_enabled
            } else {
                $published = $library.publish_info.published
                $publishedURL = "N/A"
                $externalReplication = "N/A"
            }
    
            if($library.subscription_info) {
                $subscribeURL = $library.subscription_info.subscription_url
                $published = "N/A"
            } else {
                $subscribeURL = "N/A"
            }
    
            if(!$LibraryName) {
                $libraryResult = [pscustomobject] @{
                    Id = $library.Id;
                    Name = $library.Name;
                    Type = $library.Type;
                    Description = $library.Description;
                    Datastore = $datastore.name;
                    Published = $published;
                    PublishedURL = $publishedURL;
                    JSONPersistence = $externalReplication;
                    SubscribedURL = $subscribeURL;
                    CreationTime = $library.Creation_Time;
                }
                $results+=$libraryResult
            } else {
                if($LibraryName -eq $library.name) {
                    $libraryResult = [pscustomobject] @{
                        Name = $library.Name;
                        Id = $library.Id;
                        Type = $library.Type;
                        Description = $library.Description;
                        Datastore = $datastore.name;
                        Published = $published;
                        PublishedURL = $publishedURL;
                        JSONPersistence = $externalReplication;
                        SubscribedURL = $subscribeURL;
                        CreationTime = $library.Creation_Time;
                    }
                    $results+=$libraryResult
                }
            }
        }
        $results
    }

Function Get-ContentLibraryItems {
<#
    .NOTES
    ===========================================================================
    Created by:    William Lam
    Organization:  VMware
    Blog:          www.virtuallyghetto.com
    Twitter:       @lamw
    Modified by    A. Mikkelsen / @AMikkelsenDK / https://github.com/amikkelsendk
    ===========================================================================
    .DESCRIPTION
        This function lists all items within a given vSphere Content Library
    .PARAMETER LibraryName
        The name of a vSphere Content Library
    .PARAMETER LibraryItemName
        The name of a vSphere Content Library Item
    .EXAMPLE
        Get-ContentLibraryItems -LibraryName Test
    .EXAMPLE
        Get-ContentLibraryItems -LibraryName Test -LibraryItemName TinyPhotonVM
#>
    param(
        [Parameter(Mandatory=$true)][String]$LibraryName,
        [Parameter(Mandatory=$false)][String]$LibraryItemName
    )

    $contentLibraryService = Get-CisService com.vmware.content.library
    $LibraryIDs = $contentLibraryService.list()

    $results = @()
    foreach($libraryID in $LibraryIDs) {
        $library = $contentLibraryService.get($libraryId)
        if($library.name -eq $LibraryName) {
            $contentLibraryItemService = Get-CisService com.vmware.content.library.item
            $itemIds = $contentLibraryItemService.list($libraryID)

            foreach($itemId in $itemIds) {
                $item = $contentLibraryItemService.get($itemId)

                if(!$LibraryItemName) {
                    $itemResult = [pscustomobject] @{
                        Name = $item.name;
                        Id = $item.id;
                        Description = $item.description;
                        Size = $item.size;
                        Created = $item.creation_time;
                        LastModified =  $item.last_modified_time;
                        Type = $item.type;
                        Version = $item.version;
                        MetadataVersion = $item.metadata_version;
                        ContentVersion = $item.content_version;
                    }
                    $results+=$itemResult
                } else {
                    if($LibraryItemName -eq $item.name) {
                        $itemResult = [pscustomobject] @{
                            Name = $item.name;
                            Id = $item.id;
                            Description = $item.description;
                            Size = $item.size;
                            Created = $item.creation_time;
                            LastModified =  $item.last_modified_time;
                            Type = $item.type;
                            Version = $item.version;
                            MetadataVersion = $item.metadata_version;
                            ContentVersion = $item.content_version;
                        }
                        $results+=$itemResult
                    }
                }
            }
        }
    }
    $results
}

Function Get-ContentLibraryItemFiles {
<#
    .NOTES
    ===========================================================================
    Created by:    William Lam
    Organization:  VMware
    Blog:          www.virtuallyghetto.com
    Twitter:       @lamw
    ===========================================================================
    .DESCRIPTION
        This function lists all item files within a given vSphere Content Library
    .PARAMETER LibraryName
        The name of a vSphere Content Library
    .PARAMETER LibraryItemName
        The name of a vSphere Content Library Item
    .EXAMPLE
        Get-ContentLibraryItemFiles -LibraryName Test
    .EXAMPLE
        Get-ContentLibraryItemFiles -LibraryName Test -LibraryItemName TinyPhotonVM
#>
    param(
        [Parameter(Mandatory=$true)][String]$LibraryName,
        [Parameter(Mandatory=$false)][String]$LibraryItemName
    )

    $contentLibraryService = Get-CisService com.vmware.content.library
    $libraryIDs = $contentLibraryService.list()

    $results = @()
    foreach($libraryID in $libraryIDs) {
        $library = $contentLibraryService.get($libraryId)
        if($library.name -eq $LibraryName) {
            $contentLibraryItemService = Get-CisService com.vmware.content.library.item
            $itemIds = $contentLibraryItemService.list($libraryID)
            $DatastoreID = $library.storage_backings.datastore_id.Value
            $Datastore = get-datastore -id "Datastore-$DatastoreID"
            
            foreach($itemId in $itemIds) {
                $itemName = ($contentLibraryItemService.get($itemId)).name
                $contentLibraryItemFileSerice = Get-CisService com.vmware.content.library.item.file
                $files = $contentLibraryItemFileSerice.list($itemId)
                $contentLibraryItemStorageService = Get-CisService com.vmware.content.library.item.storage

                foreach($file in $files) {
                    if($contentLibraryItemStorageService.get($itemId, $($file.name)).storage_backing.type -eq "DATASTORE"){
                        $filepath = $contentLibraryItemStorageService.get($itemId, $($file.name)).storage_uris.AbsolutePath.split("/")[5..7] -join "/"
                        $fullfilepath = "[$($datastore.name)] $filepath"
                    }
                    else{
                        $fullfilepath = "UNKNOWN"
                    }
                    
                    if(!$LibraryItemName) {
                        $fileResult = [pscustomobject] @{
                            Name = $file.name;
                            Version = $file.version;
                            Size = $file.size;
                            Stored = $file.cached;
                            Path = $fullfilepath;
                        }
                        $results+=$fileResult
                    } else {
                        if($itemName -eq $LibraryItemName) {
                            $fileResult = [pscustomobject] @{
                                Name = $file.name;
                                Version = $file.version;
                                Size = $file.size;
                                Stored = $file.cached;
                                Path = $fullfilepath;
                            }
                            $results+=$fileResult
                        }
                    }
                }
            }
        }
    }
    $results
}   

Function Copy-ContentLibrary {
<#
    .NOTES
    ===========================================================================
    Created by:    William Lam
    Organization:  VMware
    Blog:          www.virtuallyghetto.com
    Twitter:       @lamw
    ===========================================================================
    .DESCRIPTION
        This function copies all library items from one Content Library to another
    .PARAMETER SourceLibraryName
        The name of the source Content Library to copy from
    .PARAMETER DestinationLibraryName
        The name of the desintation Content Library to copy to
    .PARAMETER DeleteSourceFile
        Whther or not to delete library item from the source Content Library after copy
    .EXAMPLE
        Copy-ContentLibrary -SourceLibraryName Foo -DestinationLibraryName Bar
    .EXAMPLE
        Copy-ContentLibrary -SourceLibraryName Foo -DestinationLibraryName Bar -DeleteSourceFile $true
#>
    param(
        [Parameter(Mandatory=$true)][String]$SourceLibraryName,
        [Parameter(Mandatory=$true)][String]$DestinationLibraryName,
        [Parameter(Mandatory=$false)][Boolean]$DeleteSourceFile=$false
    )

    $sourceLibraryId = (Get-ContentLibrary -LibraryName $SourceLibraryName).Id
    if($sourceLibraryId -eq $null) {
        Write-Host -ForegroundColor red "Unable to find Source Content Library named $SourceLibraryName"
        exit
    }
    $destinationLibraryId = (Get-ContentLibrary -LibraryName $DestinationLibraryName).Id
    if($destinationLibraryId -eq $null) {
        Write-Host -ForegroundColor Red "Unable to find Destination Content Library named $DestinationLibraryName"
        break
    }

    $sourceItemFiles = Get-ContentLibraryItems -LibraryName $SourceLibraryName
    if($sourceItemFiles -eq $null) {
        Write-Host -ForegroundColor red "Unable to retrieve Content Library Items from $SourceLibraryName"
        break
    }

    $contentLibraryItemService = Get-CisService com.vmware.content.library.item

    foreach ($sourceItemFile in  $sourceItemFiles) {
        # Check to see if file already exists in destination Content Library
        $result = Get-ContentLibraryItems -LibraryName $DestinationLibraryName -LibraryItemName $sourceItemFile.Name

        if($result -eq $null) {
            # Create CopySpec
            $copySpec = $contentLibraryItemService.Help.copy.destination_create_spec.Create()
            $copySpec.library_id = $destinationLibraryId
            $copySpec.name = $sourceItemFile.Name
            $copySpec.description = $sourceItemFile.Description
            # Create random Unique Copy Id
            $UniqueChangeId = [guid]::NewGuid().tostring()

            # Perform Copy
            try {
                Write-Host -ForegroundColor Cyan "Copying" $sourceItemFile.Name "..."
                $copyResult = $contentLibraryItemService.copy($UniqueChangeId, $sourceItemFile.Id, $copySpec)
            } catch {
                Write-Host -ForegroundColor Red "Failed to copy" $sourceItemFile.Name
                $Error[0]
                break
            }

            # Delete source file if set to true
            if($DeleteSourceFile) {
                try {
                    Write-Host -ForegroundColor Magenta "Deleteing" $sourceItemFile.Name "..."
                    $deleteResult = $contentLibraryItemService.delete($sourceItemFile.Id)
                } catch {
                    Write-Host -ForegroundColor Red "Failed to delete" $sourceItemFile.Name
                    $Error[0]
                    break
                }
            }
        } else {
            Write-Host -ForegroundColor Yellow "Skipping" $sourceItemFile.Name "already exists"

            # Delete source file if set to true
            if($DeleteSourceFile) {
                try {
                    Write-Host -ForegroundColor Magenta "Deleteing" $sourceItemFile.Name "..."
                    $deleteResult = $contentLibraryItemService.delete($sourceItemFile.Id)
                } catch {
                    Write-Host -ForegroundColor Red "Failed to delete" $sourceItemFile.Name
                    break
                }
            }
        }
    }
}

Function New-LocalContentLibrary {
<#
    .NOTES
    ===========================================================================
    Created by:    William Lam
    Organization:  VMware
    Blog:          www.virtuallyghetto.com
    Twitter:       @lamw
    ===========================================================================
    .DESCRIPTION
        This function creates a new Subscriber Content Library from a JSON Persisted
        Content Library that has been externally replicated
    .PARAMETER LibraryName
        The name of the new vSphere Content Library
    .PARAMETER DatastoreName
        The name of the vSphere Datastore to store the Content Library
    .PARAMETER Publish
        Whther or not to publish the Content Library, this is required for JSON Peristence
    .PARAMETER JSONPersistence
        Whether or not to enable JSON Persistence which enables external replication of Content Library
    .EXAMPLE
        New-LocalContentLibrary -LibraryName Foo -DatastoreName iSCSI-01 -Publish $true
    .EXAMPLE
        New-LocalContentLibrary -LibraryName Foo -DatastoreName iSCSI-01 -Publish $true -JSONPersistence $true
#>
    param(
        [Parameter(Mandatory=$true)][String]$LibraryName,
        [Parameter(Mandatory=$true)][String]$DatastoreName,
        [Parameter(Mandatory=$false)][Boolean]$Publish=$true,
        [Parameter(Mandatory=$false)][Boolean]$JSONPersistence=$false
    )

    $datastore = Get-Datastore -Name $DatastoreName

    if($datastore) {
        $datastoreId = $datastore.ExtensionData.MoRef.Value
        $localLibraryService = Get-CisService -Name "com.vmware.content.local_library"

        $StorageSpec = [pscustomobject] @{
                        datastore_id = $datastoreId;
                        type         = "DATASTORE";
        }

        $UniqueChangeId = [guid]::NewGuid().tostring()

        $createSpec = $localLibraryService.Help.create.create_spec.Create()
        $createSpec.name = $LibraryName
        $addResults = $createSpec.storage_backings.Add($StorageSpec)
        $createSpec.publish_info.authentication_method = "NONE"
        $createSpec.publish_info.persist_json_enabled = $JSONPersistence
        $createSpec.publish_info.published = $Publish
        $createSpec.type = "LOCAL"
        Write-Host "Creating new Local Content Library called $LibraryName ..."
        $library = $localLibraryService.create($UniqueChangeId,$createSpec)
    }
}

Function Remove-LocalContentLibrary {
<#
    .NOTES
    ===========================================================================
    Created by:    William Lam
    Organization:  VMware
    Blog:          www.virtuallyghetto.com
    Twitter:       @lamw
    ===========================================================================
    .DESCRIPTION
        This function deletes a Local Content Library
    .PARAMETER LibraryName
        The name of the new vSphere Content Library to delete
    .EXAMPLE
        Remove-LocalContentLibrary -LibraryName Bar
#>
    param(
        [Parameter(Mandatory=$true)][String]$LibraryName
    )

    $contentLibraryService = Get-CisService com.vmware.content.library
    $LibraryIDs = $contentLibraryService.list()

    $found = $false
    foreach($libraryID in $LibraryIDs) {
        $library = $contentLibraryService.get($libraryId)
        if($library.name -eq $LibraryName) {
            $found = $true
            break
        }
    }

    if($found) {
        $localLibraryService = Get-CisService -Name "com.vmware.content.local_library"

        Write-Host "Deleting Local Content Library $LibraryName ..."
        $localLibraryService.delete($library.id)
    } else {
        Write-Host "Unable to find Content Library $LibraryName"
    }
}

Function New-VMTX {
<#
    .NOTES
    ===========================================================================
    Created by:    William Lam
    Organization:  VMware
    Blog:          www.virtuallyghetto.com
    Twitter:       @lamw
    ===========================================================================
    .DESCRIPTION
        This function clones a VM to VM Template in Content Library (currently only supported on VMC)
    .PARAMETER SourceVMName
        The name of the source VM to clone
    .PARAMETER VMTXName
        The name of the VM Template in Content Library
    .PARAMETER Description
        Description of the VM template
    .PARAMETER LibraryName
        The name of the Content Library to clone to
    .PARAMETER FolderName
        The name of vSphere Folder (Defaults to "Workloads" for VMC)
    .PARAMETER ResourcePoolName
        The name of the vSphere Resource Pool (Defaults to Compute-ResourcePools for VMC)
    .EXAMPLE
        New-VMTX -SourceVMName "Windows10-BaseInstall" -VMTXName "Windows10-VMTX-Template" -LibraryName "VMC-CL-01"
#>
    param(
        [Parameter(Mandatory=$true)][String]$SourceVMName,
        [Parameter(Mandatory=$true)][String]$VMTXName,
        [Parameter(Mandatory=$false)][String]$Description,
        [Parameter(Mandatory=$true)][String]$LibraryName,
        [Parameter(Mandatory=$false)][String]$FolderName="vm",
        [Parameter(Mandatory=$false)][String]$ResourcePoolName="Resources"
    )
    # "$FolderName"         modified from "Workloads" (VMC default),            to "vm" (vCenter Default)
    # "$ResourcePoolName"   modified from "Compute-ResourcePool" (VMC default), to "Resources" (vCenter Default)
    
    $vmtxService = Get-CisService -Name "com.vmware.vcenter.vm_template.library_items"

    $sourceVMId = ((Get-VM -Name $SourceVMName).ExtensionData.MoRef).Value
    $libraryId = ((Get-ContentLibrary -LibraryName $LibraryName).Id).Value
    $folderId = ((Get-Folder -Name $FolderName).ExtensionData.MoRef).Value
    $rpId = ((Get-ResourcePool -Name $ResourcePoolName).ExtensionData.MoRef).Value

    $vmtxCreateSpec =  $vmtxService.Help.create.spec.Create()
    $vmtxCreateSpec.source_vm = $sourceVMId
    $vmtxCreateSpec.name = $VMTXName
    $vmtxCreateSpec.description = $Description
    $vmtxCreateSpec.library = $libraryId
    $vmtxCreateSpec.placement.folder = $folderId
    $vmtxCreateSpec.placement.resource_pool = $rpId

    Write-Host "`nCreating new VMTX Template from $SourceVMName in Content Library $LibraryName ..."
    $result = $vmtxService.create($vmtxCreateSpec)
}

Function New-VMFromVMTX {
<#
    .NOTES
    ===========================================================================
    Created by:    William Lam
    Organization:  VMware
    Blog:          www.virtuallyghetto.com
    Twitter:       @lamw
    ===========================================================================
    .DESCRIPTION
        This function deploys a new VM from Template in Content Library (currently only supported in VMC)
    .PARAMETER VMTXName
        The name of the VM Template in Content Library to deploy from
    .PARAMETER NewVMName
        The name of the new VM to deploy
    .PARAMETER FolderName
        The name of vSphere Folder (Defaults to Workloads for VMC)
    .PARAMETER ResourcePoolName
        The name of the vSphere Resource Pool (Defaults to Compute-ResourcePools for VMC)
    .PARAMETER NumCpu
        The number of vCPU to configure for the new VM
    .PARAMETER MemoryMb
        The amount of memory (MB) to configure for the new VM
    .PARAMETER PowerOn
        To power on the VM after deploy
    .EXAMPLE
        New-VMFromVMTX -NewVMName "FooFoo" -VMTXName "FooBar" -PowerOn $true -NumCpu 4 -MemoryMB 2048
#>
    param(
        [Parameter(Mandatory=$true)][String]$VMTXName,
        [Parameter(Mandatory=$true)][String]$NewVMName,
        [Parameter(Mandatory=$false)][String]$FolderName="vm",
        [Parameter(Mandatory=$false)][String]$ResourcePoolName="Resources",
        [Parameter(Mandatory=$false)][String]$DatastoreName="vsanDatastore",
        [Parameter(Mandatory=$false)][Int]$NumCpu,
        [Parameter(Mandatory=$false)][Int]$MemoryMB,
        [Parameter(Mandatory=$false)][Boolean]$PowerOn=$false
    )
    # "$FolderName"         modified from "Workloads" (VMC default),            to "vm" (vCenter Default)
    # "$ResourcePoolName"   modified from "Compute-ResourcePool" (VMC default), to "Resources" (vCenter Default)

    $vmtxService = Get-CisService -Name "com.vmware.vcenter.vm_template.library_items"
    $vmtxId = (Get-ContentLibraryItem -Name $VMTXName).Id
    $folderId = ((Get-Folder -Name $FolderName).ExtensionData.MoRef).Value
    $rpId = ((Get-ResourcePool -Name $ResourcePoolName).ExtensionData.MoRef).Value
    $datastoreId = ((Get-Datastore -Name $DatastoreName).ExtensionData.MoRef).Value

    $vmtxDeploySpec =  $vmtxService.Help.deploy.spec.Create()
    $vmtxDeploySpec.name = $NewVMName
    $vmtxDeploySpec.powered_on = $PowerOn
    $vmtxDeploySpec.placement.folder = $folderId
    $vmtxDeploySpec.placement.resource_pool = $rpId
    $vmtxDeploySpec.vm_home_storage.datastore = $datastoreId
    $vmtxDeploySpec.disk_storage.datastore = $datastoreId

    if($NumCpu) {
        $vmtxDeploySpec.hardware_customization.cpu_update.num_cpus = $NumCpu
    }
    if($MemoryMB) {
        $vmtxDeploySpec.hardware_customization.memory_update.memory = $MemoryMB
    }

    Write-Host "`nDeploying new VM $NewVMName from VMTX Template $VMTXName ..."
    $results = $vmtxService.deploy($vmtxId,$vmtxDeploySpec)
}  
## Clone to template - OVF
function func_Add-TemplateToLibrary {
    <#
        LibraryName     Name of the libray to which item needs to be uploaded.
        VMname          Name of the VM to upload.
        LibItemName     Name of the template after imported to library.
        Description     Description of the imported item.
    #>
        
    param(
    [Parameter(Mandatory=$true)][string]$LibraryName,
    [Parameter(Mandatory=$true)][string]$VMname,
    [Parameter(Mandatory=$true)][string]$LibItemName,
    [Parameter(Mandatory=$true)][string]$Description
    )
    
    ## Connect to vCenter Content Library REST API
    $ContentLibraryService = Get-CisService com.vmware.content.library
    ## Get ID of Content Library
    $libaryIDs = $contentLibraryService.list()
    foreach($libraryID in $libaryIDs) {
        $library = $contentLibraryService.get($libraryID)
        if($library.name -eq $LibraryName){
            $library_ID = $libraryID
            break
        }
    }
        
    if(!$library_ID){
        write-host -ForegroundColor red $LibraryName " -- is not exists.."
    } 
    else {
        $ContentLibraryOvfService = Get-CisService com.vmware.vcenter.ovf.library_item
        $UniqueChangeId = [guid]::NewGuid().tostring()
        
        $createOvfTarget = $ContentLibraryOvfService.Help.create.target.Create()
        $createOvfTarget.library_id = $library_ID
        
        $createOvfSource = $ContentLibraryOvfService.Help.create.source.Create()
        $createOvfSource.type = ((Get-VM $VMname).ExtensionData.MoRef).Type
        $createOvfSource.id = ((Get-VM $VMname).ExtensionData.MoRef).Value
        
        $createOvfCreateSpec = $ContentLibraryOvfService.help.create.create_spec.Create()
        $createOvfCreateSpec.name = $LibItemName
        $createOvfCreateSpec.description = $Description
        #$createOvfCreateSpec.flags = ""
        
        write-host "Creating Library Item -- " $LibItemName
        $libraryTemplateId = $ContentLibraryOvfService.create($UniqueChangeId,$createOvfSource,$createOvfTarget,$createOvfCreateSpec)    
    }
}

Function Remove-ContentLibraryItems {
    <#
        .NOTES
        ===========================================================================
        Created by:    Anders Mikkelsen
        Organization:  net IT Services
        GitHub:        https://github.com/amikkelsendk
        Twitter:       @AMikkelsenDK
        ===========================================================================
        .DESCRIPTION
            This function deletes a Content Library Item
        .PARAMETER LibraryName
            The name of a vSphere Content Library
        .PARAMETER LibraryItemName
            The name of a vSphere Content Library Item
        .EXAMPLE
            Remove-ContentLibraryItems -LibraryName Test
        .EXAMPLE
            Remove-ContentLibraryItems -LibraryName Test -LibraryItemName RemoveMe
    #>
    param(
        [Parameter(Mandatory=$true)][String]$LibraryName,
        [Parameter(Mandatory=$false)][String]$LibraryItemName
    )

    $contentLibraryService = Get-CisService com.vmware.content.library
    $LibraryIDs = $contentLibraryService.list()

    foreach($libraryID in $LibraryIDs) {
        $library = $contentLibraryService.get($libraryId)
        if($library.name -eq $LibraryName) {
            $contentLibraryItemService = Get-CisService com.vmware.content.library.item
            $itemIds = $contentLibraryItemService.list($libraryID)

            foreach($itemId in $itemIds) {
                $item = $contentLibraryItemService.get($itemId)

                if($LibraryItemName -eq $item.name) {
                    #Perform Delete
                    try {
                        Write-Host -ForegroundColor Cyan "Deleting library item: " $item.Name "..."
                        $deleteResult = $contentLibraryItemService.delete($item.Id)
                    } catch {
                        Write-Host -ForegroundColor Red "Failed to delete library item:" $item.Name
                        $Error[0]
                        break
                    }
                }
            }
        }
    }
}


## Connect to vSphere Automation SDK
Connect-VIServer -Server 192.168.1.119 -User "administrator@vsphere.local" -Password "VMware1!" | Out-Null
Connect-CisServer -Server 192.168.1.119 -User "administrator@vsphere.local" -Password "VMware1!" | Out-Null

    ## A.Mikkelsen ##
    #func_Add-TemplateToLibrary -LibraryName 'Pod200' -VMname 'contenttest' -LibItemName 'CentOS7 Template 2' -Description 'Uploaded via PowerShell'
    #Remove-ContentLibraryItems -LibraryName 'Pod200' -LibraryItemName 'DeleteMe'

    ## LAMW ##
    #Get-ContentLibrary
    #Get-ContentLibrary -LibraryName "Pod200"
    #Get-ContentLibraryItems -LibraryName "Pod200" 
    #Get-ContentLibraryItems -LibraryName "Pod200" -LibraryItemName "CentOS7 Template"
    #Get-ContentLibraryItemFiles -LibraryName "Pod200"
    #Get-ContentLibraryItemFiles -LibraryName "Pod200" -LibraryItemName "CentOS7 Template"
    #New-LocalContentLibrary -LibraryName "Pod200new" -DatastoreName "OpenFiler_NFS" -Publish $false
    #Remove-LocalContentLibrary -LibraryName "Pod200new"
    #Copy-ContentLibrary -SourceLibraryName "Pod200" -DestinationLibraryName "Pod200new"
    #Copy-ContentLibrary -SourceLibraryName "Pod200" -DestinationLibraryName "Pod200new" # -DeleteSourceFile $true
    
    # VM Template
    #New-VMTX -SourceVMName "contenttest" -VMTXName "CentOS7 Template 3" -LibraryName "Pod200"
    #New-VMFromVMTX -NewVMName "contenttest1" -VMTXName "CentOS7 Template 4" -PowerOn $false -NumCpu 1 -MemoryMB 1024 -DatastoreName "OpenFiler_NFS"

Disconnect-CisServer -Confirm:$false
Disconnect-VIServer -Confirm:$false
