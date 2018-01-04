function Get-MD5Hash () {
    param(
        [parameter(Mandatory=$true)]
        [string]
        $fileName
    )

    if (!(Test-Path $fileName)) {
        Write-Host "$fileName is not a valid filename.";
        return;
    }

    certutil.exe -hashfile $fileName MD5 | Out-Host
}

function Compare-MD5Hash () {
    param(
        [parameter(Mandatory=$true,Position=1)]
        [string]$file1,
        [parameter(Mandatory=$true,Position=2)]
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

    if ($file1hash -eq $file2hash) {
        Write-Host "Files are binary equal."
        return;
    } else {
        Write-Host "Hashes do not match."
        return;
    }
}