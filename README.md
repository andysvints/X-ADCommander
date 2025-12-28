# X-ADCommander

A PowerShell-based, extensible management framework for cross-forest Active Directory administration — featuring an interactive text-menu console interface.

## Requirements

- PowerShell 5.1 or PowerShell 7.x (PowerShell Core)
- The ActiveDirectory module (part of RSAT) must be installed on the system.
- Active Directory Web Services (ADWS) must be running on domain controller(s) configured in the module (see step 4 below) and ADWS port (TCP 9389 by default) must be reachable from the system running the module.
- Credentials of an account with administrative privileges or appropriate delegated permissions in the target forests/domains.

## Installation

1. Install the module from Powershell Gallery
   - `Install-Module -Name X-ADCommander`

2. Before using the module, modify Domain_Controllers_IPs.csv in folder "X-ADCommander" under your local AppData folder: 
   - `C:\Users\username\AppData\Local\X-ADCommander` to reflect the domain names and IPs of domain controllers for each target domain.

3. Ensure your PowerShell execution policy allows running the module. For example, to set `Bypass` for the current user:
   - `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force`

4. Import the module
   - `Import-Module X-ADCommander`
 
5. Start the interactive console:
   - `Start-XADCommander`


## Usage

- Run `Start-XADCommander` to launch the menu-driven console.
- Use the menus to select domains, and the management tasks you need.
- The module exports functions New-XADDrive and Test-XADDrive that you can directly use in your own scripts.

## Adding Extensions

- Use the following function template to add a new custom function:

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
