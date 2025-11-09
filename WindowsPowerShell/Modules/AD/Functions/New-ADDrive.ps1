function New-ADDrive {
    <#
    .SYNOPSIS
       Create a new Active Directory PSDrive for a domain.
    .DESCRIPTION
       Creates a new Active Directory PSDrive named after the domain (Get-ADDomain.Name)
       and pointing to the domain root (Get-ADDomain.DistinguishedName). Tries each
       supplied domain controller until a reachable one is found (TCP port 9389),
       unless the -NoConnectionTest switch is used to skip connectivity checks.
    .PARAMETER DomainControllers
        Array of IP addresses or FQDNs of domain controllers to try.
    .PARAMETER Credential
        PSCredential used to authenticate to the domain controller(s).
    .PARAMETER NoConnectionTest
        If specified, skip TCP connectivity testing and use the first value from
        DomainControllers directly.
    .EXAMPLE
        $DCs = @('dc01.contoso.com','dc02.contoso.com')
        New-ADDrive -DomainControllers $DCs -Credential (Get-Credential)
    .EXAMPLE
        # Skip connectivity tests and force using first DC
        New-ADDrive -DomainControllers 'dc01.contoso.com' -Credential (Get-Credential) -NoConnectionTest
    .OUTPUTS
        System.Management.Automation.PSDriveInfo
    .NOTES
        Version 1.0.0
    #>
    [CmdletBinding()]
    [OutputType('System.Management.Automation.PSDriveInfo')]
    param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true
        )]
        [string[]]$DomainControllers,

        [Parameter(Mandatory = $true,
            Position = 1
        )]
        [System.Management.Automation.PSCredential]$Credential,

        [Parameter(Mandatory = $false,
            Position = 2
        )]
        [switch]$NoConnectionTest = $false
    )
    PROCESS {
        foreach ($DomainController in $DomainControllers) {
            if ($NoConnectionTest) {
                $Server = $DomainController
                break
            }
            if ( Test-NetConnection $DomainController -Port 9389 -InformationLevel Quiet ) {
                $Server = $DomainController
                Write-Verbose "Connection test succeeded."
                break
            }
        }
        if (-Not $Server) {
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.Management.Automation.DriveNotFoundException]::new("Unable to create an Active Directory drive because none of the supplied domain controllers was reachable."),
                'ADDriveCreationFailed',
                [System.Management.Automation.ErrorCategory]::ResourceUnavailable,
                $DomainControllers
            )
            $PSCmdlet.ThrowTerminatingError($ErrorRecord)
            return
        }
        try {
            $DomainRoot = (Get-ADDomain -Server $Server -Credential $Credential).DistinguishedName
            $ADDriveName = (Get-ADDomain -Server $Server -Credential $Credential).Name
            $ADDrive = New-PSDrive -Name $ADDriveName -PSProvider ActiveDirectory -Root $DomainRoot -Credential $Credential -Server $Server -Scope Global -ErrorAction Stop
        }
        catch {
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.Management.Automation.DriveNotFoundException]::new("Unable to create an Active Directory drive for server $Server. $($_.Exception.message)"),
                'ADDriveCreationFailed',
                [System.Management.Automation.ErrorCategory]::OperationStopped,
                $Server
            )
            $PSCmdlet.ThrowTerminatingError($ErrorRecord)
            Return
        }
        $ADDrive
    }
}