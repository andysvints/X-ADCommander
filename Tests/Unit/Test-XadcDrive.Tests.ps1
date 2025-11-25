BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
    . $PSScriptRoot\New-XadcDrive.ps1
}
Describe "Test-XadcDrive" {
    Context "When the AD PSDrive exists and is accessible" {
        BeforeAll {

            $username = "contoso\administrator"
            $password = "Somepass1" | ConvertTo-SecureString -AsPlainText -Force
            $cred = New-Object System.Management.Automation.PSCredential ($username, $password)
            New-XadcDrive -DomainControllers 'dc.contoso.com' -Credential $cred -NoConnectionTest
            $result = Test-XadcDrive -Name 'contoso'
        }
        It "Returns true when drive exists and is accessible" {
            $result | Should -Be $true
        }
    }
    Context "When the AD PSDrive does not exist" {
        It {
            $result = Test-XadcDrive -Name 'NotThere'
            $result | Should -Be $false
            
        }
    }
}