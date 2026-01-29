function Add-XADGroupMember {
    param ([Parameter(Mandatory = $true)][string]$Domain)

    $Username = Read-Host -Prompt "Username"
    $Group = Read-Host -Prompt "Group"
    Write-Host "`nAdding '$Username' to $Group in $Domain..............`n" -ForegroundColor Yellow
    try {
        Add-ADGroupMember $Group -Members $Username -ErrorAction Stop
        Write-Host "User '$Username' has been added to $Group in $Domain domain successfully." -ForegroundColor Green
    }
    catch {
        $ErrorDetails = $_.Exception.Message
        Write-Host "Adding '$Username' to $Group in $Domain domain failed. ErrorDetails: $ErrorDetails" -ForegroundColor Red
    }
}






