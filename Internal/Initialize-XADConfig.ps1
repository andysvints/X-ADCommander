
# Function to ensure the environment is ready
function Initialize-XADConfig {
    if (-not (Test-Path $script:ModuleDataPath)) {
        New-Item -ItemType Directory -Path $script:ModuleDataPath -Force | Out-Null
    }
    if (-not (Test-Path $script:DCIPsCSVPath)) {
        $Entries = "Domain,IP","Domain_1,172.28.167.74","Domain_2,172.28.167.50","Domain_3,172.28.167.200"
        $Entries | ForEach-Object {$_ | Out-File -FilePath $script:DCIPsCSVPath -Encoding utf8 -Append}
    }
}