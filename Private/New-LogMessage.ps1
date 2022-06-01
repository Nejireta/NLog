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