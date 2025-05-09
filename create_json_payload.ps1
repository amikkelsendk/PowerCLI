<#
    Simple way to create a JSON payload for Invoke-WebRequest
#>
$myVar = "my test variable"
$payload = '[
    {
        "sourceType": "com.vmw.abx.actions",
        "sourceId": "' + $myVar + '",
        "type": "requestForm"
    }
]'

$payload
