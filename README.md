# X-ADCommander

A PowerShell-based, extensible management framework for cross-forest Active Directory administration — featuring an interactive text-menu console interface.

## Requirements

- PowerShell 5.1 or PowerShell 7+ (PowerShell Core)
- The ActiveDirectory module (part of RSAT) must be available on the system.
- Active Directory Web Services (ADWS) must be running on domain controller(s) configured in the module (see step 4 below), ADWS port (TCP 9389 by default) must be reachable from the system running the module.
- Credentials of an account with administrative privileges or appropriate delegated permissions in the target forests/domains.

## Installation

1. Download the latest release (X-ADCommander.zip file) from:
   https://github.com/msamersawas/X-ADCommander/releases

2. Unzip the downloaded archive.

3. Copy the `X-ADCommander` folder to one of your PowerShell module folders. Examples:
   - Windows PowerShell (All users): `%Programfiles%\WindowsPowerShell\Modules\`
   - Windows PowerShell (Current user): `%UserProfile%\Documents\WindowsPowerShell\Modules\`
   - PowerShell Core (Current user): `%UserProfile%\Documents\PowerShell\Modules\`

   After copying, the module path should look like:
   `...\Modules\X-ADCommander\X-ADCommander.psm1`

4. Modify the file `...\Modules\X-ADCommander\Data\Domain_Controllers_IPs.csv` to reflect the domain names and IPs of domain controllers for each target domain.

5. If the files were downloaded as a ZIP from the internet, you may need to unblock them:
   - In PowerShell: `Get-ChildItem -Path .\X-ADCommander\* -Recurse | Unblock-File`

6. Ensure your execution policy allows running the module. For example, to set `Bypass` for the current user:
   - `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force`

7. Import the module:
   - `Import-Module X-ADCommander`

8. Start the interactive console:
   - `Start-XADCommander`

## Usage

- Run `Start-XADCommander` to launch the menu-driven console.
- Use the menus to select domains, and the management tasks you need.
- The module exports functions New-XADDrive and Test-XADDrive that you can directly use in your own scripts.

## Adding Extensions

- Use the following function template to add new custom function:

```powershell
function Verb-XADNoun {
    param ([Parameter(Mandatory = $true)][string]$Domain)
    if (-not (Test-XADDrive -Name $Domain)) {
        Write-Host "Connection with the domain $Domain is no longer valid, exit and start over again" -ForegroundColor Red
        exit
    }
    ## Get user input here if needed
      Write-Host "`n(Describe action being done) in $Domain Domain..............`n" -ForegroundColor Yellow

    try {
      ## perform main action(s) here (with -ErrorAction Stop)
      Write-Host "(action) succeeded in $Domain Domain." -ForegroundColor Green
    }
    catch {
        $ErrorDetails = $_.Exception.Message
        Write-Host "Failed to (action). ErrorDetails: $ErrorDetails" -ForegroundColor Red
    }
}
```

- Update the file `Level_2_Menus.csv` with a menu name for the new custom function.

## Issues and Contributions

- Found a bug or want a feature? Please open an issue on the repository.
- Contributions are welcome — fork the repo, make changes, and submit a pull request.
