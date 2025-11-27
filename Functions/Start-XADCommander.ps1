function Start-XADCommander {
[cmdletbinding()]
param()
$ADDrive =  $Domain = $NewADDrive = ''

$ParentFolder = Split-Path $PSScriptRoot
$DataFolder =Join-Path $ParentFolder 'Data'
$Domain_Controllers_IPs_CSV = Import-Csv "$DataFolder\Domain_Controllers_IPs.csv"
$Level_2_Menus_CSV = Import-Csv "$DataFolder\Level_2_Menus.csv"

$UsedADDrives = [System.Collections.Generic.List[string]]::new()
# Detect existing AD drives from a previous session to track them for clean-up (removal)
$AllDomains = $Domain_Controllers_IPs_CSV | ForEach-Object { $_.Domain}
Get-PSDrive |
    Where-Object {($_.Name -in $AllDomains) -and ($_.Provider -match 'ActiveDirectory')} |
    Select-Object -ExpandProperty Name |
    ForEach-Object {$UsedADDrives.Add($_.ToLower())}

$CurrentLocation = (Get-Location).Path
$CurrentDriveName = $CurrentLocation.Replace(':\','')
if ($UsedADDrives -and $UsedADDrives -contains $CurrentDriveName) {
    Set-location $ENV:USERPROFILE
    Push-Location
} 
else {
    Push-Location
}
$DomainControllerIP = [ordered]@{}
$Domain_Controllers_IPs_CSV | ForEach-Object { $DomainControllerIP[$_.Domain] = $_.IP }
$Options = [string[]]$DomainControllerIP.keys

:MainMenuExitLabel
while ($true) {
    #Clear-Host -Force
    $Option = Show-XADMenu -Title 'Domains' -Choices $Options
    if ($Option -eq 0) { 
        break MainMenuExitLabel 
    }
    $Domain = $Options[$Option - 1]
    # Determine if we can use an existing AD drive and that drive authentication with the domain is still valid
    if (Test-XADDrive -Name $Domain) {
        $ADDrive = "$($Domain):" 
    }
    else {
        $Server = $DomainControllerIP.$Domain
        Write-Host "Connecting to domain controller $Server in $Domain.............." -ForegroundColor Yellow
        $Credential = Get-Credential -Message "Enter credential for domain: $Domain"
        try {
            $NewADDrive = New-XADDrive -DomainControllers $Server -Credential $Credential -NoConnectionTest -ErrorAction Stop
            $ADDrive = "$($NewADDrive):" 
            $UsedADDrives.Add(($NewADDrive.Name).ToLower())
            Write-Verbose "NewADDrive: $($NewADDrive.Name)"
            Write-Verbose "UsedADDrives: $UsedADDrives"
        }
        catch {
            $ErrorDetails = $_.Exception.Message
             "AD drive creation failed for $($Credential.Username) in $Domain. ErrorDetails: $ErrorDetails"
            $Confirm = Read-Host -Prompt "`nType 'y' if you want to return to the domain selection menu again or type anything else to exit"
            if ($Confirm -notin 'y', 'Y') {
                break MainMenuExitLabel
            }
            continue
        }
    }
    Write-Verbose "Switching to $ADDrive"
    Set-Location "$($ADDrive)\"

    $Level_2_Menus = [ordered]@{}
    $Level_2_Menus_CSV | ForEach-Object { $Level_2_Menus[$_.Menu_ID] = $_.Menu_Name }
    $Actions = [string[]]$Level_2_Menus.Values
    :SubMenuExitLabel
    while ($true) {
        #Clear-host -Force
        $SelectedMenuID = Show-XADMenu -Title "Actions for Domain:$Domain" -Choices $Actions
        if ($SelectedMenuID -eq 0) { break MainMenuExitLabel }
        $SelectedMenu = $Level_2_Menus[$SelectedMenuID - 1]
        do { 
            switch ($SelectedMenuID) {
                1 { Reset-XADUserPassword $Domain}
                2 { New-XADAdmin $Domain}
                3 { Add-XADGroupMember $Domain}
                4 { New-XADServiceAccount $Domain}
                5 { break SubMenuExitLabel }
                6 { $UsedADDrives.Remove($Domain.ToLower()) | Out-Null; break MainMenuExitLabel}
                default { Write-Warning "Unknown Option: $SelectedMenuID" }
            }
        } until (
            ((read-host -Prompt "`nType 'y' if you want to use `"$SelectedMenu`" again in $Domain domain or type anything else to go back to Actions menu") -notin 'y', 'Y')
        )
    }
}
# Cleanup
if ( $SelectedMenuID -ne 6 ) {Pop-Location}
Write-Verbose "Removing AD drives used: $UsedADDrives"
# Remove all previously used AD drives
$UsedADDrives | 
    ForEach-Object {
            Remove-PSDrive $_ -ErrorAction Continue 
    }
Return
}