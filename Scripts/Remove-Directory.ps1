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
  Where-Object {-not $_.PSIsContainer} | 
  Remove-Item -Force

Remove-Item -Recurse -Force $ResolvedPath

return