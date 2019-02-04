# My Scripts and Modules
# $windowsPowershellDir = "C:\Users\$($env:username)\Documents\WindowsPowerShell\"
# $scriptAndModuleHomes =@("$($windowsPowershellDir)Scripts", "$($windowsPowershellDir)Modules")
# $scriptAndModuleHomes | % { `
#     gci -Recurse | `
#     ? { $_.Extension -eq ".ps1" } | `
#     % { Import-Module $_.FullName } | `
#     Out-Null ` 
# }

Import-Module davebrothers.toolbox
Import-Module Posh-Git

function prompt {
    $realLASTEXITCODE = $LASTEXITCODE
    #$($env:username)@$($env:computername): 
    Write-Host "$(Split-Path -leaf -path (Get-Location))" -nonewline
    Write-VcsStatus
    $global:LASTEXITCODE = $realLASTEXITCODE
    return "> "
}

# Custom Functions
function Get-Directories {
    ls | ? {$_.PSIsContainer}
}

function Find-File {
    param([string]$searchTerm,
        [switch]$Recurse)
    
    if ($Recurse) {
        return (gci -Recurse -Filter *$searchTerm* -File | Format-Wide )
    }

    return (gci -Filter *$searchTerm* -File | Format-Wide )
}

# Custom Aliases
#New-Alias nucon "C:\Program Files (x86)\NUnit.org\nunit-console\nunit3-console.exe"
New-Alias npp 'C:\Program Files (x86)\Notepad++\Notepad++.exe'
New-Alias ld Get-Directories
New-Alias trunc Clear-Content