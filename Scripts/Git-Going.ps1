# Git equivalent of hg out/in

function Git-Out {

    $currentBranch = $(git rev-parse --abbrev-ref HEAD)
    if([string]::IsNullOrEmpty($currentBranch)) {Write-Host "There was an error determining your current branch.";return}
    $trackingBranch = $(git for-each-ref --format='%(upstream:short)' $(git symbolic-ref -q HEAD))
    if([string]::IsNullOrEmpty($trackingBranch)) {Write-Host "There was an error determining your tracking branch.";return}
    Write-Host "$currentBranch tracking on $trackingBranch...`n"
    $result = $(git log $trackingBranch..$currentBranch)
    if($result.length -lt 1) {Write-Host "No outgoing changes.`n";return}
    Write-Host $result
}

function Git-In {
    
    $currentBranch = $(git rev-parse --abbrev-ref HEAD)
    if([string]::IsNullOrEmpty($currentBranch)) {Write-Host "There was an error determining your current branch.";return}
    $trackingBranch = $(git for-each-ref --format='%(upstream:short)' $(git symbolic-ref -q HEAD))
    if([string]::IsNullOrEmpty($trackingBranch)) {Write-Host "There was an error determining your tracking branch.";return}
    Write-Host "$currentBranch tracking on $trackingBranch...`n"
    $result = $(git log $currentBranch..$trackingBranch)
    if($result.length -lt 1) {Write-Host "No incoming changes.`n";return}
    Write-Host $result
}