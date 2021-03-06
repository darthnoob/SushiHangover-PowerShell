function Select-CurrentTextAsCommand {   
    <#
    .Synopsis
        Attempts to select the current text as a command
    .Description
        Attempts to select the current text as a command.
        Will not display any errors if the current text could not 
        be selected as a command
    .Example
        Select-CurrentTextAsCommand
    #>
    param()
    Select-CurrentText | 
        ForEach-Object {
            if ($_) { $_.Trim() }
        } | 
        Get-Command -ErrorAction SilentlyContinue
}
