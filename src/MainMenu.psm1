Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#$script:SystemInformation = New-Object System.Windows.Forms.Button

function loadPage() {
    $script:SystemInformation = New-Object System.Windows.Forms.Button
    $script:SystemInformation.FlatAppearance.BorderSize = 0
    $script:SystemInformation.FlatStyle = "Flat"
    $script:SystemInformation.Location = New-Object System.Drawing.Point(50, 130)
    $script:SystemInformation.AutoSize = $true
    $script:SystemInformation.Text = "System Information"
    $script:SystemInformation.Add_Click({
        ##todo
        Write-Host "SystemInformation_Click"
    })
    $WindowForm.Controls.Add($script:SystemInformation)
}

function unloadPage() {
    Write-Verbose "MainMenu.psm1: unloadPage called. Removing items..."
    $WindowForm.Controls.Remove($script:SystemInformation)
}