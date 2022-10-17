[cmdletbinding()]
param(
    [Switch][Alias("h")]$Help,
    [String]$ComputerName = $env:COMPUTERNAME
)

$script:ComputerName = $ComputerName

function initializeComputerConnection{
    Write-Verbose "Initializing Connection to $script:ComputerName"
    try {
        Write-Verbose "Testing if HP Bios has a password on $script:ComputerName"
        if (Get-HPBIOSSetupPasswordIsSet -ComputerName $script:ComputerName) {
            Write-Verbose "HP BIOS Password is set. Asking user for the password..."
            $script:SetupPw= [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
            $script:SetupPw= [Microsoft.VisualBasic.Interaction]::InputBox("Enter HP BIOS Setup Password for $script:ComputerName", "HP BIOS Setup password required") 
            Write-Verbose "User entered $script:SetupPw"
            Write-Information "User entered $script:SetupPw"
        } else {
            Write-Verbose "HP BIOS has no password setup on $script:ComputerName"
        }
    } catch {
        if ($_ -like "*is not recognized*") {
            & "$PSScriptRoot\resources\hp-cmsl-1.6.8.exe" /VERYSILENT
            initializeComputerConnection
        }
    }
}

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

$MainMenuButton = initializeNewBigButton "Main" (50, 50) (100, 50)
#$MainMenuButton.Location = New-Object System.Drawing.Point(50, 50)
#$MainMenuButton.Size = New-Object System.Drawing.Size(100, 50)
#$MainMenuButton.Font = New-Object System.Drawing.Font("Arial", 15)
#$MainMenuButton.Text = "Main"
$MainMenuButton.Add_Click({ switchPage "Main" })

$SecurityMenuButton = initializeNewBigButton "Security" (150, 50) (150, 50)
$SecurityMenuButton.Add_Click({ switchPage "Security" })


$AdvancedMenuButton = initializeNewBigButton "Advanced" (300, 50) (150, 50)
$AdvancedMenuButton.Add_Click({ switchPage "Advanced" })

$UEFIMenuButton = initializeNewBigButton "UEFI Drivers" (450, 50) (200, 50)
$UEFIMenuButton.Add_Click({ switchPage "UEFI" })

$ComputerNameButton = initializeNewBigButton "$script:ComputerName" (600, 50) (200, 50)
$ComputerNameButton.FlatAppearance.BorderSize = 0
$ComputerNameButton.FlatStyle = "Flat"
$ComputerNameButton.Add_Click({
    $script:ComputerName = [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
    $script:ComputerName = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the name of the computer to connect to", "Connect to another computer")

    $ComputerNameButton.Text = "$script:ComputerName"

    initializeComputerConnection

    initializeResources
    switchPage "Main"
})

#$MainMenuButton.PerformClick()
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
    if (Get-Module GUI_Helper) { Remove-Module GUI_Helper }
    if (Get-Module MainMenu) { Remove-Module MainMenu }
    if (Get-Module ChangeDateTime ) { Remove-Module ChangeDateTime }
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