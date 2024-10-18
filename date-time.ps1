Get-Date
(Get-Date).AddHours(-1)

( (Get-Date).AddHours(-1) ) 

Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Last full Hour
$dateNow = Get-Date
$dateLastHour = ( $dateNow.AddHours(-1) )
$dateStart = Get-Date $( Get-Date $dateLastHour -Format "yyyy/MM/dd HH:00:00" )
$dateFinish = $dateStart.AddHours(1)
$dateNow
$dateLastHour
$dateStart
$dateFinish





# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date?view=powershell-7.4
Get-Date -Format "dddd MM/dd/yyyy HH:mm K"
Tuesday 06/25/2019 16:17 -07:00

Get-Date -UFormat "%A %m/%d/%Y %R %Z"
Tuesday 06/25/2019 16:19 -07

(Get-Date ).ToString()
22-08-2024 15:06:39
