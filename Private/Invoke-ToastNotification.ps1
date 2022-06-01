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
    .NOTES
        Timeout parameter of ShowBalloonTip() is deprecated
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