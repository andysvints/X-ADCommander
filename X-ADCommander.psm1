# Declare module-wide variables here
$script:ModuleDataPath = Join-Path $env:LocalAppData "X-ADCommander"
$script:DCIPsCSVPath = Join-Path $script:ModuleDataPath "Domain_Controllers_IPs.csv"

# Load all function scripts from all folders containing functions when the module is imported

$FunctionsFolders = @('Functions', 'Internal', 'Extensions')

foreach ($Folder in $FunctionsFolders) {
    $JoinedPath = Join-Path $PSScriptRoot $Folder
    $FunctionsList = Get-ChildItem -Path $JoinedPath -Name -ErrorAction Stop
    foreach ($Function in $FunctionsList) {
        . ($JoinedPath + $Function)
    }
}


Initialize-XADConfig

if ($Host.Name -match "ConsoleHost|Visual Studio Code Host") {
    Show-WelcomeBanner
}
