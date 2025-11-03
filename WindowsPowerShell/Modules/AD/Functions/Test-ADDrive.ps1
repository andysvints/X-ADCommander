function Test-ADDrive {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Domain
    )
    try {
        Get-PSDrive -Name $Domain -PSProvider ActiveDirectory -ErrorAction Stop | Out-Null
        Get-ADDomain $Domain -ErrorAction Stop | Out-Null
        $true
    }
    catch {
        $false
    }
}