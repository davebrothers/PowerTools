# Produce UTF-8 by default
# https://news.ycombinator.com/item?id=12991690
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"

# From https://stackoverflow.com/questions/3492920/is-there-a-system-defined-environment-variable-for-documents-directory
$env:DOCUMENTS = [Environment]::GetFolderPath("mydocuments")

function edit {
  & code -g @args
}

function Find-Content {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Pattern,
    [Parameter(Mandatory = $false)]
    [switch]$Recurse = $false
  )

  if ($Recurse) {
    return Get-ChildItem -Recurse | Where-Object { $_ | Select-String -Pattern $Pattern }
  }

  return Get-ChildItem | Where-Object { $_ | Select-String -Pattern $Pattern }
}

function Find-File {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Filter,
    [switch]$Recurse
  )
    
  if ($Recurse) {
    return (Get-ChildItem -Recurse -Filter *$Filter* -File)
  }

  return (Get-ChildItem -Filter *$Filter* -File)
}

function Get-Directories {
  return Get-ChildItem -Attributes D
}

function Invoke-Explorer {
  explorer.exe .
}

function open($Path) {
  Invoke-Item $Path
}

function Remove-Directory {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  <#
  Because Remove-Item on a directory with many non-empty subdirectories
  sporadically fails.

  Good context here: 
  https://serverfault.com/questions/199921/force-remove-files-and-directories-in-powershell-fails-sometimes-but-not-always
#>

  $ResolvedPath = Resolve-Path $Path -ErrorAction Stop

  Get-ChildItem $ResolvedPath -Recurse -Force |
  Where-Object { -not $_.PSIsContainer } | 
  Remove-Item -Force

  Remove-Item -Recurse -Force $ResolvedPath

  return
}

filter Test-BOM {
  <#
.SYNOPSIS
Tests files in the pipeline for BOM.

.EXAMPLE
> gci | Test-BOM
[ False ] C:\folder\foo.txt
[ True ] C:\folder\bar.md
[ False ] C:\folder\baz.cs
#>

  if ($_.PsIsContainer -or $_.Length -lt 2 ) { return }

  $Contents = new-object byte[] 3
  $Stream = [System.IO.File]::OpenRead($_.FullName)
  $Stream.Read($Contents, 0, 3) | Out-Null
  $Stream.Close()
  $Result = $Contents[0] -eq 0xEF -and $Contents[1] -eq 0xBB -and $Contents[2] -eq 0xBF
  $WriteColor = [System.ConsoleColor]::Red; if ($Result) { $WriteColor = [System.ConsoleColor]::Green }
  Write-Host -ForegroundColor $WriteColor -NoNewLine "[ $Result ] "; Write-Host $_
}
