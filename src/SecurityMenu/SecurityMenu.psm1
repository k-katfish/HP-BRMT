Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function SecurityMenuLoadPage() {
    $script:SecurityMenuInfoPlaceholder = New-Object System.Windows.Forms.Button
    $script:SecurityMenuInfoPlaceholder.FlatAppearance.BorderSize = 0
    $script:SecurityMenuInfoPlaceholder.FlatStyle = "Flat"
    $script:SecurityMenuInfoPlaceholder.Location = New-Object System.Drawing.Point(50, 130)
    $script:SecurityMenuInfoPlaceholder.AutoSize = $true
    $script:SecurityMenuInfoPlaceholder.Text = "## Security Menu ##"
    $script:SecurityMenuInfoPlaceholder.Add_Click({
        ##todo
        Write-Host "Security_Click"
    })
    $WindowForm.Controls.Add($script:SecurityMenuInfoPlaceholder)


}

function SecurityMenuUnloadPage() {
    $WindowForm.Controls.Remove($script:SecurityMenuInfoPlaceholder)
}