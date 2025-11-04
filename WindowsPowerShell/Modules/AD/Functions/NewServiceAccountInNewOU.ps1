function NewServiceAccountInNewOU {
    param ([Parameter(Mandatory = $true)][string]$Domain)
    # ensure authentication with the domain is still valid
    if (-not (Test-ADDrive -Domain $Domain)) {
        Write-Host "Connection with the domain $Domain is no longer valid, exit and start over again" -ForegroundColor Red
        exit
    }
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
        $ErrorDetails = $_.Exception.Message
        Write-Host "OU creation failed for $OUName in $Domain. ErrorDetails: $ErrorDetails" -ForegroundColor Red
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
        $ErrorDetails = $_.Exception.Message
        Write-Host "Service Account creation failed for $Username in $Domain. ErrorDetails: $ErrorDetails" -ForegroundColor Red
    }
}