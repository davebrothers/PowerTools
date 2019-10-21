################
# Path scripts
################

$scriptHome = "$(Join-Path $(Split-Path $PROFILE) Scripts)"
$env:Path += ";$scriptHome"

foreach($f in Get-ChildItem $(Join-Path $scriptHome "davebrothers.powertools") -Recurse) {
  Unblock-File $f
  . "$f"
}

Import-Module posh-git

Function prompt {
    $realLASTEXITCODE = $LASTEXITCODE
    #$($env:username)@$($env:computername): 
    Write-Host "$(Split-Path -leaf -path (Get-Location))" -nonewline
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
