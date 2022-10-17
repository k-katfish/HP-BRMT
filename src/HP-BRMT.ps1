[cmdletbinding()]
param(
    [Switch][Alias("h")]$Help,
    [String]$ComputerName = $env:COMPUTERNAME
)

try {
    Write-Verbose "Testing if HP Bios has a password on $ComputerName"
    if (Get-HPBIOSSetupPasswordIsSet -ComputerName $ComputerName) {
        Write-Verbose "HP BIOS Password is set. Asking user for the password..."
        $script:SetupPw= [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
        $script:SetupPw= [Microsoft.VisualBasic.Interaction]::InputBox("Enter HP BIOS Setup Password for $ComputerName", "HP BIOS Setup password required") 
        Write-Verbose "User entered $script:SetupPw"
        Write-Information "User entered $script:SetupPw"
    } else {
        Write-Verbose "HP BIOS has no password setup on $ComputerName"
    }
} catch {
    if ($_ -like "*is not recognized*") {
        & "$PSScriptRoot\resources\hp-cmsl-1.6.8.exe" /VERYSILENT
    }
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$WindowForm = New-Object System.Windows.Forms.Form
$WindowForm.ClientSize = New-Object System.Drawing.Size(1000, 800)
$WindowForm.Text = "HP Bios Remote Management Tool"
$WindowForm.FormBorderStyle = "FixedDialog"
$WindowForm.MaximizeBox = $false

# Main/Security/Advanced/UEFI Drivers Region

$script:PageState = "nostate"

$MainMenuButton = New-Object System.Windows.Forms.Button
$MainMenuButton.Location = New-Object System.Drawing.Point(50, 50)
$MainMenuButton.Size = New-Object System.Drawing.Size(100, 50)
$MainMenuButton.Font = New-Object System.Drawing.Font("Arial", 15)
$MainMenuButton.Text = "Main"

$SecurityMenuButton = New-Object System.Windows.Forms.Button
$SecurityMenuButton.Location = New-Object System.Drawing.Point(150, 50)
$SecurityMenuButton.Size = New-Object System.Drawing.Size(150, 50)
$SecurityMenuButton.Font = New-Object System.Drawing.Font("Arial", 15)
$SecurityMenuButton.Text = "Security"

$AdvancedMenuButton = New-Object System.Windows.Forms.Button
$AdvancedMenuButton.Location = New-Object System.Drawing.Point(300, 50)
$AdvancedMenuButton.Size = New-Object System.Drawing.Size(150, 50)
$AdvancedMenuButton.Font = New-Object System.Drawing.Font("Arial", 15)
$AdvancedMenuButton.Text = "Advanced"

$UEFIMenuButton = New-Object System.Windows.Forms.Button
$UEFIMenuButton.Location = New-Object System.Drawing.Point(450, 50)
$UEFIMenuButton.Size = New-Object System.Drawing.Size(200, 50)
$UEFIMenuButton.Font = New-Object System.Drawing.Font("Arial", 15)
$UEFIMenuButton.Text = "UEFI Drivers"

$MainMenuButton.Add_Click({
    $MainMenuButton.Enabled = $false
    $MainMenuButton.FlatStyle = "Flat"

    switch ($PageState) {
        "Security" {
            unloadPage
            Remove-Module SecurityMenu
            $SecurityMenuButton.Enabled = $true
            $SecurityMenuButton.FlatStyle = "Standard"
        }
        "Advanced" {
            unloadPage
            Remove-Module AdvancedMenu
            $AdvancedMenuButton.Enabled = $true
            $AdvancedMenuButton.FlatStyle = "Standard"
        }
        "UEFI" {
            unloadPage
            Remove-Module UEFIMenu
            $UEFIMenuButton.Enabled = $true
            $UEFIMenuButton.FlatStyle = "Standard"
        }
        "nostate" {}
    }

    $script:PageState = "Main"

    Import-Module $PSScriptRoot\$($script:PageState)Menu\$($script:PageState)Menu.psm1
    loadPage
})

$SecurityMenuButton.Add_Click({
    $SecurityMenuButton.Enabled = $false
    $SecurityMenuButton.FlatStyle = "Flat"

    Write-Verbose "Calling unloadPage from wherever it came from..."
    unloadPage

    switch ($script:PageState) {
        Main {
            Remove-Module MainMenu
            $MainMenuButton.Enabled = $true
            $MainMenuButton.FlatStyle = "Standard"
        }
        "Advanced" {
            Remove-Module AdvancedMenu
            $AdvancedMenuButton.Enabled = $true
            $AdvancedMenuButton.FlatStyle = "Standard"
        }
        "UEFI" {
            Remove-Module UEFIMenu
            $UEFIMenuButton.Enabled = $true
            $UEFIMenuButton.FlatStyle = "Standard"
        }
    }

    $script:PageState = "Security"

    Import-Module $PSScriptRoot\$($script:PageState)Menu\$($script:PageState)Menu.psm1
    loadPage
})

$AdvancedMenuButton.Add_Click({
    $AdvancedMenuButton.Enabled = $false
    $AdvancedMenuButton.FlatStyle = "Flat"

    unloadPage

    switch ($script:PageState) {
        "Main" {
            Remove-Module MainMenu
            $MainMenuButton.Enabled = $true
            $MainMenuButton.FlatStyle = "Standard"
        }
        "Security" {
            Remove-Module SecurityMenu
            $SecurityMenuButton.Enabled = $true
            $SecurityMenuButton.FlatStyle = "Standard"
        }
        "UEFI" {
            Remove-Module UEFIMenu
            $UEFIMenuButton.Enabled = $true
            $UEFIMenuButton.FlatStyle = "Standard"
        }
    }

    $script:PageState = "Advanced"

    Import-Module $PSScriptRoot\$($script:PageState)Menu\$($script:PageState)Menu.psm1
    loadPage
})


$UEFIMenuButton.Add_Click({
    $UEFIMenuButton.Enabled = $false
    $UEFIMenuButton.FlatStyle = "Flat"
    
    unloadPage

    switch ($script:PageState) {
        "Main" {
            Remove-Module MainMenu
            $MainMenuButton.Enabled = $true
            $MainMenuButton.FlatStyle = "Standard"
        }
        "Security" {
            Remove-Module SecurityMenu
            $SecurityMenuButton.Enabled = $true
            $SecurityMenuButton.FlatStyle = "Standard"
        }
        "Advanced" {
            Remove-Module AdvancedMenu
            $AdvancedMenuButton.Enabled = $true
            $AdvancedMenuButton.FlatStyle = "Standard"
        }
    }

    $script:PageState = "UEFI"

    Import-Module $PSScriptRoot\$($script:PageState)Menu\$($script:PageState)Menu.psm1
    loadPage
})

$MainMenuButton.PerformClick()
$WindowForm.Controls.AddRange(@($MainMenuButton, $SecurityMenuButton, $AdvancedMenuButton, $UEFIMenuButton))

$RightClickMenu = New-Object System.Windows.Forms.ContextMenu

$ReloadModules = New-Object System.Windows.Forms.ToolStripMenuItem
$ReloadModules.Text = "Reload Modules"
$ReloadModules.Add_Click({
    Remove-Module "$($script:PageState)Menu"
    Import-Module $PSScriptRoot\$($script:PageState)Menu\$($script:PageState)Menu.psm1
})

$RightClickMenu.MenuItems.Add($ReloadModules)
$WindowForm.ContextMenu = $RightClickMenu

$WindowForm.ShowDialog()