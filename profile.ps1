
# Add /Scripts to PATH (No recurse -- /Scripts/nopath is for skunkworks/infrequent use)
$ScriptHome = "$(Join-Path $(Split-Path $PROFILE) Scripts)"
[Environment]::SetEnvironmentVariable("PATH", "$ScriptHome;" + [Environment]::GetEnvironmentVariable("PATH"))

# Dotsource davebrothers.powertools scripts
gci $(Join-Path $ScriptHome "davebrothers.powertools") -Recurse | % {Unblock-File $_.FullName; . $_.FullName}

if (-Not (Get-Module -ListAvailable | ? { $_.Name -eq "posh-git"})) {
  Install-Module posh-git
}
Import-Module posh-git 

function prompt {
    $realLASTEXITCODE = $LASTEXITCODE
    Write-Host "$(Split-Path -Leaf -Path (Get-Location))" -NoNewline
    "$(Write-VcsStatus)> "
    $global:LASTEXITCODE = $realLASTEXITCODE
}

# Aliases for my commands
New-Alias bing Search-Bing
New-Alias exp Invoke-Explorer
New-Alias ld Get-Directories
New-Alias npv Select-NpmPackageVersion
New-Alias trunc Clear-Content
Set-Alias rd Remove-Directory -Option AllScope
function .. { Set-Location .. }
