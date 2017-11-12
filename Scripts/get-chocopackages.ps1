
#Lists all locally-installed choco packages by name

function Get-Chocopackages {
    choco list -lo | 
        % { if(!$_.Contains(" packages installed.") -and !$_.ToLower().StartsWith("chocolatey")) {
                try {$_.Substring(0, $_.IndexOf(" ")) | Out-Host } 
                catch {}
            }
        }
}