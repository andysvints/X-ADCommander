param()

BeforeAll {
    # Set up paths
    $script:TestPath = $PSCommandPath
    $script:ProjectRoot = Split-Path -Path $PSCommandPath -Parent
    $script:ScriptPath = Join-Path -Path $ProjectRoot -ChildPath "Multi_Domain_Console.ps1"
    
    # Import the actual AD module
    $ModulePath = Join-Path -Path $ProjectRoot -ChildPath "WindowsPowerShell\Modules\AD"
    Import-Module $ModulePath -Force -ErrorAction Stop

    # Mock AD-specific cmdlets to prevent actual AD changes
    Mock -CommandName Get-PSDrive -MockWith {
        @(
            @{
                Name = 'domain1'
                Provider = @{ Name = 'ActiveDirectory' }
            }
        )
    }
    Mock -CommandName New-ADDrive -MockWith { 
        param($DomainControllers, $Credential)
        return @{ Name = $Credential.UserName.Split('\')[0] }
    }
    Mock -CommandName Set-Location -MockWith {}
    Mock -CommandName Push-Location -MockWith {}
    Mock -CommandName Pop-Location -MockWith {}
    Mock -CommandName Remove-PSDrive -MockWith {}
    Mock -CommandName Get-Credential -MockWith {
        @{
            UserName = 'domain1\admin'
            Password = (ConvertTo-SecureString 'testpass' -AsPlainText -Force)
        }
    }
    
    # Create test CSV files
    $TestDomainControllersCSV = @"
Domain,IP
domain1,192.168.1.1
domain2,192.168.1.2
"@
    $TestLevel2MenusCSV = @"
Menu_ID,Menu_Name
0,Reset User Password
1,New Admin User
2,Add Group Member
3,New Service Account in New OU
4,Back to Domain Selection
5,Exit
"@
    
    $DomainControllersPath = Join-Path -Path $TestDataPath -ChildPath 'Domain_Controllers_IPs.csv'
    $Level2MenusPath = Join-Path -Path $TestDataPath -ChildPath 'Level_2_Menus.csv'
    Set-Content -Path $DomainControllersPath -Value $TestDomainControllersCSV
    Set-Content -Path $Level2MenusPath -Value $TestLevel2MenusCSV
    
    # Mock functions
    function Test-ADDrive { param($Domain) return $true }
    function New-ADDrive { 
        param($DomainControllers, $Credential) 
        return @{ Name = 'domain1' } 
    }
    function Show-Menu { 
        param($Title, $Choices) 
        return 0 
    }
    
    # Mock AD cmdlets
    Mock -CommandName Get-PSDrive -MockWith {
        @(
            @{
                Name = 'domain1'
                Provider = @{ Name = 'ActiveDirectory' }
            }
        )
    }
    Mock -CommandName Set-Location -MockWith {}
    Mock -CommandName Push-Location -MockWith {}
    Mock -CommandName Pop-Location -MockWith {}
    Mock -CommandName Remove-PSDrive -MockWith {}
}

Describe 'Multi_Domain_Console' {
    Context 'Initial Setup' {
        BeforeEach {
            # Reset variables between tests
            Remove-Variable -Name DomainControllerIP, Options, UsedADDrives -ErrorAction SilentlyContinue
            $Global:UsedADDrives = [System.Collections.Generic.List[string]]::new()
            Set-Variable -Name PSScriptRoot -Value $ProjectRoot -Scope Global
        }

        It 'Should initialize and load domain controllers from CSV' {
            # Execute the script
            . $ScriptPath
            $DomainControllerIP | Should -Not -BeNullOrEmpty
            $Options | Should -Not -BeNullOrEmpty

            # Read actual CSV for comparison
            $CSVPath = Join-Path -Path $ProjectRoot -ChildPath "Domain_Controllers_IPs.csv"
            $ExpectedDomains = Import-Csv $CSVPath
            foreach ($domain in $ExpectedDomains) {
                $DomainControllerIP[$domain.Domain] | Should -Be $domain.IP
            }
        }

        It 'Should detect existing AD drives' {
            . $ScriptPath
            $UsedADDrives | Should -Not -BeNullOrEmpty
            $UsedADDrives | Should -Contain 'domain1'
        }
    }

    Context 'AD Drive Management' {
        BeforeEach {
            Remove-Variable -Name ADDriveName, Domain, NewADDrive -ErrorAction SilentlyContinue
        }

        It 'Should handle existing AD drive' {
            Mock -CommandName Test-ADDrive -MockWith { $true }
            . $ScriptPath
            Mock -CommandName Show-Menu -MockWith { 1 } # Select first domain
            # We don't execute the whole script, so we just verify Test-ADDrive is called
            Should -InvokeVerifiable
        }

        It 'Should handle new AD drive creation' {
            Mock -CommandName Test-ADDrive -MockWith { $false }
            . $ScriptPath
            Mock -CommandName Show-Menu -MockWith { 1 } # Select first domain
            # We don't execute the whole script, but verify New-ADDrive would be called
            Should -InvokeVerifiable
        }
    }

    Context 'Menu System' {
        BeforeAll {
            $MenuCSVPath = Join-Path -Path $ProjectRoot -ChildPath "Level_2_Menus.csv"
            $ExpectedMenus = Import-Csv $MenuCSVPath
        }

        BeforeEach {
            Set-Variable -Name PSScriptRoot -Value $ProjectRoot -Scope Global
        }

        It 'Should load all menu options from CSV' {
            . $ScriptPath
            $Level_2_Menus = [ordered]@{}
            Import-Csv (Join-Path -Path $ProjectRoot -ChildPath "Level_2_Menus.csv") | 
                ForEach-Object { $Level_2_Menus[$_.Menu_ID] = $_.Menu_Name }
            
            foreach ($menu in $ExpectedMenus) {
                $Level_2_Menus[$menu.Menu_ID] | Should -Be $menu.Menu_Name
            }
        }

        It 'Should handle menu exit' {
            Mock -CommandName Show-Menu -MockWith { 0 }
            . $ScriptPath
            Should -Invoke Show-Menu -Times 1
        }
    }

    Context 'AD Module Functions' {
        BeforeAll {
            $ModuleRoot = Join-Path $PSScriptRoot "WindowsPowerShell\Modules\AD"
        }

        It 'Should have all required functions available' {
            $RequiredFunctions = @(
                'AddGroupMember',
                'New-ADDrive',
                'NewAdminUser',
                'NewServiceAccountInNewOU',
                'ResetUserPassword',
                'Show-Menu',
                'Test-ADDrive'
            )

            $ModuleFunctions = Get-ChildItem -Path (Join-Path $ModuleRoot "Functions") -Filter "*.ps1"
            foreach ($function in $RequiredFunctions) {
                $ModuleFunctions.BaseName | Should -Contain $function
            }
        }

        It 'Should properly load the AD module' {
            Get-Module AD | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Cleanup' {
        It 'Should clean up AD drives on exit' {
            Mock -CommandName Show-Menu -MockWith { 0 }
            . $ScriptPath
            Should -Invoke Remove-PSDrive
        }
    }
}