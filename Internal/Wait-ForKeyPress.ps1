function Wait-AnyKeyPress {
    [CmdletBinding()]
    param(
        [string]$Message = "Press any key to continue...",
        [System.ConsoleColor]$ForegroundColor = "Cyan"
    )

    Write-Host $Message -ForegroundColor $ForegroundColor

    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
