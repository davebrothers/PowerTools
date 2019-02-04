
####################################
#            UTILITY
####################################

Function Find-File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Filter,
        [switch]$Recurse
    )
    
    if ($Recurse) {
        return (Get-ChildItem -Recurse -Filter *$Filter* -File | Format-Wide )
    }

    return (Get-ChildItem -Filter *$Filter* -File | Format-Wide )
}
Export-ModuleMember -Function "Find-File"

Function Get-Directories {
    Get-ChildItem | Where-Item {$_.PSIsContainer}
}
Export-ModuleMember -Function "Get-Directories"

Function Out-HasByteOrderMark
{   
    return $input | where {
        $contents = new-object byte[] 3
        $stream = [System.IO.File]::OpenRead($_.FullName)
        $stream.Read($contents, 0, 3) | Out-Null
        $stream.Close()
        $contents[0] -eq 0xEF -and $contents[1] -eq 0xBB -and $contents[2] -eq 0xBF }
}
Export-ModuleMember -Function "Out-HasByteOrderMark"

####################################
#           CHOCOLATEY
####################################

#Lists all locally-installed choco packages by name
Function Show-Chocopackages {
    choco list -lo | 
        ForEach-Object { if (!$_.Contains(" packages installed.") -and !$_.ToLower().StartsWith("chocolatey")) {
            try {$_.Substring(0, $_.IndexOf(" ")) | Out-Host } 
            catch {}
        }
    }
}
Export-ModuleMember -Function "Show-Chocopackages"

####################################
#            CHUTZPAH
####################################

Function Start-ChutzpahTests() {
    Param(
        [switch]$OpenInBrowser
    )
    #Is Chutzpah installed?
    Write-Host "Locating Chutzpah..."
    if ( - !(Test-Path ($chutzpah = Get-ChildItem -Recurse "chutzpah.console.exe"))) {
        Write-Host "Cannot find Chutzpah in solution packages. Have you installed the nuget package?"
    }
    Write-Host "OK!" -ForegroundColor Green

    $testfiles = Get-ChildItem -Recurse "*.tests.js"

    Write-Host "The following test files have been found in the solution:" -ForegroundColor DarkYellow
    $testfiles | ForEach-Object { Write-Host $_.Name }

    $testdirs = $testfiles | ForEach-Object { $_.Directory }
    
    
    Write-Host ""
    Write-Host "Run these tests now?"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Kick off tests"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Exit"
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($no, $yes)
    $result = $host.UI.PromptForChoice("Test listed specs", "Do you want to run these tests now?", $options, 0)
    if ($result -eq 0) { "Suit yourself."; return }
    elseif ($result -eq 1) {
        if ($OpenInBrowser) {
            $testdirs | Get-Unique | % { & $chutzpah $_ /openInBrowser}
        }
        else {
            $testdirs | Get-Unique | % { & $chutzpah $_ }
        }
    }
}
Export-ModuleMember -Function "Start-ChutzpahTests"

####################################
#               GIT
####################################

Function Add-Gitignore {
    Function fetch {
        Write-Host -NoNewLine "Creating new "
        Write-Host -NoNewLine -ForegroundColor Magenta "Visual Studio" 
        Write-Host "-flavored .gitignore."
        $wc = New-Object System.Net.WebClient
        Try {
            $wc.DownloadString("https://raw.githubusercontent.com/github/gitignore/master/VisualStudio.gitignore") | New-Item -Name ".gitignore"
        }
        Catch {
            Write-Host "Sorry, there was a problem fetching the file."
            Write-Host $_
            return
        }
        Write-Host "Successfully created." -ForegroundColor Green
    }

    $p = "$PWD\.gitignore"
    if (Test-Path $p) {
        Write-Host "You already have a .gitignore in this dir."
        Write-Host "Fetch a fresh one from GitHub?"

        $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Fetch from Github official."
        $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Git outta here!"
        $options = [System.Management.Automation.Host.ChoiceDescription[]]($no, $yes)
        $result = $host.UI.PromptForChoice("Fetch new gitignore", "Do you want to fetch a new gitignore?", $options, 0)
        if ($result -eq 0) { "Suit yourself."; return }
        elseif ($result -eq 1) { Remove-Item .gitignore; fetch }     
    }

    fetch
}
Export-ModuleMember -Function "Add-Gitignore"

# Because you can take the boy out of Hg,
# but you can't take the Hg out of the boy

# hg in
Function Get-IncomingChangesets {

    $currentBranch = $(git rev-parse --abbrev-ref HEAD)
    if ([string]::IsNullOrEmpty($currentBranch)) {Write-Host "There was an error determining your current branch."; return}
    $trackingBranch = $(git for-each-ref --format='%(upstream:short)' $(git symbolic-ref -q HEAD))
    if ([string]::IsNullOrEmpty($trackingBranch)) {Write-Host "There was an error determining your tracking branch."; return}
    Write-Host "$currentBranch tracking on $trackingBranch...`n"
    if ($(git log "$currentBranch..$trackingBranch").length -lt 1) {Write-Host "No incoming changes.`n"; return}
    $(git log "$currentBranch..$trackingBranch") | Out-Host
}
Export-ModuleMember -Function "Get-IncomingChangesets"

# hg out
Function Get-OutgoingChangesets {

    $currentBranch = $(git rev-parse --abbrev-ref HEAD)
    if ([string]::IsNullOrEmpty($currentBranch)) {Write-Host "There was an error determining your current branch."; return}
    $trackingBranch = $(git for-each-ref --format='%(upstream:short)' $(git symbolic-ref -q HEAD))
    if ([string]::IsNullOrEmpty($trackingBranch)) {Write-Host "There was an error determining your tracking branch."; return}
    Write-Host "$currentBranch tracking on $trackingBranch...`n"
    if ($(git log "$trackingBranch..$currentBranch").length -lt 1) {Write-Host "No outgoing changes.`n"; return}
    $(git log "$trackingBranch..$currentBranch") | Out-Host
}
Export-ModuleMember -Function "Get-OutgoingChangesets"


####################################
#            CHECKSUM
####################################

Function Get-MD5Hash () {
    param(
        [parameter(Mandatory = $true)]
        [string]
        $fileName
    )

    if (!(Test-Path $fileName)) {
        Write-Host "$fileName is not a valid filename.";
        return;
    }

    $hash = certutil.exe -hashfile $fileName MD5
    return $hash[1].Trim()
}
Export-ModuleMember -Function "Get-MD5Hash"

Function Compare-MD5Hash () {
    param(
        [parameter(Mandatory = $true, Position = 1)]
        [string]$file1,
        [parameter(Mandatory = $true, Position = 2)]
        [string]$file2
    )

    if (!(Test-Path $file1)) {
        Write-Host "$file1 is not a valid filename.";
        return;
    }

    if (!(Test-Path $file2)) {
        Write-Host "$file2 is not a valid filename.";
        return;
    }

    $file1hash = certutil.exe -hashfile $file1 MD5;
    $file2hash = certutil.exe -hashfile $file2 MD5;

    if ($file1hash[1].Trim() -eq $file2hash[1].Trim()) {
        Write-Host "Files are binary equal."
        return;
    }
    else {
        Write-Host "Hashes do not match."
        return;
    }
}
Export-ModuleMember -Function "Compare-MD5Hash"