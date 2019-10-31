
# Add /Scripts to PATH (No recurse -- /Scripts/nopath is for skunkworks/infrequent use)
$scriptHome = "$(Join-Path $(Split-Path $PROFILE) Scripts)"
[Environment]::SetEnvironmentVariable('PATH', "$scriptHome;" + [Environment]::GetEnvironmentVariable('PATH'))

# Dotsource davebrothers.powertools scripts
foreach($f in Get-ChildItem $(Join-Path $scriptHome "davebrothers.powertools") -Recurse) {
  Unblock-File $f
  . "$f"
}

Import-Module posh-git

Function prompt {
    $realLASTEXITCODE = $LASTEXITCODE
    #$($env:username)@$($env:computername): 
    Write-Host "$(Split-Path -Leaf -Path (Get-Location))" -NoNewline
    Write-VcsStatus
    $global:LASTEXITCODE = $realLASTEXITCODE
    return "> "
}

# Aliases for my commands
New-Alias ld Get-Directories
New-Alias trunc Clear-Content
New-Alias npv Select-NpmPackageVersion
New-Alias exp Invoke-Explorer
Set-Alias rd Remove-Directory -Option AllScope
Function .. { Set-Location .. }
