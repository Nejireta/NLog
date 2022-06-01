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