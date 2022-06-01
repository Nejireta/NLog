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
            $appendAttribute.HelpMessage = 'Enter if log should be appended to file'
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