param(
  [Parameter(Mandatory = $false)]
  [string]$Path = "$(Join-Path $(Get-Location) package.json)"
)

if ((Split-Path $Path -Leaf).ToLower() -ne "package.json") {
  throw New-Object System.ArgumentException("File must be package.json")
}

if (!(Test-Path $Path)) {
  throw New-Object System.ArgumentException("File not found: $Path")
}

return (Get-Content $Path -Raw | ConvertFrom-Json ).version