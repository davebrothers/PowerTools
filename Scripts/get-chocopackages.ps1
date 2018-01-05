
#Lists all locally-installed choco packages by name

function Get-Chocopackages {
    try {
    choco list -lo | 
        % { if(!$_.Contains(" packages installed.") -and !$_.ToLower().StartsWith("chocolatey")) {
                try {$_.Substring(0, $_.IndexOf(" ")) | Out-Host } 
                catch {}
            }
        }
    } catch {
        Write-Host -ForegroundColor Red "An error occurred. Check that Chocolatey is installed."
        return
    }
}