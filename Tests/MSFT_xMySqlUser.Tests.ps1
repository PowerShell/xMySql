$here = Split-Path -Parent $MyInvocation.MyCommand.Path

if (! (Get-Module xDSCResourceDesigner))
{
    Import-Module -Name xDSCResourceDesigner
}

Describe 'Schema Validation MSFT_xMySqlUser' {
    It 'should pass Test-xDscResource' {
        $path = Join-Path -Path $((get-item $here).parent.FullName) -ChildPath 'DSCResources\MSFT_xMySqlUser'
        $result = Test-xDscResource $path
        $result | Should Be $true
    }

    It 'should pass Test-xDscSchema' {
        $path = Join-Path -Path $((get-item $here).parent.FullName) -ChildPath 'DSCResources\MSFT_xMySqlUser\MSFT_xMySqlUser.schema.mof'
        $result = Test-xDscSchema $path
        $result | Should Be $true
    }
}

if (Get-Module MSFT_xMySqlUser)
{
    Remove-Module MSFT_xMySqlUser
}

if (Get-Module xMySql)
{
    Remove-Module xMySql
}

if (Get-Module MSFT_xMySqlUtilities)
{
    Remove-Module MSFT_xMySqlUtilities
}

Import-Module (Join-Path $here -ChildPath "..\MSFT_xMySqlUtilities.psm1")
Import-Module (Join-Path $here -ChildPath "..\DSCResources\MSFT_xMySqlUser\MSFT_xMySqlUser.psm1")
Import-Module (Join-Path $here -ChildPath "..\xMySql.psd1")

$DSCResourceName = "MSFT_xMySqlUser"
InModuleScope $DSCResourceName {

    $testPassword = ConvertTo-SecureString "password" -AsPlainText -Force
    $testCred = New-Object -typename System.Management.Automation.PSCredential -argumentlist "account",$testPassword

    Describe "how Get-TargetResource works" {
        $userName = "TestUser"

        Context 'when ErrorPath exists' {

            Mock Test-Path -Verifiable { return $true }
            Mock Remove-Item -Verifiable { return }
            Mock Get-MySqlPort -Verifiable { return "3306" }
            Mock Get-MySqlExe -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand -Verifiable { return "Yes" }
            Mock Read-ErrorFile -Verifiable { return }

            $result = Get-TargetResource -UserName $userName -UserCredential $testCred -RootCredential $testCred -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
        }

        Context 'when ErrorPath does not exist' {

            Mock Test-Path -Verifiable { return $false }
            Mock Remove-Item { return }
            Mock Get-MySqlPort -Verifiable { return "3306" }
            Mock Get-MySqlExe -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand -Verifiable { return "Yes" }
            Mock Read-ErrorFile -Verifiable { return }

            $result = Get-TargetResource -UserName $userName -UserCredential $testCred -RootCredential $testCred -MySqlVersion "5.6.17"

            It 'should not call all the mocks' {
                Assert-VerifiableMocks
                Assert-MockCalled Remove-Item 0
            }
        }

        Context 'when the given user exists' {

            Mock Test-Path -Verifiable { return $true }
            Mock Remove-Item -Verifiable { return }
            Mock Get-MySqlPort -Verifiable { return "3306" }
            Mock Get-MySqlExe -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand -Verifiable { return "Yes" }
            Mock Read-ErrorFile -Verifiable { return }

            $result = Get-TargetResource -UserName $userName -UserCredential $testCred -RootCredential $testCred -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'Ensure should be Present' {
                $result['Ensure'] | should be 'Present'
            }
            It "UserName should be $userName" {
                $result['UserName'] | should be $userName
            }
        }

        Context 'when the given user does not exist' {

            Mock Test-Path -Verifiable { return $true }
            Mock Remove-Item -Verifiable { return }
            Mock Get-MySqlPort -Verifiable { return "3306" }
            Mock Get-MySqlExe -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand -Verifiable { return "No" }
            Mock Read-ErrorFile -Verifiable { return }
            
            $result = Get-TargetResource -UserName $userName -UserCredential $testCred -RootCredential $testCred -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'Ensure should be Absent' {
                $result['Ensure'] | should be 'Absent'
            }
            It "UserName should be $userName" {
                $result['UserName'] | should be $userName
            }
        }
    }

    Describe "how Test-TargetResource works when Ensure is 'Present'" {
        Context 'when the given user exists' {
            $userExists = @{
                Ensure = "Present"
                UserName = "TestUser"
            }

            Mock Get-TargetResource -Verifiable { return $userExists }
            
            $result = Test-TargetResource -UserName "TestUser" -Ensure "Present" -UserCredential $testCred -RootCredential $testCred -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'should return true' {
                $result | should be $true
            }
        }

        Context 'when the given user does not exist' {
            $userNotExist = @{
                Ensure = "Absent"
                UserName = "TestUser"
            }

            Mock Get-TargetResource -Verifiable { return $userNotExist }
            
            $result = Test-TargetResource -UserName "TestUser" -Ensure "Present" -UserCredential $testCred -RootCredential $testCred -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'should return false' {
                $result | should be $false
            }
        }
    }

    Describe "how Test-TargetResource works when Ensure is 'Absent'" {
        Context 'when the given user exists' {
            $userExists = @{
                Ensure = "Present"
                UserName = "TestUser"
            }

            Mock Get-TargetResource -Verifiable { return $userExists }
            
            $result = Test-TargetResource -UserName "TestUser" -Ensure "Absent" -UserCredential $testCred -RootCredential $testCred -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'should return false' {
                $result | should be $false
            }
        }

        Context 'when the given user does not exist' {
            $userNotExist = @{
                Ensure = "Absent"
                UserName = "TestUser"
            }

            Mock Get-TargetResource -Verifiable { return $userNotExist }
            
            $result = Test-TargetResource -UserName "TestUser" -Ensure "Absent" -UserCredential $testCred -RootCredential $testCred -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'should return true' {
                $result | should be $true
            }
        }
    }

    Describe 'how Set-TargetResource works' {
        Context "when ErrorPath exists" {

            Mock Test-Path -Verifiable { return $true }
            Mock Remove-Item -Verifiable { return }
            Mock Get-MySqlPort -Verifiable { return "3306" }
            Mock Get-MySqlExe -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand -Verifiable { return } -ParameterFilter { $arguments -match "CREATE" }
            Mock Read-ErrorFile -Verifiable { return }

            $null = Set-TargetResource -UserName "TestUser" -Ensure "Present" -UserCredential $testCred -RootCredential $testCred -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
        }

        Context "when ErrorPath does not exist" {

            Mock Test-Path -Verifiable { return $false }
            Mock Remove-Item { return }
            Mock Get-MySqlPort -Verifiable { return "3306" }
            Mock Get-MySqlExe -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand -Verifiable { return } -ParameterFilter { $arguments -match "CREATE" }
            Mock Read-ErrorFile -Verifiable { return }

            $null = Set-TargetResource -UserName "TestUser" -Ensure "Present" -UserCredential $testCred -RootCredential $testCred -MySqlVersion "5.6.17"

            It 'should not call all the mocks' {
                Assert-VerifiableMocks
                Assert-MockCalled Remove-Item 0
            }
        }

        Context "when Ensure is 'Present'" {

            Mock Test-Path -Verifiable { return $true }
            Mock Remove-Item -Verifiable { return }
            Mock Get-MySqlPort -Verifiable { return "3306" }
            Mock Get-MySqlExe -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand -Verifiable { return } -ParameterFilter { $arguments -match "CREATE" }
            Mock Read-ErrorFile -Verifiable { return }
            
            $null = Set-TargetResource -UserName "TestUser" -Ensure "Present" -UserCredential $testCred -RootCredential $testCred -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
        }

        Context "when Ensure is 'Absent'" {

            Mock Test-Path -Verifiable { return $true }
            Mock Remove-Item -Verifiable { return }
            Mock Get-MySqlPort -Verifiable { return "3306" }
            Mock Get-MySqlExe -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand -Verifiable { return } -ParameterFilter { $arguments -match "DROP" }
            Mock Read-ErrorFile -Verifiable { return }

            $null = Set-TargetResource -UserName "TestUser" -Ensure "Absent" -UserCredential $testCred -RootCredential $testCred -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
        }
    }
}