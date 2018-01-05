
function Run-ProjectTests() {
    Param(
        [switch]$openInBrowser
    )
    #Is Chutzpah installed?
    $chutzpah
    Write-Host "Locating Chutzpah..."
    try {
        Test-Path ($chutzpah = gci -Recurse "chutzpah.console.exe") 
    } catch {
        Write-Host -ForegroundColor Red "Cannot find Chutzpah in solution packages. Have you installed the nuget package?"
        return;
    }
    Write-Host "OK!" -ForegroundColor Green

    $testfiles = gci -Recurse "*.tests.js"

    Write-Host "The following test files have been found in the solution:" -ForegroundColor DarkYellow
    $testfiles | % { Write-Host $_.Name }

    $testdirs = $testfiles | % { $_.Directory }
    
    
    Write-Host ""
    Write-Host "Run these tests now?"
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Kick off tests"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Exit"
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($no, $yes)
    $result = $host.UI.PromptForChoice("Test listed specs", "Do you want to run these tests now?", $options, 0)
    if ($result -eq 0) { "Suit yourself."; return }
    elseif($result -eq 1) {
        if ($openInBrowser) {
            $testdirs | Get-Unique | % { & $chutzpah $_ /openInBrowser}
        }else {
            $testdirs | Get-Unique | % { & $chutzpah $_ }
        }
    }
}