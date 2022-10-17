Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Import-Module $PSScriptRoot\..\GUI_Helper.psm1

function loadPage() {
    $script:MainMenuPageState = nostate

    $script:SystemInformation = initializeNewLinkyButton("System Information")
    $script:SystemInformation.Location = New-Object System.Drawing.Point(50, 130)
    $script:SystemInformation.Add_Click({
        ##todo
        Write-Verbose "MainMenu.ps1: SystemInformation_Click"
        ##Import-Module
    })
    $WindowForm.Controls.Add($script:SystemInformation)

    $script:SystemDiagnostic = initializeNewLinkyButton("System Diagnostic")
    $script:SystemDiagnostic.Location = New-Object System.Drawing.Point(50, 150)
    $script:SystemDiagnostic.Enabled = $false
    # TODO - add a hover behavior saying that System Diagnostics need to be run directly from the BIOS
    $WindowForm.Controls.Add($script:SystemDiagnostic)

    $script:UpdateSystemBIOS = initializeNewLinkyButton("Update System BIOS")
    $script:UpdateSystemBIOS.Location = New-Object System.Drawing.Point(50, 170)
    $script:UpdateSystemBIOS.Enabled = $false
    # TODO - figure out if a BIOS update can be done like this
    $WindowForm.Controls.Add($script:UpdateSystemBIOS)

    $script:ChangeDateTime = initializeNewLinkyButton("Change Date and Time")
    $script:ChangeDateTime.Location = New-Object System.Drawing.Point(50, 210)
    $script:ChangeDateTime.Add_Click({
        # TODO: Add popup/changepage to set the Date and Time
        Write-Verbose "MainMenu.psm1: ChangeDateTime_Click"
    })
    $WindowForm.Controls.Add($script:ChangeDateTime)
}

function unloadPage() {
    Write-Verbose "MainMenu.psm1: unloadPage called. Removing items..."
    switch ($script:MainMenuPageState){
        nostate {
            $WindowForm.Controls.Remove($script:SystemInformation)
            $WindowForm.Controls.Remove($script:SystemDiagnostic)
            $WindowForm.Controls.Remove($script:UpdateSystemBIOS)
            $WindowForm.Controls.Remove($script:ChangeDateTime)
        }

    }
}

function ChangeDateTimePage() {
    Write-Verbose "MainMenu.psm1: ChangeDateTimePage: called."
    Write-Verbose "MainMenu.psm1: ChangeDateTimePage: Unloading Page"
    unloadPage
    Write-Verbose "MainMenu.psm1: ChangeDateTimePage: Setting MainMenuPageState"
    $script:MainMenuPageState = ChangeDateTime

    $TitleLabel = New-Object System.Windows.Forms.Label
    $TitleLabel.AutoSize = $true
    $TitleLabel.Text = "Change Date and Time"
    $TitleLabel.Location = New-Object System.Drawing.Point(50, 130)

    $SetDateLabel = New-Object System.Windows.Forms.Label
    $SetDateLabel.AutoSize = $true
    $SetDateLabel.Text = "Set Date (MM/DD/YYYY)"
    $SetDateLabel.Location = New-Object System.Drawing.Point(50, 180)
    
    $SetTimeLabel = New-Object System.Windows.Forms.Label
    $SetTimeLabel.AutoSize = $true
    $SetTimeLabel.Text = "Set Time (HH:MM):"
    $SetTimeLabel.Location = New-Object System.Drawing.Point(50, 200)

    $DayText = initializeNewEditableText(Get-Date -ComputerName $ComputerName -Format "dd")


    $WindowForm.Controls.AddRange(@($TitleLabel, $SetDateLabel, $SetTimeLabel, $DayText))
   # 06 / 04 / 2018

}