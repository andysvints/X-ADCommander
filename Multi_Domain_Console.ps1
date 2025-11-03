[cmdletbinding()]
param()
$ModulePath = "$PSScriptRoot\WindowsPowerShell\Modules\AD"
Get-ChildItem $ModulePath -Include '*.psm1' -Recurse | Import-Module -Force -erroraction Stop
Push-Location

$DomainControllerIP = [ordered]@{}
Import-Csv "$PSScriptRoot\Domain_Controllers_IPs.csv" | ForEach-Object { $DomainControllerIP[$_.Domain] = $_.IP }
$Options = [string[]]$DomainControllerIP.keys

:MainMenuExitLabel
while ($true) {
    #Clear-Host -Force
    $Option = Show-Menu -Title 'Domains' -Choices $Options
    if ($Option -eq 0) { break }
    $Domain = $Options[$Option - 1]
    # Determine if we can use an existing AD drive and that drive authentication with the domain is still valid
    if ((Get-PSDrive $Domain -PSProvider ActiveDirectory -ea SilentlyContinue) -and ((Get-ADDomain).Name -eq $Domain)) {
        $MYADDriveName = $Domain + ":\"
    }
    else {
        $Server = $DomainControllerIP.$Domain
        "`n"; Write-Warning "Connecting to domain controller $Server in $Domain.............."
        $Credential = Get-Credential -Message "Enter credential for domain: $Domain"
        try {
            $MYADDrive = New-ADDrive -DomainControllers $Server -Credential $Credential -ErrorAction Stop
            $MYADDriveName = $MYADDrive.Name + ":\"
        }
        catch {
            $ErrorDetails = $_.Exception.Message
            Write-Error "AD drive creation failed for $($Credential.Username) in $Domain. ErrorDetails: $ErrorDetails"
            $Confirm = Read-Host -Prompt "Type 'y' if you want to try again or type anything else to exit"
            if ($Confirm -notin 'y', 'Y') {
                exit
            }
            continue
        }
    }
    Write-Verbose $MYADDriveName
    Set-Location $MYADDriveName

    $Level_2_Menus = [ordered]@{}
    Import-Csv "$PSScriptRoot\Level_2_Menus.csv" | 
        ForEach-Object { $Level_2_Menus[$_.Menu_ID] = $_.Menu_Name }
    $Actions = [string[]]$Level_2_Menus.Values
    :SubMenuExitLabel
    while ($true) {
        #clear-host -Force
        $SelectedMenuID = Show-Menu -Title "Actions for Domain:$Domain" -Choices $Actions
        if ($SelectedMenuID -eq 0) { break MainMenuExitLabel }
        $SelectedMenu = $Level_2_Menus[$SelectedMenuID - 1]
        do { 
            switch ($SelectedMenuID) {
                1 { ResetUserPassword $Domain}
                2 { New-Admin-User $Domain}
                3 { AddGroupMember $Domain}
                4 { New-Service-Account-in-a-New-OU $Domain}
                5 { break SubMenuExitLabel }
                6 { Exit }
                default { Write-Warning "Unknown Option: $SelectedMenuID" }
            }
        } until (
            ((read-host -Prompt "Type 'y' if you want to use `"$SelectedMenu`" again in $Domain domain or type anything else to go back to Actions menu") -notin 'y', 'Y')
        )
    }
}
Pop-Location
Write-Verbose $MYADDrive
Remove-PSDrive $MYADDrive
Return