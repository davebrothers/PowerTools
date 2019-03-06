param (
  [Parameter(Mandatory = $false)]
  [string]$Path = "$(Join-Path $(Get-Location) tslint.json)"
)

if ((Split-Path $Path -Leaf).ToLower() -ne "tslint.json") {
  throw New-Object System.ArgumentException("File must be tslint.json")
}

if (!(Test-Path $Path)) {
  throw New-Object System.ArgumentException("File not found: $Path")
}

$tslintConfig = Get-Content $Path -Raw | ConvertFrom-Json

# Use double quotes
$tslintConfig.rules.quotemark = @($true, "double")

$tslintConfig | ConvertTo-Json -Depth 10 | Set-Content $Path -Encoding Ascii