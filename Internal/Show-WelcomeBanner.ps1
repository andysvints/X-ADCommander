function Show-WelcomeBanner {
    $banner = @"
*********************************************************************************
* Welcome to X-ADCommander                                                      *
* Cross-forest AD administration...                                             *
*********************************************************************************
*                                                                               *   
* IMPORTANT:                                                                    *
* Before using the module, edit Domain_Controllers_IPs.csv under your local     *
* AppData folder: C:\Users\username\AppData\Local\X-ADCommander to reflect      *
* domain names and IPs of domain controllers for each target domain.            *
*                                                                               *
* The ActiveDirectory module (part of RSAT) must be installed on the system.    *
*                                                                               *
* Active Directory Web Services (ADWS) must be running on domain controller(s)  *
* configured in Domain_Controllers_IPs.csv                                      *
*                                                                               *
* ADWS port (TCP 9389 by default) must be reachable from the system running the *
* module.                                                                       *
*********************************************************************************
"@
    Write-Host $banner -ForegroundColor Green
}


