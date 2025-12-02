BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
    . $PSScriptRoot\New-XADDrive.ps1
}
Describe "Test-XADDrive" {
    Context "When the AD PSDrive exists and is accessible" {
        BeforeAll {

            $username = "contoso\administrator"
            $password = Read-Host "Enter password" -AsSecureString
            $cred = New-Object System.Management.Automation.PSCredential ($username, $password)
            New-XADDrive -DomainControllers 'dc.contoso.com' -Credential $cred -NoConnectionTest
        }
        It "Returns true when drive exists and is accessible" {
            $result = Test-XADDrive -Name 'contoso'
            $result | Should -Be $true
        }
    }
    Context "When the AD PSDrive does not exist" {
        It {
            $result = Test-XADDrive -Name 'NotThere'
            $result | Should -Be $false
            
        }
    }
}