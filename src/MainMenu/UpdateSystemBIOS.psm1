Import-Module $PSScriptRoot\..\SessionHelper.psm1

function LoadUpdateSystemBIOSPage() {
    Write-Verbose "UpdateSystemBIOSPage.psm1: LoadUpdateSystemBIOSPage called."

    $script:TitleLabel = New-StaticText "BIOS INFORMATION for $((Get-StoredCimSession).ComputerName)" (50, 150)

    $CurrentBIOSVersionString = Get-HPBIOSSettingValue -Name "System BIOS Version" -CimSession (Get-StoredCimSession)

    $script:CurrentBIOSVersionLabel = New-StaticText "Current System BIOS Version:" (50, 200)
    $script:CurrentBIOSVersionText = New-StaticText "$($CurrentBIOSVersionString.SubString(0, $CurrentBIOSVersionString.indexOf("  ")))" (300, 200)

    $script:CurrentBIOSReleaseLabel = New-StaticText "Current BIOS Release Date:" (50, 230)
    $script:CurrentBIOSReleaseText = New-StaticText "$($CurrentBIOSVersionString.SubString($CurrentBIOSVersionString.IndexOf("  ")))" (300, 230)

    $script:Divider = New-StaticText '-------------------------------------------------------------------' (50, 250)

    $script:UpdateHelpExplain = New-EditableText "https://developers.hp.com/hp-client-management/doc/get-hpbiosupdates" (300, 280)

    $script:CheckHPDotComForBIOSUpdates = New-LinkyText "Check HP.com for BIOS Updates" (50, 280)
    $script:CheckHPDotComForBIOSUpdates.Add_Click({
        Get-GUIConfirmation "This is tricky to implement, and might happen in the future. See https://developers.hp.com/hp-client-management/doc/get-hpbiosupdates for why it's so tricky." "Ha lol. Maybe someday..." "OK"
        #Get-HPBIOSUpdates -CimSession (Get-StoredCimSession)
        $WindowForm.Controls.Add($script:UpdateHelpExplain)
    })

    $script:LockBIOSVersionCheckbox = New-CheckBox "Lock BIOS Version" (50, 340) (CheckIfBIOSVersionIsLocked)
    $script:LockBIOSVersionCheckbox.Add_Click({
        $ValueString = "Disable"
        if ($script:LockBIOSVersionCheckbox.CheckedState) {$ValueString = "Enable"} else {$ValueString = "Disable"}

        try{
            Set-HPBIOSSettingValue -Name "Lock BIOS Version" -CimSession (Get-StoredCimSession) -Value "$ValueString" -Password (Get-StoredBIOSCredential)
        } catch {}

        $script:LockBIOSVersionCheckbox.Checked = (CheckIfBIOSVersionIsLocked)
    })

    $script:RollBackPolicyLabel = New-StaticText "BIOS Rollback Policy" (50, 370)
    $script:RollBackPolicyDropdown = New-DropdownMenu (200, 370)
    $script:RollBackPolicyDropdown.Items.AddRange(@("Unrestricted Rollback to older BIOS", "Restricted Rollback to older BIOS"))
    $script:RollBackPolicyDropdown.SelectedIndex = $script:RollBackPolicyDropdown.Items.IndexOf((Get-BIOSRollbackPolicy))
    $script:RollBackPolicyDropdown.Add_SelectedIndexChanged({
        Set-BIOSRollbackPolicy ($script:RollBackPolicyDropdown.SelectedText)
    })

    $script:BackButton = New-BackButton
    $script:BackButton.Add_Click({
        UnloadUpdateSystemBIOSPage
        Import-Module $PSScriptRoot\MainMenu.psm1 -Function MainMenuReloadPageItems
        MainMenuReloadPageItems
        #Remove-Module MainMenu -Function MainMenuReloadPageItems
    })

    $WindowForm.Controls.AddRange(@($script:BackButton, $script:TitleLabel
        $script:CurrentBIOSVersionLabel, $script:CurrentBIOSVersionText
        $script:CurrentBIOSReleaseLabel, $script:CurrentBIOSReleaseText
        $script:Divider
        $script:CheckHPDotComForBIOSUpdates
        $script:LockBIOSVersionCheckbox
        $script:RollBackPolicyLabel, $script:RollBackPolicyDropdown
    ))
   # 06 / 04 / 2018
}

function UnloadUpdateSystemBIOSPage() {
    $WindowForm.Controls.Remove($script:BackButton)
    $WindowForm.Controls.Remove($script:TitleLabel)
    $WindowForm.Controls.Remove($script:CurrentBIOSVersionLabel)
    $WindowForm.Controls.Remove($script:CurrentBIOSVersionText)
    $WindowForm.Controls.Remove($script:CurrentBIOSReleaseLabel)
    $WindowForm.Controls.Remove($script:CurrentBIOSReleaseText)
    $WindowForm.Controls.Remove($script:Divider)
    $WindowForm.Controls.Remove($script:CheckHPDotComForBIOSUpdates)
    try {
        $WindowForm.Controls.Remove($script:UpdateHelpExplain)
    } catch {}
    $WindowForm.Controls.Remove($script:LockBIOSVersionCheckbox)
    $WindowForm.Controls.Remove($script:RollBackPolicyLabel)
    $WindowForm.Controls.Remove($script:RollBackPolicyDropdown)
}

function CheckIfBIOSVersionIsLocked() {
    if ((Get-HPBIOSSettingValue -Name "Lock BIOS Version" -CimSession (Get-StoredCimSession)) -eq "Disable") { 
        return $false 
    } else { 
        return $true 
    } 
}

function Get-BIOSRollbackPolicy() {
    return Get-HPBIOSSettingValue -Name "BIOS Rollback Policy" -CimSession (Get-StoredCimSession)
}

function Set-BIOSRollbackPolicy($Policy) {
    try {
        Set-HPBIOSSettingValue -Name "BIOS Rollback Policy" -Value "$Policy" -CimSession (Get-StoredCimSession) -Password (Get-StoredBIOSCredential)
    } catch {
        $script:RollBackPolicyDropdown.SelectedIndex = $script:RollBackPolicyDropdown.Items.IndexOf((Get-BIOSRollbackPolicy))
    }
}