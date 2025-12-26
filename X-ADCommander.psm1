# Load all function scripts from all folders containing functions when the module is imported


$FunctionsFolders = @('\Functions\', '\Internal\', '\Extensions\')

foreach ($Folder in $FunctionsFolders) {
    $JoinedPath = Join-Path $PSScriptRoot $Folder
    $JoinedPath
    $FunctionsList = Get-ChildItem -Path $JoinedPath -Name
    foreach ($Function in $FunctionsList) {
        . ($JoinedPath + $Function)
    }
}
if ($Host.Name -match "ConsoleHost|Visual Studio Code Host") {
    Show-WelcomeBanner
}