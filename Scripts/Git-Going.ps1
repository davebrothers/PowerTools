# Git equivalent of hg out/in

function Git-Out {

    $currentBranch = $(git rev-parse --abbrev-ref HEAD)
    if([string]::IsNullOrEmpty($currentBranch)) {Write-Host "There was an error determining your current branch.";return}
    $trackingRepository = $(git config branch.$currentBranch.remote)
    if([string]::IsNullOrEmpty($trackingRepository)) {Write-Host "There was an error determining your tracking repository.";return}
    $pattern = "[^\/]+\/[^\/]+$"
    $trackingBranch = $([Regex]::Match($(git config branch.$currentBranch.merge), $pattern))
    if([string]::IsNullOrEmpty($trackingBranch)) {Write-Host "There was an error determining your tracking branch.";return}
    Write-Host "$currentBranch tracking on $trackingRepository/$trackingBranch...`n"
    $result = $(git log $trackingRepository/$trackingBranch..$currentBranch)
    if($result.length -lt 1) {Write-Host "No outgoing changes.";return}
    Write-Host $result
}

function Git-In {
    $currentBranch = $(git rev-parse --abbrev-ref HEAD)
    if([string]::IsNullOrEmpty($currentBranch)) {Write-Host "There was an error determining your current branch.";return}
    $trackingRepository = $(git config branch.$currentBranch.remote)
    if([string]::IsNullOrEmpty($trackingRepository)) {Write-Host "There was an error determining your tracking repository.";return}
    $pattern = "[^\/]+\/[^\/]+$"
    $trackingBranch = $([Regex]::Match($(git config branch.$currentBranch.merge), $pattern))
    if([string]::IsNullOrEmpty($trackingBranch)) {Write-Host "There was an error determining your tracking branch.";return}
    Write-Host "$currentBranch tracking on $trackingRepository/$trackingBranch...`n"
    $result = $(git log $currentBranch..$trackingRepository/$trackingBranch)
    if($result.length -lt 1) {Write-Host "No incoming changes.";return}
}