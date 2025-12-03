function New-XADServiceAccount {
    param ([Parameter(Mandatory = $true)][string]$Domain)
    if (-not (Test-XADDrive -Name $Domain)) {
        Write-Host "Connection with the domain $Domain is no longer valid, exit and start over again" -ForegroundColor Red
        exit
    }
    $DomainDNRoot = (Get-ADDomain).DistinguishedName
    $DomainDNSSuffix = (Get-ADDomain).DNSRoot

    $OUPath = Read-Host -Prompt "Enter the name of the existing main OU (default: Service Accounts)"
    if ([string]::IsNullOrWhiteSpace($OUPath)) {
        $OUPath = "Service Accounts"
    }
    $OUPath = $OUPath.Trim()
    $OUPath = "OU=" + $OUPath + "," + $DomainDNRoot
    do {
        $OUName = Read-Host -Prompt "Enter the name of the new sub OU"
    } while ([string]::IsNullOrWhiteSpace($OUName))
    $OUName = $OUName.Trim()
    Write-Host "`nCreating $OUName OU under $OUPath in $Domain Domain..............`n" -ForegroundColor Yellow
    try {
        New-ADOrganizationalUnit -Name $OUName -Path $OUPath -ErrorAction Stop
        Write-Host "OU creation succeeded for OU $OUName in $Domain Domain." -ForegroundColor Green
    }
    catch {
        $ErrorDetails = $_.Exception.Message
        Write-Host "OU creation failed for $OUName in $Domain Domain. ErrorDetails: $ErrorDetails" -ForegroundColor Red
    }
    do {
        $Username = read-host -Prompt "Service Account Username"
    } while ([string]::IsNullOrWhiteSpace($Username))
    
    $Password = read-host -Prompt "Service Account Password" -AsSecureString
    $Description = read-host -Prompt "Service Account Description"
    $Path = "OU=" + $OUName + "," + $OUPath;
    $NewUserParams = @{
        Name                 = $Username
        GivenName            = $Username
        Surname              = ""
        UserPrincipalName    = "$Username@$DomainDNSSuffix"
        SamAccountName       = $Username
        Description          = $Description
        DisplayName          = $Username
        Path                 = $Path
        AccountPassword      = $Password
        Enabled              = $true
        PasswordNeverExpires = $true
    }
    Write-Host "`nCreating service account $Username in $Domain Domain under $Path..............`n" -ForegroundColor Yellow
    try {
        New-ADUser @NewUserParams -ErrorAction Stop
        Write-Host "Account creation succeeded for $Username in $Domain Domain." -ForegroundColor Green
    }
    catch {
        $ErrorDetails = $_.Exception.Message
        Write-Host "Service Account creation failed for $Username in $Domain Domain. ErrorDetails: $ErrorDetails" -ForegroundColor Red
    }
}
