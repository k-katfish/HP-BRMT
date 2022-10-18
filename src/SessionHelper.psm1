$script:SessionInformation 
$script:BIOSSetupPassword = ""
$script:PSCredentialObject

Add-Type -AssemblyName System.Windows.Forms

Import-Module $PSScriptRoot\GUI_Helper.psm1

function Get-StoredCimSession {
    return $script:SessionInformation
}

function Set-StoredCimSession ($SessionInfo) {
    $script:SessionInformation = $SessionInfo
}

function Get-StoredBIOSCredential {
    $BIOSPW = ""
    if (-Not $script:BIOSSetupPassword) {
        Write-Verbose "Get-StoredBIOSCredential: No credentials provided yet. Requesting BIOS Setup PW."
        $BIOSPW = Get-GUIInput "Please enter the BIOS Password for $((Get-StoredCimSession).ComputerName)" "BIOS Password Required"

        if ($BIOSPW -eq "") { 
            Write-Verbose "User was unable to provide BIOS Password for $((Get-StoredCimSession).ComputerName), Storing empty string."
            Set-StoredBIOSCredential ""
            return ""
        }
    }

    Write-Verbose "Testing BIOS Credential..."

    try {
        Set-HPBIOSSetupPassword "$script:BIOSSetupPassword" -CimSession (Get-StoredCimSession) -Password "$script:BIOSSetupPassword"
    } catch {
        if ($_ -like "*incorrect password*") {
            Write-Verbose "Get-StoredBIOSCredential: Bad password provided, asking again..."
            Set-StoredBIOSCredential (Get-StoredBIOSCredential)
        }
    }

    return $script:BIOSSetupPassword
}

function Get-StoredBIOSCredential {
    if (-Not $script:BIOSSetupPassword -AND (Get-HPBIOSSetupPasswordIsSet -CimSession (Get-StoredCimSession))) {
        Write-Verbose "Get-StoredBIOSCredential: No BIOS Setup PW provided yet. Requesting Password."
        $BIOSPW = Get-GUIInput "Please enter the BIOS Password for $((Get-StoredCimSession).ComputerName)" "BIOS Password Required"

        if (-Not ($BIOSPW)) { 
            Write-Verbose "User was unable to provide BIOS Password for $((Get-StoredCimSession).ComputerName), Storing empty string."
            Set-StoredBIOSCredential ""
            return ""
        }

        Write-Verbose "Get-StoredBIOSCredential: Proceeding with BIOS password: $($BIOSPW)"

        Write-Verbose "Get-StoredBIOSCredential: Testing BIOS Password..."

        try {
            Set-HPBIOSSetupPassword "$BIOSPW" -Password "$BIOSPW" -CimSession (Get-StoredCimSession)
        } catch {
            if ($_ -like "*password*") {
                Write-Verbose "Get-StoredBIOSCredential: Bad password provided."
                $BIOSPW = Get-StoredBIOSCredential
            }
        }

        Set-StoredBIOSCredential $BIOSPW
    }

    Write-Verbose "Get-StoredBIOSCredential: Returning BIOS Password: $script:BIOSSetupPassword"
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