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

function initializeNewBigButton($Text, $Location, $Size) {
    $BigButton = New-Object System.Windows.Forms.Button
    $BigButton.Size = New-Object System.Drawing.Size($Size[0], $Size[1]) #New-Object System.Drawing.Size(150, 50)
    $BigButton.Font = New-Object System.Drawing.Font("Arial", 15)
    $BigButton.Location = New-Object System.Drawing.Point($Location[0], $Location[1])
    $BigButton.Text = $Text
    
    return $BigButton
}

function initializeNewLinkyButton($Text) {
    $ButtonObject = New-Object System.Windows.Forms.Button
    $ButtonObject.FlatAppearance.BorderSize = 0
    $ButtonObject.FlatStyle = "Flat"
    $ButtonObject.AutoSize = $true
    $ButtonObject.Text = $Text

    return $ButtonObject
}

function initializeNewEditableText($Text) {
    $TextBoxObject = New-Object System.Windows.Forms.TextBox
    $TextBoxObject.BorderStyle = "None" #?
    $TextBoxObject.AutoSize = $true
    $TextBoxObject.Text = $Text
    
    return $TextBoxObject
}

function initializeNewStaticText($Text, $Location) {
    $LabelObject = New-Object System.Windows.Forms.Label
    $LabelObject.Location = New-Object System.Drawing.Point($Location[0], $Location[1])
    $LabelObject.AutoSize = $true
    $LabelObject.Text = $Text

    return $LabelObject
}

function initializeNewBackButton() {
    $BackButton = New-Object System.Windows.Forms.Button
    $BackButton.AutoSize = $true #.Size = New-Object System.Drawing.Size(50, 100) #New-Object System.Drawing.Size(150, 50)
    $BackButton.Font = New-Object System.Drawing.Font("Arial", 10)
    $BackButton.Location = New-Object System.Drawing.Point(5, 110)
    $BackButton.Text = "<- Back"
    
    return $BackButton
}