function Start-XADCommander {
[CmdletBinding(SupportsShouldProcess=$true)]
param()
begin{}
process{
	if ($pscmdlet.ShouldProcess("computer")){
$ExistingADDrive = $CurrentDriveName = ''

$ParentFolder = Split-Path $PSScriptRoot
$DataFolder =Join-Path $ParentFolder 'Data'
$Domain_Controllers_IPs_CSV = Import-Csv $Script:DCIPsCSVPath
$Level_2_Menus_CSV = Import-Csv "$DataFolder\Level_2_Menus.csv"
$AllIPs = $Domain_Controllers_IPs_CSV | ForEach-Object { $_.IP }
# Declare $UsedADDrives as a hash table
$UsedADDrives = @{}
# Detect existing AD drives created from a previous session to track them for reuse and clean-up (removal)
# check current PSDrives for drives of type Microsoft.ActiveDirectory.Management.dll\ActiveDirectory and server ip in the DC IPs CSV and add them to the UsedADDrives

# store existing AD drive names that match the domain controller and IPs in a hashtable
Get-PSDrive | 
    Where-Object { $_.Provider -match 'ActiveDirectory' -and $_.Server -in $AllIPs -and ($_.Name -eq $_.RootWithoutAbsolutePathToken.Split(',')[0].Substring(3)) } |
    Select-Object Name, Server | ForEach-Object { $UsedADDrives[$_.Name] = $_.Server } 

$CurrentDriveName = (Get-Location).Drive.Name
if (($UsedADDrives.Count -gt 0) -and $UsedADDrives.ContainsKey($CurrentDriveName)) {
    Set-location $ENV:USERPROFILE
}
Push-Location
$DomainControllerIP = [ordered]@{}
$Domain_Controllers_IPs_CSV | ForEach-Object { $DomainControllerIP[$_.Label] = $_.IP }
$Options = [string[]]$DomainControllerIP.keys

:MainMenuExit
while ($true) {
    #Clear-Host -Force
    $ADDrive = $Domain = ''
    $Option = Show-XADMenu -Title 'Domains' -Choices $Options
    if ($Option -eq 0) { 
        break MainMenuExit 
    }
    $SelectedLabel = $Options[$Option - 1]
    # Determine if we can use an existing AD drive
    $Server = $DomainControllerIP.$SelectedLabel
    write-Verbose "SelectedLabel: $SelectedLabel, Corresponding Server: $Server"
    if ($Server -in $UsedADDrives.Values) {
        foreach ($EnumUsedADDrives in $UsedADDrives.GetEnumerator()) {
            if ($EnumUsedADDrives.Value -eq $Server) {
                $ExistingADDrive = $EnumUsedADDrives.Key
                Write-Verbose "Found existing AD drive $ExistingADDrive for server $Server"
            }
        }
        # Check if existing AD drive authentication with the domain is still valid
        if (Test-XADDrive -Name $ExistingADDrive) {
            $Domain = $ExistingADDrive
            $ADDrive = "$($Domain):" 
        }
    }
    if (-not $ADDrive) {
        Write-Host "`nConnecting to domain controller $Server in $SelectedLabel.............." -ForegroundColor Yellow
        $Credential = Get-Credential -Message "Enter credential for the domain in $SelectedLabel"
        :CreateADDrive
        do {
            try {
            $Domain = New-XADDrive -DomainControllers $Server -Credential $Credential -NoConnectionTest -ErrorAction Stop | Select-Object -ExpandProperty Name
            }
            catch {
                $ErrorRecord = $_
                switch ($ErrorRecord.FullyQualifiedErrorId) {
                    # Ensure new AD drive name is not already taken
                    'DriveAlreadyExists,New-XADDrive' { 
                        "A drive with name $($ErrorRecord.TargetObject) already exists. You'll be prompted to confirm deleting the $($ErrorRecord.TargetObject) drive."
                        $Confirm = Read-Host -Prompt "`nType 'y' or 'Y' if you confirm deleting drive $($ErrorRecord.TargetObject) or type anything else to keep it and to return to the domain selection menu again"
                        if ($Confirm -notin 'y', 'Y') {
                            continue MainMenuExit
                        }
                        else {
                            if ((Get-Location -Stack).Path[0].StartsWith($ErrorRecord.TargetObject)){
                                Pop-Location
                                Set-location $ENV:USERPROFILE
                                Push-Location
                            }
                            Remove-PSDrive -Name $ErrorRecord.TargetObject -Force
                            continue CreateADDrive
                        }
                    }
                    default{
                        $ErrorDetails = $ErrorRecord.Exception.Message
                        "AD drive creation failed for $($Credential.Username) in $SelectedLabel. ErrorDetails: $ErrorDetails"
                        $Confirm = Read-Host -Prompt "`nType 'y' or 'Y' if you want to return to the domain selection menu again or type anything else to exit"
                        if ($Confirm -notin 'y', 'Y') {
                            break MainMenuExit
                        }
                        continue MainMenuExit
                    }
                }
            }
            $ADDrive = "$($Domain):" 
            Write-Verbose "UsedADDrives: $($UsedADDrives.Keys)" 
            $UsedADDrives[$Domain] = $Server
            Write-Verbose "NewADDrive: $Domain"
        } until( $ADDrive )
    }
    Write-Verbose "Switching to $Domain"
    Set-Location "$($ADDrive)\"

    $Level_2_Menus = [ordered]@{}
    $Level_2_Menus_CSV | ForEach-Object { $Level_2_Menus[$_.Menu_ID] = $_.Menu_Name }
    $Actions = [string[]]$Level_2_Menus.Values
    :SubMenuExit
    while ($true) {
        #Clear-host -Force
        $SelectedMenuID = Show-XADMenu -Title "Actions for domain: $Domain" -Choices $Actions
        if ($SelectedMenuID -eq 0) { break MainMenuExit }
        $SelectedMenu = $Level_2_Menus[$SelectedMenuID - 1]
        do {
            switch ($SelectedMenuID) {
                1 { Reset-XADUserPassword $Domain}
                2 { New-XADAdmin $Domain}
                3 { Add-XADGroupMember $Domain}
                4 { New-XADServiceAccount $Domain}
                5 { break SubMenuExit }
                6 { $UsedADDrives.Remove($Domain) | Out-Null; break MainMenuExit}
                default { Write-Warning "Unknown Option: $SelectedMenuID" }
            }
            # If the AD drive was found invalid in any called function above, start over from domains menu
            if ( -not (Test-XADDrive $Domain) ) {
                Write-Host "Connection with the domain $Domain is no longer valid, you'll be taken to domains menu to start over again" -ForegroundColor Red                
                Set-Location $Env:USERPROFILE
                Remove-PSDrive -Name $Domain -Force
                $UsedADDrives.Remove($Domain)
                break SubMenuExit
            }
        } until (
            ((read-host -Prompt "`nType 'y' or 'Y' if you want to use `"$SelectedMenu`" again in $Domain or type anything else to go back to Actions menu") -notin 'y', 'Y')
        )
    }
}
# Cleanup
if ( $SelectedMenuID -ne 6 ) {Pop-Location}
Write-Verbose "Removing AD drives used: $($UsedADDrives.keys)"
# Remove all previously used AD drives
$UsedADDrives.Keys | 
    ForEach-Object {
            Remove-PSDrive $_ -ErrorAction Continue 
    }
Return
	}
}
end{}
}
