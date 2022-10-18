Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function SecurityMenuLoadPage() {
    $script:AdminToolsHeader = initializeNewStaticText "Administrator Tools" (50, 120)

    $script:CreateBIOSSetupPasswordButton = initializeNewLinkyButton "Manage BIOS Setup Password" (50, 140)
    $script:CreateBIOSSetupPasswordButton.Add_Click({
        ManageBIOSSetupPassword
    })
    
    $script:CreatePOSTPasswordButton = initializeNewLinkyButton "Manage POST Power-On Password" (50, 160)
    $script:CreatePOSTPasswordButton.Add_Click({
        ManagePOSTPassword
    })

    $WindowForm.Controls.AddRange(@(
        $script:AdminToolsHeader, 
        $script:CreateBIOSSetupPasswordButton, 
        $script:CreatePOSTPasswordButton))


}

function SecurityMenuUnloadPage() {
    $WindowForm.Controls.Remove($script:AdminToolsHeader)
    $WindowForm.Controls.Remove($script:CreateBIOSSetupPasswordButton)
    $WindowForm.Controls.Remove($script:CreatePOSTPasswordButton)
}

function ManageBIOSSetupPassword() {
    if (Get-HPBIOSSetupPasswordIsSet -CimSession (Get-StoredCimSession)) {
        $DoManagePassword = Get-GUIInput "There is already a BIOS Setup password set. Do you wish to change or remove it? Enter 'Change' to change the password, or 'Remove' to remove it. Click 'Cancel' to do nothing." "Manage BIOS Setup Password"
        if ($DoManagePassword -like "*Change*") {
            ChangeBIOSPassword
        } elseif ($DoManagePassword -like "*Remove*") {
            if ((Get-GUIConfirmation "Are you sure you want to remove the BIOS Setup Password on $((Get-StoredCimSession).ComputerName)?" "Confirmation")  -eq "Yes") { 
                Clear-HPBIOSSetupPassword -CimSession (Get-StoredCimSession) -Password (Get-StoredBIOSCredential)
            }
        }
    } else {
        ChangeBIOSPassword
    }
}

function ChangeBIOSPassword() {
    $PWToSet = Get-GUIInput "Create an HP BIOS Setup Password for $((Get-StoredCimSession).ComputerName)" "Create an HP BIOS Setup Password"
    if ($PWToSet) {
        $Confirmation = Get-GUIConfirmation "Are you sure you want to set BIOS Setup Password '$PWToSet' on $((Get-StoredCimSession).ComputerName)?" "Confirmation"
        #$Confirmation = [System.Windows.Forms.MessageBox]::Show("Are you sure to set BIOS Setup password $PWToSet on $((Get-StoredCimSession).ComputerName)?", "Confirmation", "YesNo", "Warning")
        if ($Confirmation -eq "Yes") {
            Set-HPBIOSSetupPassword "$PWToSet" -CimSession (Get-StoredCimSession) -Password (Get-StoredBIOSCredential)
            Set-StoredBIOSCredential $PWToSet
        }
    }
}

function ManagePOSTPassword() {
    if (Get-HPBIOSPowerOnPasswordIsSet -CimSession (Get-StoredCimSession)) {
        $DoManagePassword = Get-GUIInput "There is already a POST Power-On password set. Do you wish to change or remove it? Enter 'Change' to change the password, or 'Remove' to remove it. Click 'Cancel' to do nothing." "Manage POST Password"
        if ($DoManagePassword -like "*Change*") {
            ChangePOSTPassword
        } elseif ($DoManagePassword -like "*Remove*") {
            if ((Get-GUIConfirmation "Are you sure you want to remove the POST Password on $((Get-StoredCimSession).ComputerName)?" "Confirmation")  -eq "Yes") { 
                Clear-HPBIOSPowerOnPassword -CimSession (Get-StoredCimSession) -Password (Get-StoredBIOSCredential)
            }
        }
    } else {
        ChangePOSTPassword
    }
}

function ChangePOSTPassword() {
    $PWToSet = Get-GUIInput "Create an HP BIOS POST Power-On Password for $((Get-StoredCimSession).ComputerName)" "Create an HP POST Password"
    if ($PWToSet) {
        $Confirmation = Get-GUIConfirmation "Are you sure to set POST password '$PWToSet' on $((Get-StoredCimSession).ComputerName)?" "Confirmation"
        #$Confirmation = [System.Windows.Forms.MessageBox]::Show("Are you sure to set POST password $PWToSet on $((Get-StoredCimSession).ComputerName)?", "Confirmation", "YesNo", "Warning")
        if ($Confirmation -eq "Yes") {
            Set-HPBIOSPowerOnPassword "$PWToSet" -CimSession (Get-StoredCimSession) -Password (Get-StoredBIOSCredential)
        }
    }
}