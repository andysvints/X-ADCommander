function Add-XADGroupMember {
    param ([Parameter(Mandatory = $true)][string]$Domain)
    if (-not (Test-XADDrive -Name $Domain)) {
        Write-Host "Connection with the domain $Domain is no longer valid, exit and start over again" -ForegroundColor Red
        exit
    }
    $Username = read-host -Prompt "Username"
    $Group = read-host -Prompt "Group"
    Write-Host "`nAdding $Username to $Group in $Domain..............`n" -ForegroundColor Yellow
    try {
        Add-ADGroupMember $Group -Members $Username -ErrorAction Stop
        Write-Host "User $Username has been added to $Group in $Domain Domain successfully." -ForegroundColor Green
    }
    catch {
        $ErrorDetails = $_.Exception.Message
        Write-Host "Adding $Username to $Group in $Domain Domain failed. ErrorDetails: $ErrorDetails" -ForegroundColor Red
    }
}
