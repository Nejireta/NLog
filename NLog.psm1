function New-LogMessage {
    <#
    .SYNOPSIS
        Formats message
    .DESCRIPTION
        Formats message in log based on LogLevel parameter.
        Date and LogLevel is appended to message.
        With LogLevel Error a structured error message is created
    .EXAMPLE
        New-LogMessage -Value "This is a message" -LogLevel Information
        Creates a Information LogMessage

        New-LogMessage -Value $Error[0] -LogLevel Error
        Creates a Error LogMessage
    .INPUTS
        Value [Object], Loglevel [string]
    .OUTPUTS
        [string]
    #>
    [CmdletBinding(PositionalBinding = $true)]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            HelpMessage = 'Enter value'
        )]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Value,

        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = 'Enter loglevel'
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Debug', 'Information', 'Warning', 'Error', 'Critical')]
        [string]
        $Loglevel
    )

    process {
        try {
            $datetime = [datetime]::Now.ToString('yyyy-MM-dd HH:mm:ss.fff zzz')
            $logMessage = [System.Text.StringBuilder]::new()
            [void]$logMessage.AppendLine("$datetime [$([System.Environment]::MachineName)] [$Loglevel]")
            if ($Loglevel -ne 'Error') {
                [void]$logMessage.AppendLine("Message:    $($Value)")
            }
            else {
                if (!$Value.GetType().FullName.Contains('ErrorRecord')) {
                    throw [System.ArgumentException]::new("Argument 'Value' must be of type ErrorRecord when Loglevel is Error")
                }
                [void]$logMessage.AppendLine("Message:    $($Value.Exception.Message)")
                [void]$logMessage.AppendLine("Exception:    $($Value.Exception.ToString())")
                [void]$logMessage.AppendLine("TargetObject:   $($Value.TargetObject)")
                [void]$logMessage.AppendLine("CategoryInfo:   $($Value.CategoryInfo)")
                [void]$logMessage.AppendLine("FullyQualifiedErrorId:   $($Value.FullyQualifiedErrorId)")
                [void]$logMessage.AppendLine("ErrorDetails:   $($Value.ErrorDetails)")
                [void]$logMessage.AppendLine("InvocationInfo:   $($Value.InvocationInfo)")
                [void]$logMessage.AppendLine("ScriptStackTrace:   $($Value.ScriptStackTrace)")
                [void]$logMessage.AppendLine("PipelineIterationInfo:   $($Value.PipelineIterationInfo)")
            }
            [void]$logMessage.AppendLine()
            return $logMessage.ToString()
        }
        catch {
            throw $_
        }
    }
}

function Invoke-PathValidation {
    <#
    .SYNOPSIS
        Checks if path exists
    .DESCRIPTION
        Checks if path exists. If it doesn't folder structure will be created
    .EXAMPLE
        Invoke-PathValidation -Path C:\SomeParent\SomeChild
        Creates folder structure "C:\SomeParent\SomeChild" is it doesn't already exists
    .INPUTS
        Path [string]
    .OUTPUTS
        [System.IO.DirectoryInfo]
    #>
    [CmdletBinding(PositionalBinding = $true)]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            HelpMessage = 'Enter path'
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path
    )

    process {
        $parentPath = [System.IO.DirectoryInfo]::new($Path).Parent
        if (![System.IO.Directory]::Exists($parentPath)) {
            try {
                return [System.IO.Directory]::CreateDirectory($parentPath)
            }
            catch {
                throw $_
            }
        }
    }
}

function Write-Console {
    <#
    .SYNOPSIS
        Displays console message
    .DESCRIPTION
        Displays console message with color coordination based on LogLevel
    .EXAMPLE
        Write-Console -Value "Console message" -LogLevel Warning
        Writes "Console message" with black background and yellow foreground
    .INPUTS
        Value [string], Loglevel [string]
    .OUTPUTS
        [void]
    #>
    [CmdletBinding(PositionalBinding = $true)]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            HelpMessage = 'Enter value'
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Value,

        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = 'Enter loglevel'
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Debug', 'Information', 'Warning', 'Error', 'Critical')]
        [string]
        $Loglevel
    )

    process {
        try {
            switch ($Loglevel) {
                'Debug' {
                    [System.Console]::ForegroundColor = [System.ConsoleColor]::Yellow
                }
                'Information' {
                    [System.Console]::ForegroundColor = [System.ConsoleColor]::White
                }
                'Warning' {
                    [System.Console]::BackgroundColor = [System.ConsoleColor]::Black
                    [System.Console]::ForegroundColor = [System.ConsoleColor]::Yellow
                }
                'Error' {
                    [System.Console]::BackgroundColor = [System.ConsoleColor]::Black
                    [System.Console]::ForegroundColor = [System.ConsoleColor]::Red
                }
                'Critical' {
                    [System.Console]::BackgroundColor = [System.ConsoleColor]::Black
                    [System.Console]::ForegroundColor = [System.ConsoleColor]::Red
                }
            }

            [System.Console]::WriteLine($Value)
            [System.Console]::ResetColor()
        }
        catch {
            throw $_
        }
    }
}

function Invoke-MessageBox {
    <#
    .SYNOPSIS
        Displays Messagebox message
    .DESCRIPTION
        Displays Messagebox message with icon based on LogLevel
    .EXAMPLE
        Invoke-MessageBox -Value "Console message" -LogLevel Warning
        Writes "Messagebox message" with warning icon
    .INPUTS
        Value [string], Loglevel [string]
    .OUTPUTS
        [void]
    #>
    [CmdletBinding(PositionalBinding = $true)]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            HelpMessage = 'Enter value'
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Value,

        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = 'Enter loglevel'
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Debug', 'Information', 'Warning', 'Error', 'Critical')]
        [string]
        $Loglevel
    )

    begin {
        try {
            [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
            $MessageBoxButtons = [System.Windows.Forms.MessageBoxButtons]::OK
            $MessageBoxDefaultButton = [System.Windows.Forms.MessageBoxDefaultButton]::Button1
            $MessageBoxOptions = [System.Windows.Forms.MessageBoxOptions]::DefaultDesktopOnly
        }
        catch {
            throw $_
        }
    }

    process {
        switch ($Loglevel) {
            'Debug' {
                $MessageBoxIcon = [System.Windows.Forms.MessageBoxIcon]::Asterisk
            }
            'Information' {
                $MessageBoxIcon = [System.Windows.Forms.MessageBoxIcon]::Information
            }
            'Warning' {
                $MessageBoxIcon = [System.Windows.Forms.MessageBoxIcon]::Warning
            }
            'Error' {
                $MessageBoxIcon = [System.Windows.Forms.MessageBoxIcon]::Error
            }
            'Critical' {
                $MessageBoxIcon = [System.Windows.Forms.MessageBoxIcon]::Exclamation
            }
        }
        try {
            Start-ThreadJob -Name MessageBox -ScriptBlock {
                param ($Value, $Loglevel, $MessageBoxButtons, $MessageBoxIcon, $MessageBoxDefaultButton, $MessageBoxOptions)
    
                [System.Windows.Forms.MessageBox]::Show($Value, $Loglevel.ToUpper(), $MessageBoxButtons, $MessageBoxIcon, $MessageBoxDefaultButton, $MessageBoxOptions)
            } -ArgumentList $Value, $Loglevel, $MessageBoxButtons, $MessageBoxIcon, $MessageBoxDefaultButton, $MessageBoxOptions > $null
        }
        catch {
            throw $_
        }
    }
}

function Invoke-ToastNotification {
    <#
    .SYNOPSIS
        Displays toast notificiation message
    .DESCRIPTION
        Displays toast notificiation message with icon based on LogLevel
    .EXAMPLE
        Invoke-ToastNotification -Value "Console message" -LogLevel Warning
        Writes "Messagebox message" with warning icon
    .INPUTS
        Value [string], Loglevel [string], Duration [int]
    .OUTPUTS
        [void]
    #>
    [CmdletBinding(PositionalBinding = $true)]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            HelpMessage = 'Enter value'
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Value,

        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = 'Enter loglevel'
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Debug', 'Information', 'Warning', 'Error', 'Critical')]
        [string]
        $Loglevel,

        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = 'Enter Duration'
        )]
        [ValidateNotNull()]
        [int]
        $Duration = 10
    )

    begin {
        try {
            [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
            [void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')
        }
        catch {
            throw $_
        }
    }

    process {
        try {
            $ToastNotification = [System.Windows.Forms.NotifyIcon]::New()
            $ToastNotification.Visible = $true
    
            switch ($Loglevel) {
                'Debug' {
                    $ToastNotification.Icon = [System.Drawing.SystemIcons]::Asterisk
                    $ToolTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
                }
                'Information' {
                    $ToastNotification.Icon = [System.Drawing.SystemIcons]::Information
                    $ToolTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
                }
                'Warning' {
                    $ToastNotification.Icon = [System.Drawing.SystemIcons]::Warning
                    $ToolTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
                }
                'Error' {
                    $ToastNotification.Icon = [System.Drawing.SystemIcons]::Error
                    $ToolTipIcon = [System.Windows.Forms.ToolTipIcon]::Error
                }
                'Critical' {
                    $ToastNotification.Icon = [System.Drawing.SystemIcons]::Exclamation
                    $ToolTipIcon = [System.Windows.Forms.ToolTipIcon]::Error
                }
            }
            
            $ToastNotification.ShowBalloonTip($Duration, $Loglevel.ToUpper(), $Value, $ToolTipIcon)
        }
        catch {
            throw $_
        }
    }

    end {
        try {
            $ToastNotification.Dispose()
        }
        catch {
            $null
        }
    }
}

function Send-SmtpMail {
    <#
    .SYNOPSIS
        Sends email or sms
    .DESCRIPTION
        Creates a [smtpClient] and sends a [MailMessage]
    .EXAMPLE
        $MailBody = "This is an email body"
        Invoke-SendMail -Body $MailBody

        $to = "+46<number>@sms.volvocars.com"
        $subject = "SmsThroughSmtp" # not necessary
        $MailBody = "`nDetta är ett sms skickat genom smtp"
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
        $From = "$($MyInvocation.MyCommand.Name)@volvocars.com",

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
        $SmtpServer = 'mailrelay.volvocars.net',

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

function Write-Log {
    <#
    .SYNOPSIS
        Writes log to file and/or console
    .DESCRIPTION
        Uses New-LogMessage to format an output message for file and/or console.
        Uses Invoke-PathValidation to verify path to file
        Writes to file with either [System.IO.File]::AppendAllLines or [System.IO.File]::WriteAllLines depending on Append parameter
        Uses Write-Console to output a console message
        Uses Invoke-MessageBox to output to a [System.Windows.Forms.MessageBox] object
        Uses Invoke-ToastNotification to output to a [System.Windows.Forms.NotifyIcon] object
    .EXAMPLE
        Write-Log -File -Path 'C:\log\pwshLog\error.log' -Append -Value $Error[0] -Loglevel Error
        Appends a logfile to C:\log\pwshLog\error.log with latest error message

        Write-Log -Console -Notification -NotificationType 'Toast' -Value "Some Message" -Loglevel Information
        Writes Information message to console and sends it as a toast notification
    .INPUTS
        File [switch], Console [switch], Notification [switch], Value [Object], Loglevel [string]
    .OUTPUTS
        [void]
    #>
    [CmdletBinding(SupportsShouldProcess,
        ConfirmImpact = 'Low',
        PositionalBinding = $true
    )]
    param (
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'Enter path with filename'
        )]
        [ValidateNotNullOrEmpty()]
        [switch]
        $File = $false,

        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = 'Enter if log should be written to console'
        )]
        [switch]
        $Console = $false,

        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = 'Enter if log message should be displayed as a notification'
        )]
        [switch]
        $Notification = $false,

        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = 'Enter if log message should be sent to an Email'
        )]
        [switch]
        $Email = $false,

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 4,
            HelpMessage = 'Enter value for log'
        )]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Value,

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
    
    DynamicParam {
        $dynParamDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

        if ($File) {
            # set the dynamic parameters name
            $ParamName_Path = 'Path'
            $ParamName_Append = 'Append'

            #create a new ParameterAttribute Object
            $pathAttribute = [System.Management.Automation.ParameterAttribute]::new()
            $pathAttribute.Mandatory = $false
            $pathAttribute.HelpMessage = 'Enter path of logfile'
            #create an attributecollection object for the attribute we just created.
            $pathAttributeCollection = [System.Collections.ObjectModel.Collection[Attribute]]::new()
            #add our custom attribute
            $pathAttributeCollection.Add($pathAttribute)
            #add our parameter specifying the attribute collection
            $pathParam = [System.Management.Automation.RuntimeDefinedParameter]::new($ParamName_Path, [string], $pathAttributeCollection)
            $pathParam.Value = [System.IO.Path]::Combine($PSScriptRoot, 'Log', "$($MyInvocation.MyCommand.Name).log")


            #create a new ParameterAttribute Object
            $appendAttribute = [System.Management.Automation.ParameterAttribute]::new()
            $appendAttribute.Mandatory = $false
            $appendAttribute.HelpMessage = 'Enter Enter if log should be appended to file'
            #create an attributecollection object for the attribute we just created.
            $appendAttributeCollection = [System.Collections.ObjectModel.Collection[Attribute]]::new()
            #add our custom attribute
            $appendAttributeCollection.Add($appendAttribute)
            #add our parameter specifying the attribute collection
            $appendParam = [System.Management.Automation.RuntimeDefinedParameter]::new($ParamName_Append, [switch], $appendAttributeCollection)

            #expose the name of dynamic parameter
            $dynParamDictionary.Add($ParamName_Path, $pathParam)
            $dynParamDictionary.Add($ParamName_Append, $appendParam)
        }

        if ($Notification) {
            # set the dynamic parameters name
            $ParamName_NotificationType = 'NotificationType'

            #create a new ParameterAttribute Object
            $notificationTypeAttribute = [System.Management.Automation.ParameterAttribute]::new()
            $notificationTypeAttribute.Mandatory = $true
            $notificationTypeAttribute.HelpMessage = 'Enter which type of notification should be displayed'
    
            #create an attributecollection object for the attribute we just created.
            $notificationTypeAttributeCollection = [System.Collections.ObjectModel.Collection[Attribute]]::new()

            #add our custom attribute
            $notificationTypeAttributeCollection.Add($notificationTypeAttribute)

            # Create a ValidateSetAttribute for parameter
            switch ($PSVersionTable.PSEdition) {
                'Desktop' {
                    $validateSetAttribute = [System.Management.Automation.ValidateSetAttribute]::new('Toast')
                }
                'Core' {
                    $validateSetAttribute = [System.Management.Automation.ValidateSetAttribute]::new('Toast', 'MessageBox')
                }
                Default {
                    $validateSetAttribute = [System.Management.Automation.ValidateSetAttribute]::new('Toast', 'MessageBox')
                }
            }
			
            #add ValidateSetAttribute to attributecollection object
            $notificationTypeAttributeCollection.Add($validateSetAttribute)

            #add our parameter specifying the attribute collection
            $notificationTypeParam = [System.Management.Automation.RuntimeDefinedParameter]::new($ParamName_NotificationType, [string], $notificationTypeAttributeCollection)
    
            #expose the name of dynamic parameter
            $dynParamDictionary.Add($ParamName_NotificationType, $notificationTypeParam)
        }
        
        if ($Email) {
            # set the dynamic parameters name
            $ParamName_EmailTo = 'To'
            $ParamName_EmailFrom = 'From'
            $ParamName_EmailSubject = 'Subject'
            $ParamName_EmailSmtpServer = 'SmtpServer'

            #create a new ParameterAttribute Object
            $toAttribute = [System.Management.Automation.ParameterAttribute]::new()
            $toAttribute.Mandatory = $true
            $toAttribute.HelpMessage = 'Enter whom the mail shall be sent to'
            #create an attributecollection object for the attribute we just created.
            $toAttributeCollection = [System.Collections.ObjectModel.Collection[Attribute]]::new()
            #add our custom attribute
            $toAttributeCollection.Add($toAttribute)
            #add our parameter specifying the attribute collection
            $toParam = [System.Management.Automation.RuntimeDefinedParameter]::new($ParamName_EmailTo, [string], $toAttributeCollection)


            #create a new ParameterAttribute Object
            $fromAttribute = [System.Management.Automation.ParameterAttribute]::new()
            $fromAttribute.Mandatory = $false
            $fromAttribute.HelpMessage = 'Enter who the sender is'
            #create an attributecollection object for the attribute we just created.
            $fromAttributeCollection = [System.Collections.ObjectModel.Collection[Attribute]]::new()
            #add our custom attribute
            $fromAttributeCollection.Add($fromAttribute)
            #add our parameter specifying the attribute collection
            $fromParam = [System.Management.Automation.RuntimeDefinedParameter]::new($ParamName_EmailFrom, [string], $fromAttributeCollection)
            $fromParam.Value = "$([System.IO.FileInfo]::new($PSCommandPath).BaseName).$([System.Environment]::MachineName)@volvocars.com"


            #create a new ParameterAttribute Object
            $subjectAppendAttribute = [System.Management.Automation.ParameterAttribute]::new()
            $subjectAppendAttribute.Mandatory = $false
            $subjectAppendAttribute.HelpMessage = 'Enter subject of mail'
            #create an attributecollection object for the attribute we just created.
            $subjectAttributeCollection = [System.Collections.ObjectModel.Collection[Attribute]]::new()
            #add our custom attribute
            $subjectAttributeCollection.Add($subjectAppendAttribute)
            #add our parameter specifying the attribute collection
            $subjectParam = [System.Management.Automation.RuntimeDefinedParameter]::new($ParamName_EmailSubject, [string], $subjectAttributeCollection)
            $subjectParam.Value = ("$([System.IO.FileInfo]::new($PSCommandPath).BaseName) ($([System.Environment]::MachineName))")


            #create a new ParameterAttribute Object
            $smtpServerAppendAttribute = [System.Management.Automation.ParameterAttribute]::new()
            $smtpServerAppendAttribute.Mandatory = $false
            $smtpServerAppendAttribute.HelpMessage = 'Enter SMTP server to send through'
            #create an attributecollection object for the attribute we just created.
            $smtpServerAttributeCollection = [System.Collections.ObjectModel.Collection[Attribute]]::new()
            #add our custom attribute
            $smtpServerAttributeCollection.Add($smtpServerAppendAttribute)
            #add our parameter specifying the attribute collection
            $smtpServerParam = [System.Management.Automation.RuntimeDefinedParameter]::new($ParamName_EmailSmtpServer, [string], $smtpServerAttributeCollection)
            $smtpServerParam.Value = 'mailrelay.volvocars.net'

            #expose the name of dynamic parameter
            $dynParamDictionary.Add($ParamName_EmailTo, $toParam)
            $dynParamDictionary.Add($ParamName_EmailFrom, $fromParam)
            $dynParamDictionary.Add($ParamName_EmailSubject, $subjectParam)
            $dynParamDictionary.Add($ParamName_EmailSmtpServer, $smtpServerParam)
        }
        return $dynParamDictionary
    }

    begin {
        if ($File) {
            $Path = $PSBoundParameters[$ParamName_Path]
            $Append = $PSBoundParameters[$ParamName_Append]
        }

        if ($Notification) {
            $NotificationType = $PSBoundParameters[$ParamName_NotificationType]
        }

        if ($Email) {
            $EmailArguments = @{
                To          = $PSBoundParameters[$ParamName_EmailTo]
                Body        = $Value
                Loglevel    = $Loglevel
                ErrorAction = 'Stop'
            }

            if (![string]::IsNullOrEmpty($PSBoundParameters[$ParamName_EmailFrom])) {
                $EmailArguments['From'] = $PSBoundParameters[$ParamName_EmailFrom]
            }

            if (![string]::IsNullOrEmpty($PSBoundParameters[$ParamName_EmailSubject])) {
                $EmailArguments['Subject'] = $PSBoundParameters[$ParamName_EmailSubject]
            }

            if (![string]::IsNullOrEmpty($PSBoundParameters[$ParamName_EmailSmtpServer])) {
                $EmailArguments['SmtpServer'] = $PSBoundParameters[$ParamName_EmailSmtpServer]
            }
        }
    }

    process {
        try {
            $LogMessage = New-LogMessage -Value $Value -Loglevel $Loglevel -ErrorAction Stop

            if ($File) {
                if ($pscmdlet.ShouldProcess($Path, 'Write log file?')) {
                    Invoke-PathValidation -Path $Path -ErrorAction Stop > $null

                    if ($Append) {
                        [System.IO.File]::AppendAllLines($Path, [string[]]$LogMessage)
                    }
                    else {
                        [System.IO.File]::WriteAllLines($Path, $LogMessage)
                    }
                }
            }

            if ($Console) {
                Write-Console -Value $LogMessage -Loglevel $Loglevel -ErrorAction Stop
            }

            if ($Notification) {
                switch ($NotificationType) {
                    'Toast' { 
                        Invoke-ToastNotification -Value $LogMessage -Loglevel $Loglevel -Duration 10 -ErrorAction Stop # 8 hours = 28800
                    }
                    'MessageBox' {
                        Invoke-MessageBox -Value $LogMessage -Loglevel $Loglevel -ErrorAction Stop
                    }
                    Default {
                        return
                    }
                }
            }

            if ($Email) {
                Send-SmtpMail @EmailArguments
            }
        }
        catch {
            [System.IO.File]::AppendAllLines([System.IO.Path]::Combine($PSScriptRoot, "Write-Log.log"), [string[]]$_)
            throw $_
        }
    }
}
