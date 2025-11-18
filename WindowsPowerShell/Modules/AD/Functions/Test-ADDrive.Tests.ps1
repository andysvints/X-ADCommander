BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
    . $PSScriptRoot\New-ADDrive.ps1
}
Describe "Test-ADDrive" {
    Context "When the AD PSDrive exists and is accessible" {
        BeforeAll {

            $username = "contoso\administrator"
            $password = "Somepass1" | ConvertTo-SecureString -AsPlainText -Force
            $cred = New-Object System.Management.Automation.PSCredential ($username, $password)
            New-ADDrive -DomainControllers 'dc.contoso.com' -Credential $cred -NoConnectionTest
            $result = Test-ADDrive -Name 'contoso'
        }
        It "Returns true when drive exists and is accessible" {
            $result | Should -Be $true
        }
    }
    Context "When the AD PSDrive does not exist" {
        It {
            $result = Test-ADDrive -Name 'NotThere'
            $result | Should -Be $false
            
        }
    }
}