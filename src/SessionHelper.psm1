$script:SessionInformation 

function Get-StoredCimSession {
    return $script:SessionInformation
}

function Set-StoredCimSession ($SessionInfo) {
    $script:SessionInformation = $SessionInfo
}