
function ResetUserPassword {
    param ([Parameter(Mandatory = $true)][string]$Domain)
    if (-not (Test-ADDrive -Name $Domain)) {
        Write-Host "Connection with the domain $Domain is no longer valid, exit and start over again" -ForegroundColor Red
        exit
    }
    $Username = read-host -Prompt "Username"
    Write-Host "`nFetching account details for $Username in $Domain Domain..............`n" -ForegroundColor Yellow

    try {
        $Useraccount = Get-ADUser $Username -Properties mobile, PasswordLastSet, PasswordNeverExpires, PasswordExpired, msDS-UserPasswordExpiryTimeComputed -ErrorAction Stop
        Write-Host "Account details for $Username in $Domain Domain:" -ForegroundColor Green
        $Useraccount | Select mobile, PasswordLastSet, PasswordNeverExpires, PasswordExpired, @{Name = "PasswordExpiryDate"; Expression = { [datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed") } }
    }
    catch {
        $ErrorDetails = $_.Exception.Message
        Write-Host "Failed to fetch details for $Username in $Domain Domain. ErrorDetails: $ErrorDetails" -ForegroundColor Red
        return
    }
    $Password = read-host -Prompt "Password" -AsSecureString
    $Confirm = Read-Host -Prompt "Are you sure you want to reset the password for $Username in $Domain Domain?`n Type 'y' or 'Y' to continue"
    if ($Confirm -notin 'y', 'Y') {
        continue
    }
    Write-Host "`nSetting password for $Username in $Domain Domain..............`n" -ForegroundColor Yellow
    try {
        $Useraccount | Set-ADAccountPassword -NewPassword $Password -Reset -ErrorAction Stop
        Write-Host "Password reset succeeded for $Username in $Domain Domain." -ForegroundColor Green
    }
    catch {
        $ErrorDetails = $_.Exception.Message
        Write-Host "Password reset failed for $Username in $Domain Domain. ErrorDetails: $ErrorDetails" -ForegroundColor Red
    }
}