<#
.SYNOPSIS
    Verify that an Active Directory PSDrive with the specified name exists and is accessible.

.DESCRIPTION
    Checks for a PSDrive with the specified name and attempts to enumerate
    its root to confirm read access. Returns $true if the drive exists and is
    accessible; otherwise returns $false.

.PARAMETER Name
    Name of the AD PSDrive to test (for example, 'contoso').

.EXAMPLE
    Test-ADDrive -Name 'contoso'

.EXAMPLE
    'contoso' | Test-ADDrive

.OUTPUTS
    System.Boolean

.NOTES
    Version 1.1.0
#>
function Test-ADDrive {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true
        )]
        [string]$Name
    )
    
    PROCESS {
        try {
            Write-Verbose "Checking if AD drive: $Name exists"
            Get-PSDrive -Name $Name -PSProvider ActiveDirectory -ErrorAction Stop | Out-Null
            
            $ADDrivePath = "$($Name):\"
            Write-Verbose "Checking if AD drive: $Name is accessible"
            Get-ChildItem $ADDrivePath -ErrorAction Stop | Out-Null
            Write-Verbose "AD drive $Name is valid and accessible"
            $true
        }
        catch {
            $false
        }
    }
}