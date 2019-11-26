#!/usr/bin/env pwsh

<#
.SYNOPSIS
Using openssl (included with Git for Windows), creates a new P12 certificate for local web development.

.PARAMETER Path
Path to the certificate file. Default is ./certificate.p12.
#>

[CmdletBinding()]
param (
  [Parameter()]
  [string]
  $Name = "certificate.p12"
)

$CertPath = $(Join-Path $(Get-Location) $Name)
if (!$(Test-Path $CertPath)) {
  Write-Error "Could not find certificate at $CertPath."
  return
}

# Import the certificate to the current user
certutil -user -f -importpfx $CertPath