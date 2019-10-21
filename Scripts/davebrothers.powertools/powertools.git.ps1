# Because you can take the boy out of Hg,
# but you can't take the Hg out of the boy

# hg in
Function Get-IncomingChangesets {

  $currentBranch = $(git rev-parse --abbrev-ref HEAD)
  if ([string]::IsNullOrEmpty($currentBranch)) { Write-Error "There was an error determining your current branch."; return }
  $trackingBranch = $(git for-each-ref --format='%(upstream:short)' $(git symbolic-ref -q HEAD))
  if ([string]::IsNullOrEmpty($trackingBranch)) { Write-Error "There was an error determining your tracking branch."; return }
  Write-Host "$currentBranch tracking on $trackingBranch...`n"
  if ($(git log "$currentBranch..$trackingBranch").length -lt 1) { Write-Host "No incoming changes.`n"; return }
  $(git log "$currentBranch..$trackingBranch") | Out-Host
}

# hg out
Function Get-OutgoingChangesets {

  $currentBranch = $(git rev-parse --abbrev-ref HEAD)
  if ([string]::IsNullOrEmpty($currentBranch)) { Write-Error "There was an error determining your current branch."; return }
  $trackingBranch = $(git for-each-ref --format='%(upstream:short)' $(git symbolic-ref -q HEAD))
  if ([string]::IsNullOrEmpty($trackingBranch)) { Write-Error "There was an error determining your tracking branch."; return }
  Write-Host "$currentBranch tracking on $trackingBranch...`n"
  if ($(git log "$trackingBranch..$currentBranch").length -lt 1) { Write-Host "No outgoing changes.`n"; return }
  $(git log "$trackingBranch..$currentBranch") | Out-Host
}

# Check for unstaged/uncommitted changes in repository
Function Get-RepositoryStatus {
  Get-ChildItem . -Attributes Directory, Directory+Hidden -ErrorAction SilentlyContinue -Include ".git" -Recurse | 
    ForEach-Object { 
      Write-Host "$($_.parent.Name):"
      Push-Location $($_.parent.FullName)
      $git_status = "$(git status)".ToLower()
      if ($git_status.Contains("up-to-date") -and -not $git_status.Contains("changes to be committed") -and -not $git_status.Contains("changes not staged")) { "OK" } else { "DIRTY" }
      Pop-Location
      Write-Host "" 
    }
}