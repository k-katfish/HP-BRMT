Import-Module $PSScriptRoot\..\SessionHelper.psm1

function LoadUpdateSystemBIOSPage() {
    Write-Verbose "UpdateSystemBIOSPage.psm1: LoadUpdateSystemBIOSPage called."

    $script:TitleLabel = initializeNewStaticText "BIOS INFORMATION for $((Get-StoredCimSession).ComputerName)" (50, 150)

    $CurrentBIOSVersionString = Get-HPBIOSSettingValue -Name "System BIOS Version" -CimSession (Get-StoredCimSession)

    $script:CurrentBIOSVersionLabel = initializeNewStaticText "Current System BIOS Version:" (50, 200)
    $script:CurrentBIOSVersionText = initializeNewStaticText "$($CurrentBIOSVersionString.SubString(0, $CurrentBIOSVersionString.indexOf("  ")))" (300, 200)

    $script:CurrentBIOSReleaseLabel = initializeNewStaticText "Current BIOS Release Date:" (50, 230)
    $script:CurrentBIOSReleaseText = initializeNewStaticText "$($CurrentBIOSVersionString.SubString($CurrentBIOSVersionString.IndexOf("  ")))" (300, 230)

    $script:BackButton = initializeNewBackButton
    $script:BackButton.Add_Click({
        UnloadUpdateSystemBIOSPage
        Import-Module $PSScriptRoot\MainMenu.psm1 -Function MainMenuReloadPageItems
        MainMenuReloadPageItems
        #Remove-Module MainMenu -Function MainMenuReloadPageItems
    })

    $WindowForm.Controls.AddRange(@($script:BackButton, $script:TitleLabel
        $script:CurrentBIOSVersionLabel, $script:CurrentBIOSVersionText
        $script:CurrentBIOSReleaseLabel, $script:CurrentBIOSReleaseText
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
}