$here = Split-Path -Parent $MyInvocation.MyCommand.Path

if (! (Get-Module xDSCResourceDesigner))
{
    Import-Module -Name xDSCResourceDesigner
}

if (Get-Module xMySql)
{
    Remove-Module xMySql
}

if (Get-Module MSFT_xMySqlUtilities -All)
{
    Get-Module MSFT_xMySqlUtilities -All | Remove-Module
}
$breakvar = $true
Import-Module (Join-Path $here -ChildPath "..\xMySql.psd1")

$DSCResourceName = "MSFT_xMySqlUtilities"
InModuleScope $DSCResourceName {
    Describe 'how Invoke-MySqlCommand works' {
        Context 'when the CommandPath does not exist' {
            $commandPath = "C:\somepath.exe"
            $arguments = "test", "test2"

            It 'should throw an error if the CommandPath does not exist' {
                Mock Test-Path -Verifiable { return $false }
                { Invoke-MySqlCommand -CommandPath $commandPath -Arguments $arguments } | should throw "$commandPath does not exist"
            }
            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
        }
    }

    Describe 'how Get-MySqlInstallerConsole works' {
        Context 'when the Installer Console is installed' {

            Mock Test-Path -Verifiable { return $true }

            $result = Get-MySqlInstallerConsole

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'should return C:\Program Files (x86)\MySQL\MySQL Installer for Windows\MySQLInstallerConsole.exe' {
                $result | should be "C:\Program Files (x86)\MySQL\MySQL Installer for Windows\MySQLInstallerConsole.exe"
            }
        }

        Context 'when the Installer Console is not installed' {

            It 'should throw an error if the Installer Console is not installed' {
                Mock Test-Path -Verifiable { return $false }
                { Get-MySqlInstallerConsole } | should throw "Please ensure that MySQL Installer for Windows is installed"
            }
            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
        }
    }

    Describe 'how Get-MySqlExe works' {
        Context 'when the x64 version is installed' {
            $installPathX64 = "C:\Program Files\MySQL\MySQL Server 5.6\bin\mysql.exe"

            Mock Get-ShortVersion -Verifiable { return 5.6 }
            Mock Test-Path -Verifiable { return $true } -ParameterFilter { $path -eq $installPathX64 }

            $result = Get-MySqlExe -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It "should return $installPathX64" {
                $result | should be $installPathX64
            }
        }

        Context 'when the x86 version is installed' {
            $installPathX64 = "C:\Program Files\MySQL\MySQL Server 5.6\bin\mysql.exe"
            $installPathX86 = "C:\Program Files (x86)\MySQL\MySQL Server 5.6\bin\mysql.exe"

            Mock Get-ShortVersion -Verifiable { return 5.6 }
            Mock Test-Path -Verifiable { return $false } -ParameterFilter { $path -eq $installPathX64 }
            Mock Test-Path -Verifiable { return $true } -ParameterFilter { $path -eq $installPathX86 }

            $result = Get-MySqlExe -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It "should return $installPathX86" {
                $result | should be $installPathX86
            }
        }

        Context 'when the version is not installed' {

            It 'should throw an error if that version is not installed' {
                Mock Get-ShortVersion -Verifiable { return 5.6 }
                Mock Test-Path -Verifiable { return $false }

                {Get-MySqlExe -MySqlVersion "5.6.17"} | should throw "Please ensure that MySQL Version 5.6 is installed"
            }
            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
        }
    }

    Describe 'how Get-MySqlVersionInstalled works' {
        $statusResult = @(
"Your currently installed community products are:",
"",
"MySQL Server 5.6.17",
"         Architecture=X64",
"         Installed On 8/27/2015",
"         Install Location: C:\Program Files\MySQL\MySQL Server 5.6\"
)

        Context 'when the given version is installed' {

            Mock Get-MySqlInstallerConsole -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand -Verifiable { return $statusResult }

            $result = Get-MySqlVersionInstalled -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'should return true' {
                $result | should be $true
            }
        }

        Context 'when the given version is not installed' {

            Mock Get-MySqlInstallerConsole -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand -Verifiable { return $statusResult }

            $result = Get-MySqlVersionInstalled -MySqlVersion "5.6.5"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'should return false' {
                $result | should be $false
            }
        }
    }

    Describe 'how Get-MySqlAllInstalled works' {
        Context 'should find all of the versions' {
            $statusResult = @(
"Your currently installed community products are:",
"",
"MySQL Server 5.6.17",
"         Architecture=X64",
"         Installed On 8/27/2015",
"         Install Location: C:\Program Files\MySQL\MySQL Server 5.6\",
"",
"MySQL Server 5.7.7",
"         Architecture=X64",
"         Installed On 8/27/2015",
"         Install Location: C:\Program Files\MySQL\MySQL Server 5.7\"
)

            $expectedResult = "5.6.17", "5.7.7"

            Mock Get-MySqlInstallerConsole -Verifiable { return "C:\somepath" }
            Mock Invoke-MySqlCommand -Verifiable { return $statusResult }

            $result = Get-MySqlAllInstalled

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'first version should match' {
                $result[0] | should be $expectedResult[0]
            }
            It 'second version should match' {
                $result[1] | should be $expectedResult[1]
            }
        }
    }

    Describe 'how Get-ShortVersion works' {
        Context 'should get the shortened version number' {

            $result = Get-ShortVersion -MySqlVersion "5.6.17"

            It 'should be 5.6' {
                $result | should be "5.6"
            }
        }
    }

    Describe 'how Read-ErrorFile works' {
        Context 'how it works when there is an ERROR in the file' {
            $mySqlError = "mysql.exe : Warning: Using a password on the command line interface can be insecure.", "At line:11 char:1", "+ & $CommandPath $Arguments", `
                "+ ~~~~~~~~~~~~~~~~~~~~~~~~~", "    + CategoryInfo          : NotSpecified: (Warning: Using ...an be insecure.:String) [], RemoteException", `
                "    + FullyQualifiedErrorId : NativeCommandError", "", "ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)"

            It 'should throw an error if there is an ERROR in the file' {
                Mock Test-Path -Verifiable { return $true }
                Mock Get-Content -Verifiable { return $mySqlError }
                Mock Remove-Item { return }

                {Read-ErrorFile -ErrorFilePath C:\somepath} | should throw "ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)"
            }
            It 'should call all the mocks' {
                Assert-VerifiableMocks
                Assert-MockCalled Remove-Item 1
            }
        }

        Context 'how it works when there is not an ERROR in the file' {
            $mySqlError = "mysql.exe : Warning: Using a password on the command line interface can be insecure.", "At line:11 char:1", "+ & $CommandPath $Arguments", `
                "+ ~~~~~~~~~~~~~~~~~~~~~~~~~", "    + CategoryInfo          : NotSpecified: (Warning: Using ...an be insecure.:String) [], RemoteException", `
                "    + FullyQualifiedErrorId : NativeCommandError"

                Mock Test-Path -Verifiable { return $true }
                Mock Get-Content -Verifiable { return $mySqlError }
                Mock Remove-Item { return }

            $null = Read-ErrorFile -ErrorFilePath C:\somepath

            It 'should call all the mocks' {
                Assert-VerifiableMocks
                Assert-MockCalled Remove-Item 1
            }
        }

        Context 'how it works when the file does not exist' {

                Mock Test-Path -Verifiable { return $false }
                Mock Get-Content { return $mySqlError }
                Mock Remove-Item { return }

            $null = Read-ErrorFile -ErrorFilePath C:\somepath

            It 'should not call all the mocks' {
                Assert-VerifiableMocks
                Assert-MockCalled Get-Content 0
                Assert-MockCalled Remove-Item 0
            }
        }
    }

    Describe 'how Get-MySqlPort works' {
        Context 'how it works when the .ini file does not exist' {
            It 'should throw an error if the .ini file does not exist' {

                Mock Get-ShortVersion -Verifiable { return "5.6" }
                Mock Join-Path -Verifiable { return "C:\somepath" }
                Mock Test-Path -Verifiable { return $false }
                Mock Get-Content { return $myIni }

                {Get-MySqlPort -MySqlVersion "5.6.17"} | should throw "The my.ini file does not exist in the standard location"
            }
            It 'should not call all the mocks' {
                Assert-VerifiableMocks
                Assert-MockCalled Get-Content 0
            }
        }

        Context 'should return the port number' {
            $myIni = "[client]", "no-beep", "", "# pipe", "# socket=0.0", "port=3306", "", "[mysql]"

            Mock Get-ShortVersion -Verifiable { return "5.6" }
            Mock Join-Path -Verifiable { return "C:\somepath" }
            Mock Test-Path -Verifiable { return $true }
            Mock Get-Content -Verifiable { return $myIni }

            $result = Get-MySqlPort -MySqlVersion "5.6.17"

            It 'should call all the mocks' {
                Assert-VerifiableMocks
            }
            It 'should return port number 3306' {
                $result | should be "3306"
            }
        }
    }
}
