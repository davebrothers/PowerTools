function New-Gitignore {
    function fetch {
        Write-Host -NoNewLine "Creating new "
        Write-Host -NoNewLine -ForegroundColor Magenta "Visual Studio" 
        Write-Host "-flavored .gitignore."
        $wc = New-Object System.Net.WebClient
        Try {
            $wc.DownloadString("https://raw.githubusercontent.com/github/gitignore/master/VisualStudio.gitignore") | New-Item -Name ".gitignore"
        } Catch {
            Write-Host "Sorry, there was a problem fetching the file."
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
        elseif($result -eq 1) { rm .gitignore; fetch }     
    }

    fetch
}