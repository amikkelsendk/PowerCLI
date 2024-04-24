Function Send-EMail {
    <#
    .NOTES
        ===========================================================================
        Created by:    Anders Mikkelsen
        Twitter:       @AMikkelsenDK
        Creation Date: 2022-03-21
        Modified Date: 2024-04-24
        ===========================================================================
    .DESCRIPTION
        This function sendsan e-mail
    .PARAMETER To
        Reciever E-mail
    .PARAMETER From
        Sender E-mail
    .PARAMETER Subject
        E-mail Subject
    .PARAMETER Body
        E-Mail body
    .PARAMETER smtpServer
        SMTP server FQDN or IP
    .PARAMETER Attachment
        Full path to attachment
        Only one attachment supported
    .EXAMPLE
        Without Att.:
        Send-EMail -To "to@email.com" -From "from@email.com" -Subject "HEY" -Body "TEST Mail" -smtpServer "relay.email.com"
        With Att.:
        Send-EMail -To "to@email.com" -From "from@email.com" -Subject "HEY" -Body "TEST Mail" -Attachment "c:\list.csv" -smtpServer "relay.email.com"

    #>
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Reciever E-mail")]
        [string]$To,
        [Parameter(Mandatory = $true, HelpMessage = "Sender E-mail")]
        [string]$From,
        [Parameter(Mandatory = $true, HelpMessage = "E-mail Subject")]
        [string]$Subject,
        [Parameter(Mandatory = $true, HelpMessage = "E-Mail body")]
        [string]$Body,
        [Parameter(Mandatory = $false, HelpMessage = "Full path to attachment")]
        [string]$Attachment,
        [Parameter(Mandatory = $true, HelpMessage = "SMTP server")]
        [string]$smtpServer
    )

    If ( $Attachment ) {
        $att = New-Object Net.Mail.Attachment( $Attachment )
    }
    $smtp = New-Object Net.Mail.SmtpClient( $smtpServer )
    $msg            = New-Object Net.Mail.MailMessage
    $msg.From       = $From
    $msg.To.Add( $To )
    $msg.Subject    = $Subject
    $msg.IsBodyHtml = 1
    $msg.Body       = $Body
    If ( $Attachment ) {
        $msg.Attachments.Add( $att )
    }
    $smtp.Send( $msg )
}


Function Send-EMailNew{
    <#
    .NOTES
        ===========================================================================
        Created by:    Anders Mikkelsen
        Twitter:       @AMikkelsenDK
        Creation Date: 2024-04-24

        Based on: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/send-mailmessage
        ===========================================================================
    .DESCRIPTION
        This function sendsan e-mail
    .PARAMETER To
        Reciever E-mail
    .PARAMETER From
        Sender E-mail
    .PARAMETER Subject
        E-mail Subject
    .PARAMETER Body
        E-Mail body
    .PARAMETER smtpServer
        SMTP server FQDN or IP
    .PARAMETER Attachment
        Full path to attachment
    .EXAMPLE
        Send-EMailNew -To "to@email.com" -From "from@email.com" -Subject "HEY" -Body "TEST Mail" -smtpServer "relay.email.com" -Alist.csvttachment "C:\"
    #>
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Reciever E-mail")]
        [string]$To,
        [Parameter(Mandatory = $true, HelpMessage = "Sender E-mail")]
        [string]$From,
        [Parameter(Mandatory = $true, HelpMessage = "E-mail Subject")]
        [string]$Subject,
        [Parameter(Mandatory = $true, HelpMessage = "E-Mail body")]
        [string]$Body,
        [Parameter(Mandatory = $true, HelpMessage = "SMTP server")]
        [string]$smtpServer,
        [Parameter(Mandatory = $true, HelpMessage = "Path to attachment")]
        [string]$Attachment
    )

    ## Define the Send-MailMessage parameters
    $mailParams = @{
        SmtpServer                 = $smtpServer
        Port                       = "25"
        UseSSL                     = $true
        From                       = $From
        To                         = $To
        Subject                    = $Subject
        Body                       = $Body
        BodyAsHtml                 = $true
        Attachment                 = $Attachment
        DeliveryNotificationOption = "OnFailure", "OnSuccess"
    }

    ## Send the message
    Send-MailMessage @mailParams
}