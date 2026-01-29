
function New-XADAdmin {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ([Parameter(Mandatory = $true)][string]$Domain)
    begin {}
    process {
        if ($pscmdlet.ShouldProcess("domain - $Domain")) {
            $DomainDNRoot = (Get-ADDomain).DistinguishedName
            $DomainDNSSuffix = (Get-ADDomain).DNSRoot

            $Username = Read-Host -Prompt "Username"
            $Password = Read-Host -Prompt "Password" -AsSecureString
            $Description = Read-Host -Prompt "Description"
            $Mobile = Read-Host -Prompt "Mobile"

            $Path = Read-Host -Prompt "Enter the OU name for admin users (default: Admin Accounts)"
            if ([string]::IsNullOrWhiteSpace($Path)) {
                $Path = "Admin Accounts"
            }
            $Path = $Path.Trim()
            $Path = "OU=" + $Path + "," + $DomainDNRoot

            Write-Host "`nCreating new admin user '$Username' in $Domain under $Path..............`n" -ForegroundColor Yellow
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
                Write-Host "Account creation succeeded for '$Username' in $Domain domain." -ForegroundColor Green
            }
            catch {
                $ErrorDetails = $_.Exception.Message
                Write-Host "Account creation failed for '$Username' in $Domain domain. ErrorDetails: $ErrorDetails" -ForegroundColor Red
            }
        }
    }
    end {}
}






