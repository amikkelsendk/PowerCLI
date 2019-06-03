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
