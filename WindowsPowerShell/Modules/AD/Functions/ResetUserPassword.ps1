
# Reset-Password.ps1
function ResetUserPassword {
    param ([Parameter(Mandatory = $true)][string]$Domain)
    # ensure authentication with the domain is still valid
    if (-not (Test-ADDrive -Domain $Domain)) {
        Write-Host "Connection with the domain $Domain is no longer valid, exit and start over again" -ForegroundColor Red
        exit
    }
    $Username = read-host -Prompt "Username"
    "`n"; Write-Warning "Setting password for $Username in $Domain ..............`n"
    try {
        Get-ADUser $Username -Properties mobile, PasswordLastSet, PasswordNeverExpires, PasswordExpired, msDS-UserPasswordExpiryTimeComputed -OutVariable Useraccount -ErrorAction Stop |
            Select mobile, PasswordLastSet, PasswordNeverExpires, PasswordExpired, @{Name = "PasswordExpiryDate"; Expression = { [datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed") } }
        $Password = read-host -Prompt "Password" -AsSecureString
        $Confirm = Read-Host -Prompt "Are you sure you want to reset the password for $Username in $Domain ?`n Type 'y' or 'Y' to continue"
        if ($Confirm -notin 'y', 'Y') {
            continue
        }
        $Useraccount | Set-ADAccountPassword -NewPassword $Password -Reset -ErrorAction Stop
        Write-Host "Password reset succeeded for $Username in $Domain." -ForegroundColor Green
    }
    catch {
        $ErrorDetails = $_.Exception.Message
        Write-Host "Password reset failed for $Username in $Domain. ErrorDetails: $ErrorDetails" -ForegroundColor Red
    }
}