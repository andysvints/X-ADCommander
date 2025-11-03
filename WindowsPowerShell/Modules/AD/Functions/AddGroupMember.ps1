function AddGroupMember {
    $Username = read-host -Prompt "Username"
    $Group = read-host -Prompt "Group"
    "`n";Write-Warning "Adding $Username to $Group in $Domain..............`n"
    try {
        Add-ADGroupMember $Group -Members $Username -ErrorAction Stop
        Write-Host "User $Username added to $Group in $Domain successfully." -ForegroundColor Green
    }
    catch {
        $ErrorDetails = $_.Exception.Message
        Write-Error "Adding $Username to $Group in $Domain failed. ErrorDetails: $ErrorDetails"
    }
}