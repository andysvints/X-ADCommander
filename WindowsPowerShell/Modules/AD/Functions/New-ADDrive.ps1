function New-ADDrive {
    <#
    .SYNOPSIS
       Function to create a new Active Directory drive.
    .DESCRIPTION
       Function to create a new Active Directory drive and return as outcome a drive pointing to specified domain.
    .PARAMETER DCs
        array of IPs or FQDNs of domain controllers.
    .PARAMETER Credential
        User name and password as PS Credential variable.
    .PARAMETER NoConnectionTest
        If you want to test the connection with the Domain Controller(s) before creating the Active Directory drive.
    .EXAMPLE
        $DomainControllers = @('DC01.contoso.com','DC02.contoso.com')
        New-ADDrive -DCs $DomainControllers -Credential (Get-Credential) -TestConnection
    .NOTES
        Version 1.0.0
    #>
    [CmdletBinding(
        SupportsPaging = $True,
        SupportsShouldProcess = $True)]
    [OutputType('ADDriveInfo')]
    param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true
            #ValueFromPipelineByPropertyName=$true,
            #MUTUALLY EXCLUSIVE WITH ValueFromPipelineByPropertyName and with ValueFromPipeline and ValueFromPipelineByPropertyName in other ParameterSets
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
            if (Test-Connection $DomainController -TCPPort 9389 -Quiet) {
                $Server = $DomainController
                Write-Verbose "Connection Test succeeded."
                break
            }
        }
        if (-Not $Server) {
            Write-error -Message "Unable to create an Active Directory drive because no online Domain Controller was reachable." -ErrorAction Stop
            Return
        }
        Import-Module ActiveDirectory -Force -WarningAction SilentlyContinue
        try {
            $DomainRoot = (Get-ADDomain -Server $Server -Credential $Credential).DistinguishedName # TAKING FOREVER :( :( :)
            $ADDriveName = (Get-ADDomain -Server $Server -Credential $Credential).Name
            $ADDrive = New-PSDrive -Name $ADDriveName -PSProvider ActiveDirectory -Root $DomainRoot -Credential $Credential -Server $Server -Scope Global -EA Stop
        }
        catch {
            #Write-error -Message "Unable to create an Active Directory drive. This was due to: $($_.Exception.message)`n" -ErrorAction Stop
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