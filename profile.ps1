###################
# Install Modules
###################

$modulesToLoad = @(
  "davebrothers.powertools",
  "Posh-Git",
  "Get-ChildItemColor"
)

$modulesToLoad | ForEach-Object {
    try {
        Import-Module $_ -ErrorAction "Stop"
    } catch {
        # My modules aren't published outside the repository
        if ($_.ToString().Contains("davebrothers")) {
            return
        }

        try {
            Write-Host -ForegroundColor Yellow "Could not import module $_.`nAttempting to install for current user..."
            Install-Module -Name $_ -Scope CurrentUser -ErrorAction "Stop"
        } catch {
            Write-Host $_
        }
    }
  }

Function prompt {
    $realLASTEXITCODE = $LASTEXITCODE
    #$($env:username)@$($env:computername): 
    Write-Host "$(Split-Path -leaf -path (Get-Location))" -nonewline
    Write-VcsStatus
    $global:LASTEXITCODE = $realLASTEXITCODE
    return "> "
}

# Custom Aliases
New-Alias npp 'C:\Program Files (x86)\Notepad++\Notepad++.exe'
New-Alias ld Get-Directories
New-Alias trunc Clear-Content

if (Get-Module Get-ChildItemColor) {
  Set-Alias ls Get-ChildItemColorFormatWide -Option AllScope
  Set-Alias dir Get-ChildItemColor -Option AllScope
}