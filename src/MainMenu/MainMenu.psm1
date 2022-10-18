Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Import-Module $PSScriptRoot\..\GUI_Helper.psm1
Import-Module $PSScriptRoot\SystemInformation.psm1

function MainMenuLoadPage() {
    $script:MainMenuPageState = "Main"

    $script:SystemInformation = initializeNewLinkyButton "System Information" (50, 130)
    #$script:SystemInformation.Location = New-Object System.Drawing.Point(50, 130)
    $script:SystemInformation.Add_Click({
        ##todo
        Write-Verbose "MainMenu.ps1: SystemInformation_Click"
        #Import-Module $PSScriptRoot\SystemInformation.psm1
        $script:MainMenuPageState = "SystemInformation"
        MainMenuRemovePageItems
        LoadSystemInformationPage
        #Remove-Module SystemInformation
    })
    $WindowForm.Controls.Add($script:SystemInformation)

    $script:SystemDiagnostic = initializeNewLinkyButton "System Diagnostic" (50, 150)
    #E$script:SystemDiagnostic.Location = New-Object System.Drawing.Point
    $script:SystemDiagnostic.Enabled = $false
    # TODO - add a hover behavior saying that System Diagnostics need to be run directly from the BIOS
    $WindowForm.Controls.Add($script:SystemDiagnostic)

    $script:UpdateSystemBIOS = initializeNewLinkyButton "Update System BIOS"  (50, 170)
    #$script:UpdateSystemBIOS.Location = New-Object System.Drawing.Point 
    $script:UpdateSystemBIOS.Enabled = $false
    # TODO - figure out if a BIOS update can be done like this
    $WindowForm.Controls.Add($script:UpdateSystemBIOS)

    $script:ChangeDateTime = initializeNewLinkyButton "Change Date and Time" (50, 210)
    #$script:ChangeDateTime.Location = New-Object System.Drawing.Point(50, 210)
    $script:ChangeDateTime.Add_Click({
        # TODO: Add popup/changepage to set the Date and Time
        Write-Verbose "MainMenu.psm1: ChangeDateTime_Click"
        Import-Module $PSScriptRoot\ChangeDateTime.psm1
        LoadChangeDateTimePage
        Get-Module ChangeDateTime | Remove-Module
    })
    $WindowForm.Controls.Add($script:ChangeDateTime)
}

function MainMenuRemovePageItems() {
    $WindowForm.Controls.Remove($script:SystemInformation)
    $WindowForm.Controls.Remove($script:SystemDiagnostic)
    $WindowForm.Controls.Remove($script:UpdateSystemBIOS)
    $WindowForm.Controls.Remove($script:ChangeDateTime)
}

function MainMenuReloadPageItems() {
    Write-Verbose "Reloading MainMenuPage Items"
    $WindowForm.Controls.AddRange(@($script:SystemInformation, $script:SystemDiagnostic, $script:UpdateSystemBIOS, $script:ChangeDateTime))
    $script:MainMenuPageState = "Main"
}

function MainMenuUnloadPage() {
    Write-Verbose "MainMenu.psm1: unloadPage called. Removing items for page state $script:MainMenuPageState"
    switch ($script:MainMenuPageState){
        "Main" {
            MainMenuRemovePageItems
        }
        "ChangeDateTime" {
            UnloadChangeDateTimePage
        }
        "SystemInformation" {
            UnloadSystemInformationPage
        }
    }

    Write-Verbose "MainMenu.psm1: Removing imported modules..."

    Remove-Module SystemInformation
}
