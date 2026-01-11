function Show-WelcomeBanner {
    $banner = @"
*********************************************************************************
* Welcome to X-ADCommander                                                      *
* Cross-forest interactive AD administration console...                         *
*********************************************************************************
*                                                                               *
* REQUIRMENTS:                                                                  *
* 1- The ActiveDirectory module (part of RSAT) must be installed on the system. *
* 2- Active Directory Web Services (ADWS) must be running on domain             *
* controller(s) configured for X-ADCommander module                             *
* 3- ADWS port (TCP 9389 by default) must be reachable from the system running  *
* the module.                                                                   *
*                                                                               *   
* IMPORTANT:                                                                    *
* Before using the module, edit "Domain_Controllers_IPs.csv" in folder          *
* "X-ADCommander" under your local AppData folder:                              *
* C:\Users\username\AppData\Local\X-ADCommander to reflect                      *
* domain names and IPs of domain controllers for each target domain.            *
*                                                                               *
* To start the interactive console, run Start-ADCommander                       *
*                                                                               *
*********************************************************************************
"@
    Write-Host $banner -ForegroundColor Green
}


