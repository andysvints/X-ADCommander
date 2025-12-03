
function New-XADAdmin {
    param ([Parameter(Mandatory = $true)][string]$Domain)
    if (-not (Test-XADDrive -Name $Domain)) {
        Write-Host "Connection with the domain $Domain is no longer valid, exit and start over again" -ForegroundColor Red
        exit
    }
    $DomainDNRoot = (Get-ADDomain).DistinguishedName
    $DomainDNSSuffix = (Get-ADDomain).DNSRoot

    $Username = read-host -Prompt "Username"
    $Password = read-host -Prompt "Password" -AsSecureString
    $Description = read-host -Prompt "Description"
    $Mobile = read-host -Prompt "Mobile"

    $Path = Read-Host -Prompt "Enter the OU name for admin users (default: Admin Accounts)"
    if ([string]::IsNullOrWhiteSpace($Path)) {
        $Path = "Admin Accounts"
    }
    $Path = $Path.Trim()
    $Path = "OU=" + $Path + "," + $DomainDNRoot

    Write-Host "`nCreating new admin user $Username in $Domain under $Path..............`n" -ForegroundColor Yellow
    $UserParams = @{
        Name              = $UserName
        GivenName         = $UserName
        Surname           = ""
        UserPrincipalName = "$UserName@$DomainDNSSuffix"
        SamAccountName    = $UserName
        Description       = $Description
        DisplayName       = $UserName
        Path              = $Path
        AccountPassword   = $Password
        Enabled           = $true
        Mobile            = $Mobile
    }
    try {
        New-ADUser @UserParams -ErrorAction Stop
        Write-Host "Account creation succeeded for $Username in $Domain Domain." -ForegroundColor Green
    }
    catch {
        $ErrorDetails = $_.Exception.Message
        Write-Host "Account creation failed for $Username in $Domain Domain. ErrorDetails: $ErrorDetails" -ForegroundColor Red
    }
}
