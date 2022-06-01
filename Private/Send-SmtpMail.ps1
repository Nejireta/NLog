function Send-SmtpMail {
    <#
    .SYNOPSIS
        Sends email
    .DESCRIPTION
        Creates a [smtpClient] and sends a [MailMessage]
    .EXAMPLE
        $MailBody = "This is an email body"
        Invoke-SendMail -Body $MailBody

        $to = "someEmail@someDomain.com"
        $subject = "SmsThroughSmtp" # not necessary
        $MailBody = "`nThis is an email sent through smtp"
        Invoke-SendMail -Body $MailBody -To $to -Subject $subject
    .INPUTS
        To [string[]], From [string], Subject [string], Body [string], Loglevel [string], SmtpServer [string]
    .OUTPUTS
        [void]
    #>
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'Enter whom the mail shall be sent to'
        )]
        [ValidateNotNull()]
        [string[]]
        $To,

        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = 'Enter who the sender is'
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $From,

        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = 'Enter subject of mail'
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Subject = ($MyInvocation.MyCommand.Name),

        [Parameter(
            Mandatory = $true,
            Position = 3,
            HelpMessage = 'Enter body of mail'
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Body,

        [Parameter(
            Mandatory = $false,
            Position = 4,
            HelpMessage = 'Enter SMTP server to send through'
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $SmtpServer,

        [Parameter(
            Mandatory = $true,
            Position = 5,
            HelpMessage = 'Enter loglevel'
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Debug', 'Information', 'Warning', 'Error', 'Critical')]
        [string]
        $Loglevel

    )
    begin {
        try {
            $smtpClient = [System.Net.Mail.SmtpClient]::new($SmtpServer)
            $smtpMail = [System.Net.Mail.MailMessage]::new()
        }
        catch {
            throw $_
        }

    }
    process {
        try {
            foreach ($email in $To) {
                $smtpMail.To.Add($email)
            }

            switch ($Loglevel) {
                'Debug' {
                    $smtpMail.Priority = [System.Net.Mail.MailPriority]::Low
                }
                'Information' {
                    $smtpMail.Priority = [System.Net.Mail.MailPriority]::Low
                }
                'Warning' {
                    $smtpMail.Priority = [System.Net.Mail.MailPriority]::Normal
                }
                'Error' {
                    $smtpMail.Priority = [System.Net.Mail.MailPriority]::High
                }
                'Critical' {
                    $smtpMail.Priority = [System.Net.Mail.MailPriority]::High
                }
            }

            $smtpMail.From = [System.Net.Mail.MailAddress]::new($From)
            $smtpMail.Subject = $Subject
            $smtpMail.Body = $Body
            $smtpMail.IsBodyHtml = $true
            $smtpClient.Send($smtpMail)
        }
        catch {
            throw $_
        }
    }
    end {
        try {
            $smtpClient.Dispose()
        }
        catch {
            $null
        }
    }
}