Function Send-EMail {
    <#
    .NOTES
        ===========================================================================
        Created by:    Anders Mikkelsen
        Twitter:       @AMikkelsenDK
        Creation Date: 2022-03-21
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
    .EXAMPLE
        Send-EMail -To "to@email.com" -From "from@email.com" -Subject "HEY" -Body "TEST Mail" -smtpServer "relay.email.com"
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
        [string]$smtpServer
    )

    $smtp = new-object Net.Mail.SmtpClient($smtpServer)
    $msg            = new-object Net.Mail.MailMessage
    $msg.From       = $From
    $msg.To.Add($To)
    $msg.Subject    = $Subject
    $msg.IsBodyHtml = 1
    $msg.Body       = $Body
    $smtp.Send($msg)
}
