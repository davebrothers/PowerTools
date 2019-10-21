# Produce UTF-8 by default
# https://news.ycombinator.com/item?id=12991690
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"

# From https://stackoverflow.com/questions/3492920/is-there-a-system-defined-environment-variable-for-documents-directory
$env:DOCUMENTS = [Environment]::GetFolderPath("mydocuments")

Function edit {
  trap {
    Write-Error "Could not open Code: $_"
    return
  }
  & "code" -g @args
}

Function Find-Content {
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

Function Find-File {
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

Function Get-Directories {
  return Get-ChildItem -Attributes D
}

Function Invoke-Explorer {
  explorer.exe .
}

Function open($file) {
  Invoke-Item $file
}

Function Remove-Directory {
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

Function Test-BOM {
  <#
.SYNOPSIS
Tests files in the pipeline for BOM.

.EXAMPLE
gci | Test-BOM

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        10/21/2019  9:54 AM              3 i-have-bom
#>

  return $input | Where-Object {
    !$_.PsIsContainer -and $_.Length -gt 2
  } | Where-Object {
    $contents = new-object byte[] 3
    $stream = [System.IO.File]::OpenRead($_.FullName)
    $stream.Read($contents, 0, 3) | Out-Null
    $stream.Close()
    $contents[0] -eq 0xEF -and $contents[1] -eq 0xBB -and $contents[2] -eq 0xBF 
  }
}