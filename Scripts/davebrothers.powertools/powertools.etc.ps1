
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
