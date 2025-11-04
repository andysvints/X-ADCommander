
function NewAdminUser {
    param ([Parameter(Mandatory = $true)][string]$Domain)
    # ensure authentication with the domain is still valid
    if (-not (Test-ADDrive -Domain $Domain)) {
        Write-Host "Connection with the domain $Domain is no longer valid, exit and start over again" -ForegroundColor Red
        exit
    }
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
        $ErrorDetails = $_.Exception.Message
        Write-Host "Account creation failed for $Username in $Domain. ErrorDetails: $ErrorDetails" -ForegroundColor Red
    }
}