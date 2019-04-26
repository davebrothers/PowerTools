param(
  [Parameter(Mandatory = $false)]
  [string]$NightscoutApiBaseUrl
)

if ([String]::IsNullOrEmpty($NightscoutApiBaseUrl)) {
  $NightscoutApiBaseUrl = "https://deebsisnotwaiting.herokuapp.com/api/v1"
}

$WebRequestResult = Invoke-WebRequest "$($NightscoutApiBaseUrl)/entries/current.json"
$ContentAsJson = ConvertFrom-Json ($WebRequestResult).Content

if (![String]::IsNullOrEmpty($ContentAsJson.sgv)) {
  return $ContentAsJson.sgv
} else {
  return "unknown"
}