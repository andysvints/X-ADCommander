# Load all function scripts when the module is imported
$FunctionsPath = Join-Path $PSScriptRoot '\Functions\'
$FunctionsPath

$FunctionsList = Get-ChildItem -Path $FunctionsPath -Name
foreach ($Function in $FunctionsList) {
    . ($FunctionsPath + $Function)
}