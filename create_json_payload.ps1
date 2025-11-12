### - Simple way to create a JSON payload for Invoke-WebRequest
$myVar = "my test variable"
$payload = '[
    {
        "sourceType": "com.vmw.abx.actions",
        "sourceId": "' + $myVar + '",
        "type": "requestForm"
    }
]'

$payload


### - Another way
$payload = @{
    "resource_type" = "Segment"
    "type" = "DISCONNECTED"
    "id" = $segmentName
    "display_name" = $segmentName
    "vlan_ids" = $vlanIDs
    "path" = "/infra/segments/$segmentName"
    "relative_path" = $segmentName
    "parent_path" = "/infra"
    "transport_zone_path" = $transportZone
    "replication_mode" = "MTEP"
    "marked_for_delete" = $False
}
$jsonPayload = $payload | ConvertTo-Json -Depth 5 
$jsonPayload

