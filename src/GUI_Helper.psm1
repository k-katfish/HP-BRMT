Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$script:PageState = "nostate"

function switchPage($Page) {
    Write-Verbose "Switching page from $script:PageState to $Page"
    switch ($script:PageState) {
        "Main" {
            MainMenuUnloadPage
            Remove-Module MainMenu
            $MainMenuButton.Enabled = $true
            $MainMenuButton.FlatStyle = "Standard"
        }
        "Security" {
            SecurityMenuUnloadPage
            Remove-Module SecurityMenu
            $SecurityMenuButton.Enabled = $true
            $SecurityMenuButton.FlatStyle = "Standard"
        }
        "Advanced" {
            AdvancedMenuUnloadPage
            Remove-Module AdvancedMenu
            $AdvancedMenuButton.Enabled = $true
            $AdvancedMenuButton.FlatStyle = "Standard"
        }
        "UEFI" {
            UEFIMenuUnloadPage
            Remove-Module UEFIMenu
            $UEFIMenuButton.Enabled = $true
            $UEFIMenuButton.FlatStyle = "Standard"
        }
        "nostate" { }
    }

    switch ($Page) {
        "Main" {
            $MainMenuButton.Enabled = $false
            $MainMenuButton.FlatStyle = "Flat"
            Import-Module $PSScriptRoot\MainMenu\MainMenu.psm1
            MainMenuLoadPage
        }
        "Security" {
            $SecurityMenuButton.Enabled = $false
            $SecurityMenuButton.FlatStyle = "Flat"
            Import-Module $PSScriptRoot\SecurityMenu\SecurityMenu.psm1
            SecurityMenuLoadPage
        }
        "Advanced" {
            $AdvancedMenuButton.Enabled = $false
            $AdvancedMenuButton.FlatStyle = "Flat"
            Import-Module $PSScriptRoot\AdvancedMenu\AdvancedMenu.psm1
            AdvancedMenuLoadPage
        }
        "UEFI" {
            $UEFIMenuButton.Enabled = $false
            $UEFIMenuButton.FlatStyle = "Flat"
            Import-Module $PSScriptRoot\UEFIMenu\UEFIMenu.psm1
            UEFIMenuLoadPage
        }
        "nostate" { }
    }

    $script:PageState = $Page
}

function New-BigButton($Text, $Location, $Size) {
    $BigButton = New-Object System.Windows.Forms.Button
    $BigButton.Size = New-Object System.Drawing.Size($Size[0], $Size[1]) #New-Object System.Drawing.Size(150, 50)
    $BigButton.Font = New-Object System.Drawing.Font("Arial", 15)
    $BigButton.Location = New-Object System.Drawing.Point($Location[0], $Location[1])
    $BigButton.Text = $Text
    
    return $BigButton
}

function New-LinkyText($Text, $Location) {
    $ButtonObject = New-Object System.Windows.Forms.Button
    $ButtonObject.Location = New-Object System.Drawing.Point($Location[0], $Location[1])
    $ButtonObject.FlatAppearance.BorderSize = 0
    $ButtonObject.FlatStyle = "Flat"
    $ButtonObject.AutoSize = $true
    $ButtonObject.Text = $Text

    return $ButtonObject
}

function New-EditableText($Text, $Location) {
    $TextBoxObject = New-Object System.Windows.Forms.TextBox
    $TextBoxObject.BorderStyle = 0
    $TextBoxObject.Size = New-Object System.Drawing.Size((5+(($Text.Length)*6)), 20)
#    $TextBoxObject.AutoSize = $true
    $TextBoxObject.Text = $Text
    $TextBoxObject.Location = New-Object System.Drawing.Point($Location[0], $Location[1])
    
    return $TextBoxObject
}

function New-StaticText($Text, $Location) {
    $LabelObject = New-Object System.Windows.Forms.Label
    $LabelObject.Location = New-Object System.Drawing.Point($Location[0], $Location[1])
    $LabelObject.AutoSize = $true
    $LabelObject.Text = $Text

    return $LabelObject
}

function New-BackButton() {
    $BackButton = New-Object System.Windows.Forms.Button
    $BackButton.AutoSize = $true #.Size = New-Object System.Drawing.Size(50, 100) #New-Object System.Drawing.Size(150, 50)
    $BackButton.Font = New-Object System.Drawing.Font("Arial", 10)
    $BackButton.Location = New-Object System.Drawing.Point(5, 110)
    $BackButton.Text = "<- Back"
    
    return $BackButton
}

function New-CheckBox($Text, $Location, $DefaultCheckedState=$false){
    $CheckBoxObject = New-Object System.Windows.Forms.CheckBox
    $CheckBoxObject.AutoSize = $true
    $CheckBoxObject.Location = New-Object System.Drawing.Point($Location[0], $Location[1])
    $CheckBoxObject.Text = $Text
    $CheckBoxObject.Checked = $DefaultCheckedState

    return $CheckBoxObject
}

function New-DropdownMenu($Location) {
    $ComboBoxObject = New-Object System.Windows.Forms.ComboBox
    $ComboBoxObject.Location = New-Object System.Drawing.Point($Location[0], $Location[1])
    $ComboBoxObject.Size = New-Object System.Drawing.Size(200, 30)

    return $ComboBoxObject
}

function Get-GUIInput($BodyText, $TitleText) {
    $GuiInput = [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
    $GuiInput = [Microsoft.VisualBasic.Interaction]::InputBox($BodyText, $TitleText)
    Write-Debug "User Entered $GuiInput"

    return $GuiInput
}

function Get-GUIConfirmation($BodyText, $TitleText, $Buttons="YesNo", $Icon="Warning") {
    $GuiConfirm = [System.Windows.Forms.MessageBox]::Show($BodyText, $TitleText, $Buttons, $Icon)
    return $GuiConfirm
}