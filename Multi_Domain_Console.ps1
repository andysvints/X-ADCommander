[cmdletbinding()]
param()
function Show-Menu
{
    param (
        [string]$Title = 'Menu',
        [Parameter(Mandatory=$true)]
        [string[]]$Choices
    )
    $SelectedChoice = 0
    Clear-Host
    Write-Host "$Title" -ForegroundColor Cyan
    Write-Host "-------------------------------"
    $i = 1
    foreach ($Choice in $Choices) {
        $RandomColor = Get-Random -Minimum 1 -Maximum 15
        Write-Host "$i. $Choice" -ForegroundColor $RandomColor
        $i++
    }
    Write-Host "-------------------------------"
    try {
        [int]$SelectedChoice = Read-Host "`nEnter your choice (1-$($Choices.Count)) or type anything else to quit"
    }
    catch {
        $SelectedChoice = 0
        $SelectedChoice
        Return
    }
    if  ($SelectedChoice -lt 1 -or $SelectedChoice -gt $Choices.Count){
        $SelectedChoice = 0
    }
    $SelectedChoice
}
$ModulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\AD"
Get-ChildItem $ModulePath -Include '*.psm1' -Recurse | Import-Module -Force
Push-Location

$DomainControllerIP = @{}
Import-Csv "$PSScriptRoot\DomainControllerIPs.csv" | ForEach-Object { $DomainControllerIP[$_.Domain] = $_.IP }

$Options = [string[]]$DomainControllerIP.keys
:MainMenuExitLabel
while ($true) {
    $Option = Show-Menu -Title 'Domains' -Choices $Options
    if ($Option -eq 0) {break }
    $Domain = $Options[$Option-1]
    if (Get-PSDrive $Domain -PSProvider ActiveDirectory -ea SilentlyContinue) {
        $MYADDriveName = $Domain + ":\"
    }
    else {
        $Server = $DomainControllerIP.$Domain
        "`n";Write-Warning "Connecting to domain controller $Server in $Domain.............."
        $Credential = Get-Credential -Message "Enter credential for domain: $Domain"
        try {
            $MYADDrive = New-ADDrive -DomainControllers $Server -Credential $Credential -ErrorAction Stop
            $MYADDriveName = $MYADDrive.Name + ":\"
        }
        catch {
            $ErrorDetails = $_.Exception.ToString()
            Write-Error "AD drive creation failed for $($Credential.Username) in $Domain. ErrorDetails: $ErrorDetails"
            $Confirm = Read-Host -Prompt "Type 'y' if you want to try again or type anything else to exit"
                            if ($Confirm -notin 'y','Y'){
                                exit
                            }
            continue
        }
    }
    Write-Verbose $MYADDriveName
    Set-Location $MYADDriveName
    $Actions = @(
        'Reset Password' ,
        'New Admin User' ,
        'Add User to Group',
        'Exit to AD drive prompt',
        'Go back to Domains menu',
        'New Service Account in a New OU')
    :SubMenuExitLabel
    while ($true) {
        $ActionOption = Show-Menu -Title "Actions for Domain:$Domain" -Choices $Actions
        if ($ActionOption -eq 0) {break MainMenuExitLabel}
        switch($ActionOption){
            1{ 
                do { 
                    $Username = read-host -Prompt "Username"
                    "`n";Write-Warning "Setting password for $Username in $Domain ..............`n"
                    try {
                        Get-ADUser $Username -Properties mobile, PasswordLastSet, PasswordNeverExpires, PasswordExpired, msDS-UserPasswordExpiryTimeComputed -OutVariable Useraccount -ErrorAction Stop |
                            Select mobile, PasswordLastSet, PasswordNeverExpires, PasswordExpired, @{Name = "PasswordExpiryDate"; Expression = { [datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed") } }
                        $Password = read-host -Prompt "Password" -AsSecureString # Or generate random password
                        $Confirm = Read-Host -Prompt "Are you sure you want to reset the password for $Username in $Domain ?`n Type 'y' or 'Y' to continue"
                        if ($Confirm -notin 'y','Y'){
                            continue
                        }
                        $Useraccount | Set-ADAccountPassword -NewPassword $Password -Reset -ErrorAction Stop
                        Write-Host "Password reset succeeded for $Username in $Domain." -ForegroundColor Green
                        # Now send SMS with new creds
                    }
                    catch {
                        $ErrorDetails = $_.Exception.ToString()
                        Write-Error "Password reset failed for $Username in $Domain. ErrorDetails: $ErrorDetails"
                    }
                } until (
                    ((read-host -Prompt "Type 'y' if you want to reset more passwords in $Domain or type anything else to go back to Actions menu") -notin 'y','Y')
                )
            }
            2{
                do {
                    $Username = read-host -Prompt "Username"
                    $Password = read-host -Prompt "Password" -AsSecureString
                    $Description = read-host -Prompt "Description"
                    $Mobile = read-host -Prompt "Mobile"
                    $DomainDNRoot = $MYADDrive.RootWithoutAbsolutePathToken
                    $DomainDNSSuffix = (Get-ADDomain).DNSRoot
                    $Path = 'OU=Admin Accounts,' + $DomainDNRoot
                    try {
                        New-ADUser -Name $UserName `
                                -GivenName $UserName `
                                -Surname "" `
                                -UserPrincipalName "$UserName@$DomainDNSSuffix" `
                                -SamAccountName $UserName `
                                -Description $Description `
                                -DisplayName $UserName `
                                -Path $Path `
                                -AccountPassword $Password  `
                                -OutVariable NewAccount `
                                -PassThru `
                                -Enabled $True `
                                -Mobile  $Mobile `
                                -Verbose
                                Write-Host "Account creation succeeded for $Username in $Domain." -ForegroundColor Green
                    }
                    catch {
                        $ErrorDetails = $_.Exception.ToString()
                        Write-Error "Account creation failed for $Username in $Domain. ErrorDetails: $ErrorDetails"
                    }
                } until (
                    ((read-host -Prompt "Type 'y' if you want to create more users in $Domain or type anything else to go back to Actions menu") -notin 'y','Y')
                )
            }
            3{ 
                do {
                    $Username = read-host -Prompt "Username"
                    $Group = read-host -Prompt "Group"
                    "`n";Write-Warning "Adding $Username to $Group in $Domain..............`n"
                    try {
                        Add-ADGroupMember $Group -Members $Username -ErrorAction Stop
                        Write-Host "User $Username added to $Group in $Domain successfully." -ForegroundColor Green
                    }
                    catch {
                        $ErrorDetails = $_.Exception.ToString()
                        Write-Error "Adding $Username to $Group in $Domain failed. ErrorDetails: $ErrorDetails"
                    }
                } until (
                    ((read-host -Prompt "Type 'y' if you want to add more users to groups or type anything else to go back to Actions menu") -notin 'y','Y')
                )
            }
            4{Exit}
            5{break SubMenuExitLabel}
            6{
                do {
                    $OUName = read-host -Prompt "Name of new Service Account OU"
                    $DomainDNRoot = $MYADDrive.RootWithoutAbsolutePathToken
                    $OUPath = 'OU=Service Accounts,' + $DomainDNRoot
                    $Username = read-host -Prompt "Service Account Username"
                    $Password = read-host -Prompt "Service Account Password" -AsSecureString
                    $Description = read-host -Prompt "Service Account Description"
                    $DomainDNSSuffix = (Get-ADDomain).DNSRoot
                    $Path = "OU=" + $OUName + "," + $OUPath;
                    try {
                        New-ADOrganizationalUnit -Name $OUName -Path $OUPath
                        Write-Host "OU creation succeeded for OU $OUName in $Domain." -ForegroundColor Green
                    }
                    catch {
                        $ErrorDetails = $_.Exception.ToString()
                        Write-Error "OU creation failed for $OUName in $Domain. ErrorDetails: $ErrorDetails"
                    }
                    try {
                        New-ADUser -Name $UserName `
                                -GivenName $UserName `
                                -Surname "" `
                                -UserPrincipalName "$UserName@$DomainDNSSuffix" `
                                -SamAccountName $UserName `
                                -Description $Description `
                                -DisplayName $UserName `
                                -Path $Path `
                                -AccountPassword $Password  `
                                -OutVariable NewAccount `
                                -PassThru `
                                -Enabled $True `
                                -PasswordNeverExpires $True `
                                -Verbose
                                Write-Host "Account creation succeeded for $Username in $Domain." -ForegroundColor Green
                    }
                    catch {
                        $ErrorDetails = $_.Exception.ToString()
                        Write-Error "Service Account creation failed for $Username in $Domain. ErrorDetails: $ErrorDetails"
                    }
                } until (
                    ((read-host -Prompt "Type 'y' if you want to create more service accounts in $Domain or type anything else to go back to Actions menu") -notin 'y','Y')
                )
            }
        }
    }
}
Pop-Location
Write-Verbose $MYADDrive
Remove-PSDrive $MYADDrive