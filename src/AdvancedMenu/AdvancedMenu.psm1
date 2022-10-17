Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function AdvancedMenuLoadPage() {
    $script:SystemInformation = New-Object System.Windows.Forms.Button
    $script:SystemInformation.FlatAppearance.BorderSize = 0
    $script:SystemInformation.FlatStyle = "Flat"
    $script:SystemInformation.Location = New-Object System.Drawing.Point(50, 130)
    $script:SystemInformation.AutoSize = $true
    $script:SystemInformation.Text = "## Advanced MENU ##"
    $script:SystemInformation.Add_Click({
        ##todo
        Write-Host "Advanced_Click"
    })
    $WindowForm.Controls.Add($script:SystemInformation)

}

function AdvancedMenuUnloadPage() {
    $WindowForm.Controls.Remove($script:SystemInformation)
}