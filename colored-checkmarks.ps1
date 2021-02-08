$greenCheck = @{
  Object = [Char]8730
  ForegroundColor = 'Green'
  NoNewLine = $true
  }

$redCheck = @{
  Object = [Char]8730
  ForegroundColor = 'Red'
  NoNewLine = $true
  }


Write-Host "Status check... " -NoNewline
Start-Sleep -Seconds 1
Write-Host @greenCheck
Write-Host " (Done)"

write-host ""

Write-Host "Status check... " -NoNewline
Start-Sleep -Seconds 1
Write-Host @redCheck
Write-Host " (Error)"