
'g','h' | Show-Menu not working properly



on v 5.1, dark scheme is needed

when back from sub menu to main, text remanents from sub keep showing and intervene with main


Fixed:

when exiting to AD drive prompt the kept drive does not get removed on next run

Switching from dom1 to dom2 then to dom1 again : Unable to create an Active Directory drive for server x.x.x.x. A drive with the name 'dom1' already exists.
Fix: Test and reuse dom1 drive if possible, if not remove existing dom1 drive and create new one

in NewAdminUser fix hardcoded OU 

in NewServiceAccountInNewOU fix hardcoded OU & $OUName & $MYADDrive

Test NewAdminUser and NewServiceAccountInNewOU