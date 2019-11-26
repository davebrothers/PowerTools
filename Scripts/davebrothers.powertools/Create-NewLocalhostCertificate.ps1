#!/usr/bin/env pwsh

<#
.SYNOPSIS
Using openssl (included with Git for Windows), creates a new P12 certificate for local web development.

.PARAMETER Configuration
Path to the openssl configuration file for creating the new certificate. Default is openssl-custom.cnf in current directory.

.PARAMETER ApplicationName
Name of the application for which the cert is being generated. Default is localhost.
#>

[CmdletBinding()]
param (
  [Parameter()]
  [string]
  $Configuration = "./openssl-custom.cnf",
  [Parameter()]
  [string]
  $ApplicationName = "localhost"
)

try {
  $(openssl exit)
}
catch { 
  Write-Error "Could not find openssl."
  return
}

if (!$(Test-Path $Configuration)) {
  Write-Error "Could not find Configuration file $Configuration."
  return
}

# Request a new certificate and key using the required cnf file
openssl req `
  -newkey rsa:2048 `
  -x509 `
  -nodes `
  -keyout key.pem `
  -out certificate.pem `
  -config ./openssl-custom.cnf `
  -sha256 `
  -days 365

# Review the new certificate
openssl x509 -text -noout -in certificate.pem

# Combine key and cert into a p12 bundle with no password
openssl pkcs12 -export -name "ng serve $ApplicationName" -out certificate.p12 -in certificate.pem -inkey key.pem -passout pass:

# Validate the new p12
openssl pkcs12 -in certificate.p12 -noout -info

# Delete the x509 cert and key used to generate the pfx
Remove-Item certificate.pem
Remove-Item key.pem
