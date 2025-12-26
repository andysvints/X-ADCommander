function Show-WelcomeBanner {
    $banner = @"
******************************************
* Welcome to X-ADCommander       *
* Cross-forest AD administration...      *

* Important: After installing the module, modify the file ...\Modules\X-ADCommander\Data\Domain_Controllers_IPs.csv *
* The ActiveDirectory module (part of RSAT) must be available on the system. *
* Active Directory Web Services (ADWS) must be running on domain controller(s) configured in the module *
* ADWS port (TCP 9389 by default) must be reachable from the system running the module. *
* to reflect the domain names and IPs of domain controllers for each target domain. *
******************************************
"@
    Write-Host $banner -ForegroundColor Green
}


