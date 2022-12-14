Import-Module $PSScriptRoot\..\SessionHelper.psm1

function LoadChangeDateTimePage() {
    Write-Verbose "ChangeDateTime.psm1: LoadChangeDateTimePage called."
    Write-Verbose "LoadChangeDateTimePage: Setting MainMenuPageState"

    $script:TitleLabel = New-StaticText "Change Date and Time for $((Get-StoredCimSession).ComputerName)" (50, 150)
    $script:SetDateLabel = New-StaticText "Set Date (MM/DD/YYYY):" (50, 180)
    $script:SetTimeLabel = New-StaticText "Set Time (HH:MM):" (50, 200)

    $CurrentDate = (Get-CimInstance -CimSession (Get-StoredCimSession) -ClassName Win32_OperatingSystem).LocalDateTime

    $script:MonthText = New-EditableText "$($CurrentDate.ToString("MM"))" (200, 180)
    $script:MDSlash = New-StaticText '/' (220, 180)
    $script:DayText = New-EditableText "$($CurrentDate.ToString("dd"))" (240, 180)
    $script:DYSlash = New-StaticText '/' (260, 180)
    $script:YearText = New-EditableText "$($CurrentDate.ToString("yyyy"))" (280, 180)

    $script:HourText = New-EditableText "$($CurrentDate.ToString("HH"))" (200, 200)
    $script:HMSlash = New-StaticText '/' (220, 200)
    $script:MinuteText = New-EditableText "$($CurrentDate.ToString("mm"))" (240, 200)

    $script:SetButton = New-LinkyText 'Set Date/Time to these values and return to main menu.' (50, 300)
    $script:SetButton.Add_Click({
        $NewDateTime = New-Object DateTime($script:YearText.Text, $script:MonthText.Text, $script:DayText.Text, $script:HourText.Text, $script:MinuteText.Text, 0)
        (Get-CimInstance Win32_OperatingSystem) | Invoke-CimMethod -MethodName SetDateTime -Arguments @{LocalDateTime=$NewDateTime} -CimSession (Get-StoredCimSession)
        $script:BackButton.PerformClick()
    })

    $script:BackButton = New-BackButton
    $script:BackButton.Add_Click({
        UnloadChangeDateTimePage
        Import-Module $PSScriptRoot\MainMenu.psm1 -Function MainMenuReloadPageItems
        MainMenuReloadPageItems
    })

    $WindowForm.Controls.AddRange(@($script:BackButton, $script:TitleLabel
        $script:SetDateLabel, $script:SetTimeLabel
        $script:MonthText, $script:MDSlash, $script:DayText, $script:DYSlash, $script:YearText
        $script:HourText, $script:HMSlash, $script:MinuteText
        $script:SetButton
    ))
}

function UnloadChangeDateTimePage() {
    $WindowForm.Controls.Remove($script:BackButton)
    $WindowForm.Controls.Remove($script:TitleLabel)
    $WindowForm.Controls.Remove($script:SetTimeLabel)
    $WindowForm.Controls.Remove($script:SetDateLabel)
    $WindowForm.Controls.Remove($script:MonthText)
    $WindowForm.Controls.Remove($script:MDSlash)
    $WindowForm.Controls.Remove($script:DayText)
    $WindowForm.Controls.Remove($script:DYSlash)
    $WindowForm.Controls.Remove($script:YearText)
    $WindowForm.Controls.Remove($script:HourText)
    $WindowForm.Controls.Remove($script:HMSlash)
    $WindowForm.Controls.Remove($script:MinuteText)
    $WindowForm.Controls.Remove($script:SetButton)
}
