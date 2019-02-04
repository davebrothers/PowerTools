# My Scripts
$script_home = "C:\Users\$($env:username)\Documents\WindowsPowerShell\Scripts"
gci $script_home -Recurse | ? { $_.Extension -eq ".ps1" } | % { Import-Module $_.FullName } | Out-Null

function prompt {
    $realLASTEXITCODE = $LASTEXITCODE
	#$($env:username)@$($env:computername): 
    Write-Host "$(Split-Path -leaf -path (Get-Location))" -nonewline

    Write-VcsStatus
    $global:LASTEXITCODE = $realLASTEXITCODE
    return "> "
}

# modules
Import-Module posh-git

# Custom Functions
function List-Directories {
	ls | ?{$_.PSIsContainer}
}

function Find-File {
	param([string]$searchTerm,
            [switch]$Recurse)
    
    if ($Recurse) {
        return (gci -Recurse -Filter *$searchTerm* -File | Format-Wide )
    }

	return (gci -Filter *$searchTerm* -File | Format-Wide )
}

Function Out-HasByteOrderMark
{   
    return $input | where {
        $contents = new-object byte[] 3
        $stream = [System.IO.File]::OpenRead($_.FullName)
        $stream.Read($contents, 0, 3) | Out-Null
        $stream.Close()
        $contents[0] -eq 0xEF -and $contents[1] -eq 0xBB -and $contents[2] -eq 0xBF }
}

# Custom Aliases
New-Alias npp 'C:\Program Files (x86)\Notepad++\Notepad++.exe'
New-Alias ld List-Directories
New-Alias trunc Clear-Content