# Import everything in these folders
foreach ($Folder in @('Private', 'Public')) {
    $RootFolder = [System.IO.Path]::Combine($PSScriptRoot, $Folder)

    if ([System.IO.Directory]::Exists($RootFolder)) {
        $Files = [System.IO.Directory]::GetFiles($RootFolder, '*.ps1', [System.IO.SearchOption]::TopDirectoryOnly)
        $Files.ForEach({
                # dot source each file
                . $_
            })
    }
}

Export-ModuleMember -Function (Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1").BaseName