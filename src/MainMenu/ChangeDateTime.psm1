function LoadChangeDateTimePage() {
    Write-Verbose "ChangeDateTimePage.psm1: ChangeDateTimePage called."
    Write-Verbose "ChangeDateTimePage: Unloading Page"
    unloadPage
    Write-Verbose "ChangeDateTimePage: Setting MainMenuPageState"
    $script:MainMenuPageState = ChangeDateTime

    $script:TitleLabel = New-Object System.Windows.Forms.Label
    $script:TitleLabel.AutoSize = $true
    $script:TitleLabel.Text = "Change Date and Time"
    $script:TitleLabel.Location = New-Object System.Drawing.Point(50, 130)

    $script:SetDateLabel = New-Object System.Windows.Forms.Label
    $script:SetDateLabel.AutoSize = $true
    $script:SetDateLabel.Text = "Set Date (MM/DD/YYYY)"
    $script:SetDateLabel.Location = New-Object System.Drawing.Point(50, 180)
    
    $script:SetTimeLabel = New-Object System.Windows.Forms.Label
    $script:SetTimeLabel.AutoSize = $true
    $script:SetTimeLabel.Text = "Set Time (HH:MM):"
    $script:SetTimeLabel.Location = New-Object System.Drawing.Point(50, 200)

    $script:DayText = initializeNewEditableText(Get-Date -ComputerName $ComputerName -Format "dd")

    $WindowForm.Controls.AddRange(@($script:TitleLabel, $script:SetDateLabel, $script:SetTimeLabel, $script:DayText))
   # 06 / 04 / 2018
}

function UnloadChangeDateTimePage() {
    $WindowForm.Controls.Remove($script:TitleLabel)
    $WindowForm.Controls.Remove($script:SetDateLabel)
    $WindowForm.Controls.Remove($script:SetTimeLabel)
    $WindowForm.Controls.Remove($script:DayText)
#    $WindowForm.Controls.Remove($script:TitleLabel)
}