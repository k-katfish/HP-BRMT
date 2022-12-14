Import-Module $PSScriptRoot\..\SessionHelper.psm1

function LoadSystemInformationPage() {
    Write-Verbose "SystemInformation.psm1: LoadSystemInformationPage called."
    Write-Verbose "LoadSystemInformationPage: Setting MainMenuPageState"

    $script:TitleLabel = New-StaticText "SYSTEM INFORMATION for $((Get-StoredCimSession).ComputerName)" (50, 150)

    $script:ProductNameLabel = New-StaticText "Product Name" (50, 200)
    $script:ProductNameText = New-StaticText "$(Get-HPDeviceModel -CimSession (Get-StoredCimSession))" (200, 200)

    $script:MemorySizeLabel = New-StaticText "Memory Size" (50, 220)
    $script:MemorySizeText = New-StaticText "$([Math]::Round((Get-CimInstance -CimSession (Get-StoredCimSession) -ClassName Win32_ComputerSystem).TotalPhysicalMemory / (1024 * 1024 * 1024))) GB" (200, 220)

    $script:ServiceBar = New-StaticText "SERVICE ------------------------------------------------------------------------" (50, 300)
    
    $script:BornOnDateLabel = New-StaticText "Born on Date" (50, 340)
    $Script:BornOnDateText = New-StaticText "$(Get-HPBiosSettingValue -CimSession (Get-StoredCimSession) -Name "Born On Date")" (200, 340)

    $script:SerialNumberLabel = New-StaticText "Serial Number" (50, 360)
    $script:SerialNumberText = New-StaticText "$(Get-HPDeviceSerialNumber -CimSession (Get-StoredCimSession))" (200, 360)

    $script:SKUNumberLabel = New-StaticText "SKU Number" (50, 380)
    $script:SKUNumberText = New-StaticText "$(Get-HPDevicePartNumber -CimSession (Get-StoredCimSession))" (200, 380)

    $script:UUIDLabel = New-StaticText "UUID" (50, 400)
    $script:UUIDText = New-StaticText "$(Get-HPBIOSUUID -CimSession (Get-StoredCimSession))" (200,400)

    $script:AssetTrackingNumberLabel = New-StaticText "Asset Tracking Number" (50, 440)
    $script:AssetTrackingNumberText = New-StaticText "$(Get-HPBIOSSettingValue -Name "Asset Tracking Number" -CimSession (Get-StoredCimSession))" (200, 400)

    $script:BackButton = New-BackButton
    $script:BackButton.Add_Click({
        UnloadSystemInformationPage
        Import-Module $PSScriptRoot\MainMenu.psm1 -Function MainMenuReloadPageItems
        MainMenuReloadPageItems
    })

    $WindowForm.Controls.AddRange(@($script:BackButton, $script:TitleLabel, 
        $script:ProductNameLabel, $script:ProductNameText
        $script:MemorySizeLabel, $script:MemorySizeText
        $script:ServiceBar
        $script:BornOnDateLabel, $Script:BornOnDateText
        $script:SerialNumberLabel, $script:SerialNumberText
        $script:SKUNumberLabel, $script:SKUNumberText
        $script:AssetTrackingNumberLabel, $script:AssetTrackingNumberText
        $script:UUIDLabel, $script:UUIDText))
}

function UnloadSystemInformationPage() {
    $WindowForm.Controls.Remove($script:BackButton)
    $WindowForm.Controls.Remove($script:TitleLabel)
    $WindowForm.Controls.Remove($script:ProductNameLabel)
    $WindowForm.Controls.Remove($script:ProductNameText)
    $WindowForm.Controls.Remove($script:MemorySizeLabel)
    $WindowForm.Controls.Remove($script:MemorySizeText)
    $WindowForm.Controls.Remove($script:ServiceBar)
    $WindowForm.Controls.Remove($script:BornOnDateLabel)
    $WindowForm.Controls.Remove($Script:BornOnDateText)
    $WindowForm.Controls.Remove($script:SerialNumberLabel)
    $WindowForm.Controls.Remove($script:SerialNumberText)
    $WindowForm.Controls.Remove($script:SKUNumberLabel)
    $WindowForm.Controls.Remove($script:SKUNumberText)
    $WindowForm.Controls.Remove($script:UUIDLabel)
    $WindowForm.Controls.Remove($script:UUIDText)
    $WindowForm.Controls.Remove($script:AssetTrackingNumberLabel)
    $WindowForm.Controls.Remove($script:AssetTrackingNumberText)
}