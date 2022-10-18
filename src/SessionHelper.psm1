$script:SessionInformation 
$script:BIOSSetupPassword
$script:PSCredentialObject

function Get-StoredCimSession {
    return $script:SessionInformation
}

function Set-StoredCimSession ($SessionInfo) {
    $script:SessionInformation = $SessionInfo
}

function Get-StoredBIOSCredential {
    return $script:BIOSSetupPassword
}

function Set-StoredBIOSCredential ($BIOSSetupPW) {
    $script:BIOSSetupPassword = $BIOSSetupPW
}

function Get-StoredPSCredential {
    if (-Not $script:PSCredentialObject) {
        Write-Verbose "Get-StoredPSCredential: No credentials provided yet. Requesting credentials."
        $CredMessage = "Please provide valid credentials."
        $user = "$env:UserDomain\$env:USERNAME"
        $Credential = Get-Credential -Message $CredMessage -UserName $user
          if (-Not $Credential) {
            Write-Verbose "Get-StoredPSCredential: User probably clicked Cancel."
            return -1
        }
        Write-Verbose "Get-StoredPSCredential: Proceeding with PSCredential Object with username: $($Credential.Username)"

        Write-Verbose "Get-StoredPSCredential: Testing PSCredential object..."

        try {
            Start-Process Powershell -ArgumentList "return 0" -Credential $Credential -WorkingDirectory 'C:\Windows\System32' -NoNewWindow
        } catch {
            if ($_ -like "*password*") {
                Write-Verbose "GetCred: Bad password provided."
                Start-Process Powershell -ArgumentList "Add-Type -AssemblyName System.Windows.Forms;",
                "[System.Windows.Forms.MessageBox]::Show('Bad Password! Try again!','Uh-oh.')" -WindowStyle Hidden
                $Credential = Get-StoredPSCredential
            } elseif ($_ -like "*is not null or empty*") {
                Write-Verbose "GetCred: No password provided."
                $OKC = Start-Process Powershell -ArgumentList "Add-Type -AssemblyName System.Windows.Forms;",
                "[System.Windows.Forms.MessageBox]::Show('Please enter a password. Click Cancel to cancel the operation.','Whoopsie.',OKCancel)" -WindowStyle Hidden
                if ($OKC -eq "Cancel") { return -1 }
                $Credential = Get-StoredPSCredential
            }
        }

        Set-StoredPSCredential $Credential
    }

    Write-Verbose "GetCreds: Returning Credential Object: $($Credential.Username)"
    return $script:PSCredentialObject
}

function Set-StoredPSCredential ([pscredential]$CredentialObject) {
    $script:PSCredentialObject = $CredentialObject
}