
$userNode = "$(Join-Path $env:APPDATA npm)"
[Environment]::SetEnvironmentVariable('PATH', "$userNode;" + [Environment]::GetEnvironmentVariable('PATH'))

Function Select-NpmPackageVersion {
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
}

Function Set-TsLintPreferences {
  <#
.SYNOPSIS
Sets preferences for tslint.json as used by Angular.

.DESCRIPTION
Last updated for Angular CLI 8.3.8

.PARAMETER Path
(Optional) The full path to the tslint.json file. Defaults to current directory.

.PARAMETER Prefix
(Optional) If provided, enforces prefix-associated rules for components and directives.

.EXAMPLE
Set-TslintPreferences -Path C:\git\repo\app\tslint.json
#>
  param (
    [Parameter(Mandatory = $false)]
    [string]$Path = "$(Join-Path $(Get-Location) tslint.json)",
    [Parameter(Mandatory = $false)]
    [string]$Prefix = ""
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

  # Configure disallowed console methods; includes non-standard APIs and swaps allowances of log/info
  $tslintConfig.rules."no-console" = @($true, "debug", "exception", "log", "profile", "profileEnd", "timeStamp", "trace")

  # Enforce prefix if provided
  if (![string]::IsNullOrEmpty($Prefix)) {
    $tslintConfig.rules."directive-selector" = @($true, "attribute", "$Prefix", "camelCase")
    $tslintConfig.rules."component-selector" = @($true, "element", "$Prefix", "kebab-case")
  }

  $tslintConfig | ConvertTo-Json -Depth 10 | Set-Content $Path -Encoding utf8
}