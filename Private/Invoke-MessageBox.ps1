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