$here = Split-Path -Parent $MyInvocation.MyCommand.Path

if (! (Get-Module xDSCResourceDesigner))
{
    Import-Module -Name xDSCResourceDesigner
}

Describe 'Schema Validation MSFT_xMySqlGrant' {
    It 'should pass Test-xDscResource' {
        $path = Join-Path -Path $((get-item $here).parent.FullName) -ChildPath 'DSCResources\MSFT_xMySqlGrant'
        $result = Test-xDscResource $path
        $result | Should Be $true
    }

    It 'should pass Test-xDscSchema' {
        $path = Join-Path -Path $((get-item $here).parent.FullName) -ChildPath 'DSCResources\MSFT_xMySqlGrant\MSFT_xMySqlGrant.schema.mof'
        $result = Test-xDscSchema $path
        $result | Should Be $true
    }
}

if (Get-Module MSFT_xMySqlGrant)
{
    Remove-Module MSFT_xMySqlGrant
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
Import-Module (Join-Path $here -ChildPath "..\DSCResources\MSFT_xMySqlGrant\MSFT_xMySqlGrant.psm1")
Import-Module (Join-Path $here -ChildPath "..\xMySql.psd1")

$DSCResourceName = "MSFT_xMySqlGrant"
InModuleScope $DSCResourceName {

    $testPassword = ConvertTo-SecureString "password" -AsPlainText -Force
    $testCred = New-Object -typename System.Management.Automation.PSCredential -argumentlist "account",$testPassword

    Describe "how Get-TargetResource works" {
        $userName = "TestUser"
        $databaseName = "TestDB"

        Context "when ErrorPath exists" {
            $invokeResults = "GRANT USAGE ON *.* TO 'TestUser'@'localhost' IDENTIFIED BY PASSWORD '*326D8F59AB0875382A46BD23BE904264D7CE7EA0'", `
                "GRANT ALL PRIVILEGES ON `TestDB`.* TO 'TestUser'@'localhost'"
            $permissionType = "CREATE"

            Mock Test-Path -Verifiable { return $true }
            Mock Remove-Item -Verifiable { return }
            Mock Get-MySqlPort -Verifiable { return "3306" }
            Mock Get-MySqlExe -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand -Verifiable { return }
            Mock Read-ErrorFile -Verifiable { return }

            $result = Get-TargetResource -UserName $userName -DatabaseName $databaseName -RootCredential $testCred -PermissionType $permissionType -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
        }

        Context "when ErrorPath does not exist" {
            $invokeResults = "GRANT USAGE ON *.* TO 'TestUser'@'localhost' IDENTIFIED BY PASSWORD '*326D8F59AB0875382A46BD23BE904264D7CE7EA0'", `
                "GRANT ALL PRIVILEGES ON `TestDB`.* TO 'TestUser'@'localhost'"
            $permissionType = "CREATE"

            Mock Test-Path -Verifiable { return $false }
            Mock Remove-Item { return }
            Mock Get-MySqlPort -Verifiable { return "3306" }
            Mock Get-MySqlExe -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand -Verifiable { return }
            Mock Read-ErrorFile -Verifiable { return }

            $result = Get-TargetResource -UserName $userName -DatabaseName $databaseName -RootCredential $testCred -PermissionType $permissionType -MySqlVersion "5.6.17"

            It 'should not call all the mocks' {
                Assert-VerifiableMocks
                Assert-MockCalled Remove-Item 0
            }
        }

        Context 'when the permission granted is ALL PRIVILEGES' {
            $invokeResults = "GRANT USAGE ON *.* TO 'TestUser'@'localhost' IDENTIFIED BY PASSWORD '*326D8F59AB0875382A46BD23BE904264D7CE7EA0'", `
                "GRANT ALL PRIVILEGES ON `TestDB`.* TO 'TestUser'@'localhost'"
            $permissionType = "CREATE"

            Mock Test-Path -Verifiable { return $true }
            Mock Remove-Item -Verifiable { return }
            Mock Get-MySqlPort -Verifiable { return "3306" }
            Mock Get-MySqlExe -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand -Verifiable { return $invokeResults }
            Mock Read-ErrorFile -Verifiable { return }

            $result = Get-TargetResource -UserName $userName -DatabaseName $databaseName -RootCredential $testCred -PermissionType $permissionType -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It "UserName should be $userName" {
                $result['UserName'] | should be $userName
            }
            It "DatabaseName should be $databaseName" {
                $result['DatabaseName'] | should be $databaseName
            }
            It 'Ensure should be Present' {
                $result['Ensure'] | should be 'Present'
            }
            It 'PermissionType should be $permissionType' {
                $result['PermissionType'] | should be $permissionType
            }
        }

        Context 'when the given permission matches the permission granted' {
            $invokeResults = "GRANT USAGE ON *.* TO 'TestUser'@'localhost' IDENTIFIED BY PASSWORD '*326D8F59AB0875382A46BD23BE904264D7CE7EA0'", `
                "GRANT CREATE, DROP ON `TestDB`.* TO 'TestUser'@'localhost'"
            $permissionType = "CREATE"

            Mock Test-Path -Verifiable { return $true }
            Mock Remove-Item -Verifiable { return }
            Mock Get-MySqlPort -Verifiable { return "3306" }
            Mock Get-MySqlExe -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand -Verifiable { return $invokeResults }
            Mock Read-ErrorFile -Verifiable { return }

            $result = Get-TargetResource -UserName $userName -DatabaseName $databaseName -RootCredential $testCred -PermissionType $permissionType -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It "UserName should be $userName" {
                $result['UserName'] | should be $userName
            }
            It "DatabaseName should be $databaseName" {
                $result['DatabaseName'] | should be $databaseName
            }
            It 'Ensure should be Present' {
                $result['Ensure'] | should be 'Present'
            }
            It 'PermissionType should be $permissionType' {
                $result['PermissionType'] | should be $permissionType
            }
        }

        Context 'when the given permission does not match the permission granted' {
            $invokeResults = "GRANT USAGE ON *.* TO 'TestUser'@'localhost' IDENTIFIED BY PASSWORD '*326D8F59AB0875382A46BD23BE904264D7CE7EA0'", `
                "GRANT DROP ON `TestDB`.* TO 'TestUser'@'localhost'"
            $permissionType = "CREATE"

            Mock Test-Path -Verifiable { return $true }
            Mock Remove-Item -Verifiable { return }
            Mock Get-MySqlPort -Verifiable { return "3306" }
            Mock Get-MySqlExe -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand -Verifiable { return $invokeResults }
            Mock Read-ErrorFile -Verifiable { return }

            $result = Get-TargetResource -UserName $userName -DatabaseName $databaseName -RootCredential $testCred -PermissionType $permissionType -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It "UserName should be $userName" {
                $result['UserName'] | should be $userName
            }
            It "DatabaseName should be $databaseName" {
                $result['DatabaseName'] | should be $databaseName
            }
            It 'Ensure should be Absent' {
                $result['Ensure'] | should be 'Absent'
            }
            It 'PermissionType should be $permissionType' {
                $result['PermissionType'] | should be $permissionType
            }
        }
    }

    Describe "how Test-TargetResource works when Ensure is 'Present'" {
        Context 'when the given permission exists' {
            $permissionExists = @{
                UserName = "TestUser"
                DatabaseName = "TestDB"
                Ensure = "Present"
                PermissionType = "CREATE"
            }

            Mock Get-TargetResource -Verifiable { return $permissionExists }
            
            $result = Test-TargetResource -UserName "TestUser" -DatabaseName "TestDB" -Ensure "Present" -RootCredential $testCred -PermissionType "CREATE" -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'should return true' {
                $result | should be $true
            }
        }

        Context 'when the given user does not exist' {
            $permissionNotExist = @{
                UserName = "TestUser"
                DatabaseName = "TestDB"
                Ensure = "Absent"
                PermissionType = "CREATE"
            }

            Mock Get-TargetResource -Verifiable { return $permissionNotExist }
            
            $result = Test-TargetResource -UserName "TestUser" -DatabaseName "TestDB" -Ensure "Present" -RootCredential $testCred -PermissionType "CREATE" -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'should return false' {
                $result | should be $false
            }
        }
    }

    Describe "how Test-TargetResource works when Ensure is 'Absent'" {
        Context 'when the given permission exists' {
            $permissionExists = @{
                UserName = "TestUser"
                DatabaseName = "TestDB"
                Ensure = "Present"
                PermissionType = "CREATE"
            }

            Mock Get-TargetResource -Verifiable { return $permissionExists }
            
            $result = Test-TargetResource -UserName "TestUser" -DatabaseName "TestDB" -Ensure "Absent" -RootCredential $testCred -PermissionType "CREATE" -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'should return false' {
                $result | should be $false
            }
        }

        Context 'when the given user does not exist' {
            $permissionNotExist = @{
                UserName = "TestUser"
                DatabaseName = "TestDB"
                Ensure = "Absent"
                PermissionType = "CREATE"
            }

            Mock Get-TargetResource -Verifiable { return $permissionNotExist }
            
            $result = Test-TargetResource -UserName "TestUser" -DatabaseName "TestDB" -Ensure "Absent" -RootCredential $testCred -PermissionType "CREATE" -MySqlVersion "5.6.17"

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
            Mock Invoke-MySqlCommand { return } -ParameterFilter { $arguments -match "CREATE" }
            Mock Read-ErrorFile -Verifiable { return }

            $null = Set-TargetResource -UserName "TestUser" -DatabaseName "TestDB" -Ensure "Present" -RootCredential $testCred -PermissionType "CREATE" -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
                Assert-MockCalled Invoke-MySqlCommand -Exactly 1
            }
        }

        Context "when ErrorPath does not exist" {

            Mock Test-Path -Verifiable { return $false }
            Mock Remove-Item { return }
            Mock Get-MySqlPort -Verifiable { return "3306" }
            Mock Get-MySqlExe -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand { return } -ParameterFilter { $arguments -match "CREATE" }
            Mock Read-ErrorFile -Verifiable { return }

            $null = Set-TargetResource -UserName "TestUser" -DatabaseName "TestDB" -Ensure "Present" -RootCredential $testCred -PermissionType "CREATE" -MySqlVersion "5.6.17"

            It 'should not call all the mocks' {
                Assert-VerifiableMocks
                Assert-MockCalled Remove-Item 0
                Assert-MockCalled Invoke-MySqlCommand -Exactly 1
            }
        }

        Context "when Ensure is 'Present'" {

            Mock Test-Path -Verifiable { return $true }
            Mock Remove-Item -Verifiable { return }
            Mock Get-MySqlPort -Verifiable { return "3306" }
            Mock Get-MySqlExe -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand { return } -ParameterFilter { $arguments -match "CREATE" }
            Mock Read-ErrorFile -Verifiable { return }

            $null = Set-TargetResource -UserName "TestUser" -DatabaseName "TestDB" -Ensure "Present" -RootCredential $testCred -PermissionType "CREATE" -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
                Assert-MockCalled Invoke-MySqlCommand -Exactly 1
            }
        }

        Context "when Ensure is 'Absent'" {

            Mock Test-Path -Verifiable { return $true }
            Mock Remove-Item -Verifiable { return }
            Mock Get-MySqlPort -Verifiable { return "3306" }
            Mock Get-MySqlExe -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand { return } -ParameterFilter { $arguments -match "REVOKE" }
            Mock Read-ErrorFile -Verifiable { return }
            
            $null = Set-TargetResource -UserName "TestUser" -DatabaseName "TestDB" -Ensure "Absent" -RootCredential $testCred -PermissionType "CREATE" -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
                Assert-MockCalled Invoke-MySqlCommand -Exactly 1
            }
        }
    }
}
