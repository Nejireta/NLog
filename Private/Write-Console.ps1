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