
function Reset-XADUserPassword {
    param ([Parameter(Mandatory = $true)][string]$Domain)
    if (-not (Test-XADDrive -Name $Domain)) {
         "Connection with the domain $Domain is no longer valid, exit and start over again" -ForegroundColor Red
        exit
    }
    $Username = read-host -Prompt "Username"
     "`nFetching account details for $Username in $Domain Domain..............`n" -ForegroundColor Yellow

    try {
        $Useraccount = Get-ADUser $Username -Properties mobile, PasswordLastSet, PasswordNeverExpires, PasswordExpired, msDS-UserPasswordExpiryTimeComputed -ErrorAction Stop
         "Account details for $Username in $Domain Domain:" -ForegroundColor Green
        $Useraccount | Select-Object mobile, PasswordLastSet, PasswordNeverExpires, PasswordExpired, @{Name = "PasswordExpiryDate"; Expression = { [datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed") } }
    }
    catch {
        $ErrorDetails = $_.Exception.Message
         "Failed to fetch details for $Username in $Domain Domain. ErrorDetails: $ErrorDetails" -ForegroundColor Red
        return
    }
    $Password = read-host -Prompt "Password" -AsSecureString
    $Confirm = Read-Host -Prompt "Are you sure you want to reset the password for $Username in $Domain Domain?`n Type 'y' or 'Y' to continue"
    if ($Confirm -notin 'y', 'Y') {
        continue
    }
     "`nSetting password for $Username in $Domain Domain..............`n" -ForegroundColor Yellow
    try {
        $Useraccount | Set-ADAccountPassword -NewPassword $Password -Reset -ErrorAction Stop
         "Password reset succeeded for $Username in $Domain Domain." -ForegroundColor Green
    }
    catch {
        $ErrorDetails = $_.Exception.Message
         "Password reset failed for $Username in $Domain Domain. ErrorDetails: $ErrorDetails" -ForegroundColor Red
    }
}
