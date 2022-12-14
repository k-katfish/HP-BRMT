[cmdletbinding()]
param(
    [Switch][Alias("h")]$Help,
    [String]$ComputerName = $env:COMPUTERNAME
)

$script:ComputerName = $ComputerName

Import-Module $PSScriptRoot\SessionHelper.psm1

function initializeComputerConnection{
    Write-Verbose "Initializing Connection to $script:ComputerName"

    if (-Not ((Get-StoredCimSession).ComputerName -eq $script:ComputerName)) {
        if (Get-StoredCimSession) { Remove-CimSession (Get-StoredCimSession) }
        try {
            Set-StoredCIMSession (New-CimSession $script:ComputerName -Credential (Get-StoredPSCredential) -Authentication Kerberos)
        } catch {
            if ($_ -like "*not this computer*") { }# do something }
            Write-Error "Unable to create a PSSession with $script:ComputerName. Is this a real computer, and is it online, or did you maybe provide a bad password?"
            Write-Error $_
        }
    }

    try {
        Write-Verbose "Getting BIOS Password (if required) for $((Get-StoredCimSession).ComputerName)"
        Get-StoredBIOSCredential
    } catch {
        if ($_ -like "*is not recognized*") {
            & "$PSScriptRoot\resources\hp-cmsl-1.6.8.exe" /VERYSILENT
            initializeComputerConnection
        }
    }
}

initializeComputerConnection

function initializeResources() {
    if (Get-Module GUI_Helper) { Write-Verbose "GUI_Helper loaded, unloading..."; Remove-Module GUI_Helper }
    Import-Module $PSScriptRoot\GUI_Helper.psm1
}

initializeResources

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$WindowForm = New-Object System.Windows.Forms.Form
$WindowForm.ClientSize = New-Object System.Drawing.Size(1000, 800)
$WindowForm.Text = "HP Bios Remote Management Tool"
$WindowForm.FormBorderStyle = "FixedDialog"
$WindowForm.MaximizeBox = $false

# Main/Security/Advanced/UEFI Drivers Region

$MainMenuButton = New-BigButton "Main" (50, 50) (100, 50)
$MainMenuButton.Add_Click({ switchPage "Main" })

$SecurityMenuButton = New-BigButton "Security" (150, 50) (150, 50)
$SecurityMenuButton.Add_Click({ switchPage "Security" })


$AdvancedMenuButton = New-BigButton "Advanced" (300, 50) (150, 50)
$AdvancedMenuButton.Add_Click({ switchPage "Advanced" })

$UEFIMenuButton = New-BigButton "UEFI Drivers" (450, 50) (200, 50)
$UEFIMenuButton.Add_Click({ switchPage "UEFI" })

$ComputerNameButton = New-BigButton "$script:ComputerName" (600, 50) (400, 50)
$ComputerNameButton.FlatAppearance.BorderSize = 0
$ComputerNameButton.FlatStyle = "Flat"
$ComputerNameButton.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
$ComputerNameButton.Add_Click({
    $NewComputerName = Get-GUIInput "Enter the name of the computer to connect to", "Connect to another computer"

    if ($NewComputerName) {
        Write-Verbose "User wants to connect to $NewComputerName"
        $script:ComputerName = $NewComputerName
        initializeComputerConnection

        $ComputerNameButton.Text = "$((Get-StoredCimSession).ComputerName)"
        switchPage "nostate"

        initializeResources
        switchPage "Main"
    }
})

$MainMenuButton.PerformClick()
$WindowForm.Controls.AddRange(@($MainMenuButton, $SecurityMenuButton, $AdvancedMenuButton, $UEFIMenuButton, $ComputerNameButton))

$RightClickMenu = New-Object System.Windows.Forms.ContextMenuStrip

$ReloadModules = New-Object System.Windows.Forms.ToolStripMenuItem
$ReloadModules.Text = "Reinitialize Program"
$ReloadModules.Add_Click({
    initializeComputerConnection
    initializeResources
    switchPage "Main"
})

$ForceReloadAllModules = New-Object System.Windows.Forms.ToolStripMenuItem
$ForceReloadAllModules.Text = "Reload all modules"
$ForceReloadAllModules.Add_Click({
    switchPage "nostate"
    if (Get-Module GUI_Helper) { Remove-Module GUI_Helper }
    if (Get-Module MainMenu) { Remove-Module MainMenu }
    if (Get-Module SecurityMenu) { Remove-Module SecurityMenu }
    if (Get-Module AdvancedMenu) { Remove-Module AdvancedMenu }
    if (Get-Module UEFIMenu) { Remove-Module UEFIMenu }

    initializeComputerConnection

    initializeResources
    switchPage "Main"
})

$RightClickMenu.Items.Add($ReloadModules)
$WindowForm.ContextMenuStrip = $RightClickMenu

$WindowForm.ShowDialog()

if (Get-Module GUI_Helper) { Remove-Module GUI_Helper }
if (Get-Module MainMenu) { Remove-Module MainMenu }
if (Get-Module SecurityMenu) { Remove-Module SecurityMenu }
if (Get-Module AdvancedMenu) { Remove-Module AdvancedMenu }
if (Get-Module UEFIMenu) { Remove-Module UEFIMenu }
if (Get-Module SessionHelper) { Remove-Module SessionHelper }