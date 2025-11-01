
# Reset-Password.ps1, function taking Domain as parameter
function Reset-Password {
    # get current domain name from current AD PSDrive set by Set-Location
    $Domain = (Get-ADDomain).Name
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
        $ErrorDetails = $_.Exception.Message
        Write-Error "Password reset failed for $Username in $Domain. ErrorDetails: $ErrorDetails"
    }
}