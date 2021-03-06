function Get-FunctionFromFile {
    <#
    .Synopsis
        Gets the Functions declared within a file
    .Description
        Gets the Functions declared within a file in the Integrated Scripting Environment
    .Example
        Get-FunctionFromFile $psise.CurrentFile        
    #>
    param(
    # The File in the Windows PowerShell Integrated Scripting Environment
    # (i.e. $psise.CurrentFile) 
    [Parameter(ValueFromPipeline=$true)]    
    [Microsoft.PowerShell.Host.ISE.ISEFile]
    $File
    )
    process {
        $tokens = Get-TokenFromFile -file $file
        for ($i = 0; $i -lt $tokens.Count; $i++) {
            if ($tokens[$i].Content -eq "function" -and
                $tokens[$i].Type -eq "Keyword") {
                $groupDepth = 0
                $ii = $i
                $done = $false
                while (-not $done) {
                    while ($tokens[$ii] -and $tokens[$ii].Type -ne 'GroupStart') { $ii++ }
                    $groupDepth++
                    while ($groupDepth -and $tokens[$ii]) {
                        $ii++
                        if ($tokens[$ii].Type -eq 'GroupStart') { $groupDepth++ } 
                        if ($tokens[$ii].Type -eq 'GroupEnd') { $groupDepth-- }
                    }
                    if (-not $tokens[$ii]) { break } 
                    if ($tokens[$ii].Content -eq "}") { 
                        $done = $true
                    }
                }
                if (-not $tokens[$ii] -or 
                    ($tokens[$ii].Start + $tokens[$ii].Length) -ge $file.Editor.Text.Length) {
                    $chunk = $file.Editor.Text.Substring($tokens[$i].Start)
                } else {
                    $chunk = $file.Editor.Text.Substring($tokens[$i].Start, 
                        $tokens[$ii].Start + $tokens[$ii].Length - $tokens[$i].Start)
                }        
                [ScriptBlock]::Create($chunk)
            }
        }
    }
}