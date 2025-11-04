function AddGroupMember {
    param ([Parameter(Mandatory = $true)][string]$Domain)
    # ensure authentication with the domain is still valid
    if (-not (Test-ADDrive -Domain $Domain)) {
        Write-Host "Connection with the domain $Domain failed, ErrorDetails: $ErrorDetails.`nexit and start over again" -ForegroundColor Red
        exit
    }
    
    $Username = read-host -Prompt "Username"
    $Group = read-host -Prompt "Group"
    "`n"; Write-Warning "Adding $Username to $Group in $Domain..............`n"
    try {
        Add-ADGroupMember $Group -Members $Username -ErrorAction Stop
        Write-Host "User $Username added to $Group in $Domain successfully." -ForegroundColor Green
    }
    catch {
        $ErrorDetails = $_.Exception.Message
        Write-Host "Adding $Username to $Group in $Domain failed. ErrorDetails: $ErrorDetails" -ForegroundColor Red
    }
}