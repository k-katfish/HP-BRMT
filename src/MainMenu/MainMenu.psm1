Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Import-Module $PSScriptRoot\..\GUI_Helper.psm1
Import-Module $PSScriptRoot\ChangeDateTime.psm1

function MainMenuLoadPage() {
    $script:MainMenuPageState = "nostate"

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
        LoadChangeDateTimePage
    })
    $WindowForm.Controls.Add($script:ChangeDateTime)
}

function MainMenuUnloadPage() {
    Write-Verbose "MainMenu.psm1: unloadPage called. Removing items..."
    switch ($script:MainMenuPageState){
        "nostate" {
            $WindowForm.Controls.Remove($script:SystemInformation)
            $WindowForm.Controls.Remove($script:SystemDiagnostic)
            $WindowForm.Controls.Remove($script:UpdateSystemBIOS)
            $WindowForm.Controls.Remove($script:ChangeDateTime)
        }
        "ChangeDateTime" {
            UnloadChangeDateTimePage
        }

    }
    Remove-Module ChangeDateTime
}
