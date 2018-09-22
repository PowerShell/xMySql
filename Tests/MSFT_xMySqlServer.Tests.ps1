[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param
()
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

if (! (Get-Module xDSCResourceDesigner))
{
    Import-Module -Name xDSCResourceDesigner
}

Describe 'Schema Validation MSFT_xMySqlServer' {
    It 'should pass Test-xDscResource' {
        $path = Join-Path -Path $((Get-Item $here).Parent.FullName) -ChildPath 'DSCResources\MSFT_xMySqlServer'
        $result = Test-xDscResource $path
        $result | Should Be $true
    }

    It 'should pass Test-xDscSchema' {
        $path = Join-Path -Path $((Get-Item $here).parent.FullName) -ChildPath 'DSCResources\MSFT_xMySqlServer\MSFT_xMySqlServer.schema.mof'
        $result = Test-xDscSchema $path
        $result | Should Be $true
    }
}

if (Get-Module MSFT_xMySqlServer)
{
    Remove-Module MSFT_xMySqlServer
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
Import-Module (Join-Path $here -ChildPath "..\DSCResources\MSFT_xMySqlServer\MSFT_xMySqlServer.psm1")
Import-Module (Join-Path $here -ChildPath "..\xMySql.psd1")

$DSCResourceName = "MSFT_xMySqlServer"
InModuleScope $DSCResourceName {

    $testPassword = ConvertTo-SecureString "password" -AsPlainText -Force
    $testCred = New-Object -Typename System.Management.Automation.PSCredential -Argumentlist "account",$testPassword

    Describe 'how Get-TargetResource responds' {
        $version = "5.6.17"

        Context 'when the given version is installed' {
            $returnport = "3306"

            Mock Get-MySqlVersionInstalled -Verifiable { return $true }
            Mock Get-MySqlPort -Verifiable { return $returnport }

            $result = Get-TargetResource -MySqlVersion $version -RootPassword $testCred

            It 'should call all the mocks' {
                Assert-VerifiableMocks Get-MySqlInstalled
                Assert-VerifiableMocks Get-MySqlPort
            }
            It 'Ensure should be Present' {
                $result['Ensure'] | should be 'Present'
            }
            It "MySqlVersion should be $version" {
                $result['MySqlVersion'] | should be $version
            }
            It "Port should be $returnport" {
                $result['Port'] | should be $returnport
            }
        }

        Context 'when the given version is not installed' {

            Mock Get-MySqlVersionInstalled -Verifiable { return $false }
            Mock Get-MySqlPort { return }

            $result = Get-TargetResource -MySqlVersion $version -RootPassword $testCred

            It 'should not call all the mocks' {
                Assert-VerifiableMocks
                Assert-MockCalled Get-MySqlPort 0
            }
            It 'Ensure should be Absent'{
                $result['Ensure'] | should be 'Absent'
            }
            It "MySqlVersion should be $version"{
                $result['MySqlVersion'] | should be $version
            }
            It "Port should be null" {
                $result['Port'] | should be $null
            }
        }
    }

    Describe "how Test-TargetResource responds when Ensure = 'Present'" {
        Context 'when the given version is installed and port matches' {
            $MySqlInstalled = @{
                Ensure = "Present"
                MySqlVersion = "5.6.17"
                Port = "3306"
            }

            Mock Get-TargetResource -Verifiable { return $MySqlInstalled }

            $result = Test-TargetResource -Ensure "Present" -MySqlVersion "5.6.17" -RootPassword $testCred -Port "3306"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'should return true'{
                $result | should be $true
            }
        }

        Context "when the given version is installed and port doesn't match" {
            $MySqlInstalled = @{
                Ensure = "Present"
                MySqlVersion = "5.6.17"
                Port = "3306"
            }

            Mock Get-TargetResource -Verifiable { return $MySqlInstalled }

            $result = Test-TargetResource -Ensure "Present" -MySqlVersion "5.6.17" -RootPassword $testCred -Port "3307"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'should return false'{
                $result | should be $false
            }
        }

        Context 'when the given version is not installed and the port matches' {
            $MySqlNotInstalled = @{
                Ensure = "Absent"
                MySqlVersion = "5.6.17"
                Port = "3306"
            }

            Mock Get-TargetResource -Verifiable { return $MySqlNotInstalled }

            $result = Test-TargetResource -Ensure "Present" -MySqlVersion "5.6.17" -RootPassword $testCred -Port "3306"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'should return false'{
                $result | should be $false
            }
        }

        Context "when the given version is not installed and the port doesn't match" {
            $MySqlNotInstalled = @{
                Ensure = "Absent"
                MySqlVersion = "5.6.17"
                Port = "3306"
            }

            Mock Get-TargetResource -Verifiable { return $MySqlNotInstalled }

            $result = Test-TargetResource -Ensure "Present" -MySqlVersion "5.6.17" -RootPassword $testCred -Port "3307"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'should return false'{
                $result | should be $false
            }
        }
    }

    Describe "how Test-TargetResource responds when Ensure = 'Absent'" {
        Context 'when the given version is installed and the port matches' {
            $MySqlInstalled = @{
                Ensure = "Present"
                MySqlVersion = "5.6.17"
                Port = "3306"
            }

            Mock Get-TargetResource -Verifiable { return $MySqlInstalled }

            $result = Test-TargetResource -Ensure "Absent" -MySqlVersion "5.6.17" -RootPassword $testCred -Port "3306"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'should return false'{
                $result | should be $false
            }
        }

        Context "when the given version is installed and port doesn't match" {
            $MySqlInstalled = @{
                Ensure = "Present"
                MySqlVersion = "5.6.17"
                Port = "3306"
            }

            Mock Get-TargetResource -Verifiable { return $MySqlInstalled }

            $result = Test-TargetResource -Ensure "Absent" -MySqlVersion "5.6.17" -RootPassword $testCred -Port "3307"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'should return false'{
                $result | should be $false
            }
        }

        Context 'when the given version is not installed and the port matches' {
            $MySqlNotInstalled = @{
                Ensure = "Absent"
                MySqlVersion = "5.6.17"
                Port = "3306"
            }

            Mock Get-TargetResource -Verifiable { return $MySqlNotInstalled }

            $result = Test-TargetResource -Ensure "Absent" -MySqlVersion "5.6.17" -RootPassword $testCred -Port "3306"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'should return true'{
                $result | should be $true
            }
        }

        Context "when the given version is not installed and the port doesn't match" {
            $MySqlNotInstalled = @{
                Ensure = "Absent"
                MySqlVersion = "5.6.17"
                Port = "3306"
            }

            Mock Get-TargetResource -Verifiable { return $MySqlNotInstalled }

            $result = Test-TargetResource -Ensure "Absent" -MySqlVersion "5.6.17" -RootPassword $testCred -Port "3307"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'should return false'{
                $result | should be $false
            }
        }
    }

    Describe "how Set-TargetResource works when Ensure is 'Present'" {
        Context "when no version is installed" {

            Mock Get-MySqlAllInstalled -Verifiable { return $null }
            Mock Get-MySqlInstallerConsole -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand -Verifiable { return }

            $null = Set-TargetResource -Ensure "Present" -MySqlVersion "5.6.17" -RootPassword $testCred -Port "3307"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
        }

        Context "when some version is installed" {

            Mock Get-MySqlAllInstalled -Verifiable { return "5.6.19" }
            Mock Get-MySqlInstallerConsole { return "C:\somepath" }
            Mock Invoke-MySqlCommand { return }

            $null = Set-TargetResource -Ensure "Present" -MySqlVersion "5.6.17" -RootPassword $testCred -Port "3307"

            It 'should not call all the mocks' {
                Assert-VerifiableMocks
                Assert-MockCalled Get-MySqlInstallerConsole 0
                Assert-MockCalled Invoke-MySqlCommand 0
            }
        }
    }

    Describe "how Set-TargetResource works when Ensure is 'Absent'" {
        Context "no matter what is installed" {

            Mock Get-MySqlAllInstalled { return $null }
            Mock Get-MySqlInstallerConsole { return "C:\somepath" }
            Mock Invoke-MySqlCommand { return }

            $null = Set-TargetResource -Ensure "Absent" -MySqlVersion "5.6.17" -RootPassword $testCred -Port "3307"

            It 'should call all the mocks' {
                Assert-MockCalled Get-MySqlAllInstalled 0
                Assert-MockCalled Get-MySqlInstallerConsole 0
                Assert-MockCalled Invoke-MySqlCommand 0
            }
        }
    }
}
