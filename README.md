# X-ADCommander

A PowerShell-based, extensible management framework for cross-forest Active Directory administration — featuring an interactive text-menu console interface.

## Requirements

- PowerShell 5.1 or PowerShell 7+ (PowerShell Core)
- If you plan to manage Active Directory from the host, the ActiveDirectory module (part of RSAT) must be available on that system.
- Appropriate network connectivity and credentials for the forests/domains you will manage.

## Installation

1. Download the latest release from:
   https://github.com/msamersawas/X-ADCommander/releases

2. Unzip the downloaded archive.

3. Copy the `X-ADCommander` folder to one of your PowerShell module folders. Examples:
   - Windows PowerShell (All users): `C:\Program Files\WindowsPowerShell\Modules\`
   - Windows PowerShell (Current user): `%UserProfile%\Documents\WindowsPowerShell\Modules\`
   - PowerShell Core (Current user): `%UserProfile%\Documents\PowerShell\Modules\`

   After copying, the module path should look like:
   `C:\...\Modules\X-ADCommander\X-ADCommander.psm1` (or similar).

4. If the files were downloaded as a ZIP from the internet, you may need to unblock them:
   - In PowerShell: `Get-ChildItem -Path .\X-ADCommander\* -Recurse | Unblock-File`

5. Import the module:
   - `Import-Module X-ADCommander`

6. Start the interactive console:
   - `Start-XADCommander`

## Usage

- Run `Start-XADCommander` to launch the menu-driven console.
- Use the menus to select forests, domains, and the management tasks you need.
- For scripting or automation, import the module and call individual functions exported by the module.

## Notes

- You may need administrative privileges or appropriate delegated permissions in the target Active Directory environments.
- Ensure your execution policy allows running local modules. For example, to set RemoteSigned for the current user:
  - `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force`


## Adding Extensions 
Use the following template to add new custom functions:

function ActionName-XADUser {
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

## Issues and Contributions

- Found a bug or want a feature? Please open an issue on the repository.
- Contributions are welcome — fork the repo, make changes, and submit a pull request.
