Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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