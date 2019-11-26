
function Get-LastNightscoutReading {
  <#
.SYNOPSIS
Retrieves last reading from Nightscout.

.DESCRIPTION NightscoutBaseURl
Requires $env:NIGHTSCOUT_BASEURL to be The Base URL for your Nightscout installation, e.g., https://foobar.herokuapp.com/api/v1

.EXAMPLE
> Get-LastNightscoutReading

121
#>

  $NightscoutBaseUrl = [System.Environment]::GetEnvironmentVariable("NIGHTSCOUT_BASEURL", [System.EnvironmentVariableTarget]::User)
  if (!$NightscoutBaseUrl) {
    $NightscoutBaseUrl = Read-Host -Prompt "Nightscout Base URL: "
    [System.Environment]::SetEnvironmentVariable("NIGHTSCOUT_BASEURL", $NightscoutBaseUrl, [System.EnvironmentVariableTarget]::User)
  }

  $WebRequestResult = Invoke-WebRequest "$NightscoutBaseUrl/entries/current.json"
  $ContentAsJson = ConvertFrom-Json ($WebRequestResult).Content

  if (![String]::IsNullOrEmpty($ContentAsJson.sgv)) {
    return $ContentAsJson.sgv
  }
  else {
    return "unknown"
  }
}

function Search-Bing {
  [CmdletBinding()]
  
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$Query
  )

  process {
    Start-Process "https://www.bing.com/search?q=$Query" 
  }
}

function New-PfxCertificate {
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
    throw [System.Exception] "Could not find openssl."
  }

  if (!$(Test-Path $Configuration)) {
    throw [System.IO.FileNotFoundException] "Could not find Configuration file $Configuration."
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
}

function Install-PfxCertificate {
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
    throw [System.IO.FileNotFoundException] "Could not find certificate at $CertPath."
  }

  # Import the certificate to the current user
  certutil -user -f -importpfx $CertPath
}
