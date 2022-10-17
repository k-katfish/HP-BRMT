[cmdletbinding()]
param(
    [Switch][Alias("h")]$Help,
    [String]$ComputerName = $env:COMPUTERNAME
)

$script:ComputerName = $ComputerName

function GetCreds {
    param([PSCredential]$Credential)
    Write-Host "GetCreds: Called with: $($Credential.Username)"

    if (-Not $Credential) {
        Write-Host "GetCreds: No credentials provided. Requesting credentials."
        $CredMessage = "Please provide valid credentials."
        $user = "$env:UserDomain\$env:USERNAME"
        $Credential = Get-Credential -Message $CredMessage -UserName $user
          if (-Not $Credential) {
            Write-Verbose "GetCreds: User probably clicked Cancel."
            return -1
        }
        Write-Host "GetCreds: Proceeding with PSCredential Object with username: $($Credential.Username)"
    }

    Write-Verbose "GetCreds: Testing PSCredential Object..."

    try {
        Start-Process Powershell -ArgumentList "return 0" -Credential $Credential -WorkingDirectory 'C:\Windows\System32' -NoNewWindow
    } catch {
        if ($_ -like "*password*") {
            Write-Verbose "GetCred: Bad password provided."
            Start-Process Powershell -ArgumentList "Add-Type -AssemblyName System.Windows.Forms;",
            "[System.Windows.Forms.MessageBox]::Show('Bad Password! Try again!','Uh-oh.')" -WindowStyle Hidden
            $Credential = GetCreds
        } elseif ($_ -like "*is not null or empty*") {
            Write-Verbose "GetCred: No password provided."
            $OKC = Start-Process Powershell -ArgumentList "Add-Type -AssemblyName System.Windows.Forms;",
            "[System.Windows.Forms.MessageBox]::Show('Please enter a password. Click Cancel to cancel the operation.','Whoopsie.',OKCancel)" -WindowStyle Hidden
            if ($OKC -eq "Cancel") { return -1 }
            $Credential = GetCreds
        }
    }

    Write-Verbose "GetCreds: Returning Credential Object: $($Credential.Username)"
    return $Credential
}

Import-Module $PSScriptRoot\SessionHelper.psm1

function initializeComputerConnection{
    Write-Verbose "Initializing Connection to $script:ComputerName"

    if (-Not ((Get-StoredCimSession).ComputerName -eq $script:ComputerName)) {
        if (Get-StoredCimSession) { Remove-CimSession (Get-StoredCimSession) }
        try {
            $script:Credential = GetCreds -Credential $script:Credential
            if ($script:Credential -eq -1) {
                throw "Bad credentials"
            }
            Set-StoredCIMSession (New-CimSession $script:ComputerName -Credential $script:Credential -Authentication Kerberos)
        } catch {
            Write-Error "Unable to create a PSSession with $script:ComputerName. Is this a real computer, and is it online?"
            Write-Error $_
        }
    }

    try {
        Write-Verbose "Testing if HP Bios has a password on $($script:PSSessionInformation.ComputerName)"
        if (Get-HPBIOSSetupPasswordIsSet -CimSession $script:PSSessionInformation) {
            Write-Verbose "HP BIOS Password is set. Asking user for the password..."
            $script:SetupPw= [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
            $script:SetupPw= [Microsoft.VisualBasic.Interaction]::InputBox("Enter HP BIOS Setup Password for $($script:PSSessionInformation.ComputerName)", "HP BIOS Setup password required") 
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

$MainMenuButton = initializeNewBigButton "Main" (50, 50) (100, 50)
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

    Write-Verbose "User wants to connect to $script:ComputerName"

    initializeComputerConnection

    $ComputerNameButton.Text = "$((Get-StoredCimSession).ComputerName)"
    switchPage "nostate"

    initializeResources
    switchPage "Main"
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