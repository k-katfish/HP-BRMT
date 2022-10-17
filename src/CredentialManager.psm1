function Set-WindowsCredential ($userString) {
    $script:Credential = "null"

    while ($script:Credential -eq "null") {
        $script:Credential = Get-Credential $userString

        try {
            Start-Process Powershell.exe -ArgumentList "/c return 0" -NoNewWindow -Credential $script:Credential
        } catch {
            if ($_ -like "*incorrect*") { Write-Verbose "Bad password, try again"; $script:Credential = "null" }
        }
    }
}

function Get-WindowsCredential () {
    return $script:Credential
}

Set-WindowsCredential "$env:UserDomain\$env:UserName"