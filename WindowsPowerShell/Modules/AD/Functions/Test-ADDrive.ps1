function Test-ADDrive {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Domain
    )
    try {
        Get-PSDrive -Name $Domain -PSProvider ActiveDirectory -ErrorAction Stop | Out-Null
        $ADDriveName = $Domain + ':\'
        Get-ChildItem $ADDriveName -ErrorAction Stop | Out-Null
        $true
    }
    catch {
        $false
    }
}