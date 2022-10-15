Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function loadPage() {
    $SystemInformation = New-Object System.Windows.Forms.Button
    $SystemInformation.FlatAppearance.BorderSize = 0
    $SystemInformation.FlatStyle = "Flat"
    $SystemInformation.Location = New-Object System.Drawing.Point(50, 130)
    $SystemInformation.AutoSize = $true
    $SystemInformation.Text = "System Information"
    $SystemInformation.Add_Click({
        ##todo
        Write-Host "SystemInformation_Click"
    })
    $WindowForm.Controls.Add($SystemInformation)
}

function unloadPage() {
    $WindowForm.Controls.Remove($SystemInformation)
}