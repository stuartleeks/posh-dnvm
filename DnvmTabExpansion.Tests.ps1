$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Import-Module "$here\PesterMatchArray.psm1" -Force
# # Failing tests to test the problemMatcher when running tests in VSCode :-)
# Describe "failing test" {
#     It "fails!" {
#         $false | Should Be $true
#     }
#     It "fails again!" {
#         $false | Should Be $true
#     }
#     It "doesn't match the array" {
#        @("one", "two") | Should MatchArray @("One", "Two", "Three")
#     }
# }
Describe "dnvm <cmd>" {
    It "returns a full list when no input" {
        ,(DnvmTabExpansion "dnvm ") | Should MatchArray @('alias', 'exec', 'help', 'install', 'list', 'run', 'setup', 'uninstall', 'update-self', 'upgrade', 'use')
    }
    It "returns a partial list of matching items"{
        ,(DnvmTabExpansion "dnvm u") | Should MatchArray @('uninstall', 'update-self', 'upgrade', 'use')
    }
}

Describe "dnvm alias *" {
    Mock getAliases { @('alias1', 'alias2', 'anotherAlias') }
    Mock getVersions { @('1.0.0-beta4', '1.0.1', '2.0.0') }
    Context "general name completion" {
        It "completes alias names" {
            ,(DnvmTabExpansion "dnvm alias ") | Should MatchArray @('alias1', 'alias2', 'anotherAlias')      
        }
        It "completes alias names filtered to matching" {
            ,(DnvmTabExpansion "dnvm alias al") | Should MatchArray @('alias1', 'alias2')      
        }
    }
    Context "-d completion" {
        It "completes alias names" {
            ,(DnvmTabExpansion "dnvm alias -d ") | Should MatchArray @('alias1', 'alias2', 'anotherAlias')      
        }
        It "completes alias names filtered to matching" {
            ,(DnvmTabExpansion "dnvm alias -d al") | Should MatchArray @('alias1', 'alias2')      
        }
    }
    Context "name version" {
        It "lists all versions when none specified" {
            ,(DnvmTabExpansion "dnvm alias somename ") | Should MatchArray @('1.0.0-beta4', '1.0.1', '2.0.0')
        }
        It "lists matching versions when partial version specified" {
            ,(DnvmTabExpansion "dnvm alias somename 1") | Should MatchArray @('1.0.0-beta4', '1.0.1')
        }
    }
    Context "name version -switches" {
# TODO - review whether this should be a passing test 
#        It "lists all switches when none specified" { 
#            ,(DnvmTabExpansion "dnvm alias somename 1.0 ") | Should MatchArray @('-arch', '-r') 
#        } 
        It "lists all switches when only switch char is specified" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0 -") | Should MatchArray @('-a', '-arch', '-os', '-r') 
        } 
        It "lists matching switches when partial is specified" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0 -a") | Should MatchArray @('-a', '-arch') 
        } 
        It "lists matching switches when partial is specified after other parameters" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0 -a") | Should MatchArray @('-a', '-arch') 
        } 
        It "lists matching switches when partial is specified after other switches" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0 -r asdas -a") | Should MatchArray @('-a', '-arch') 
        } 
    }
    Context "name version -a" { 
        It "lists all architectures when nothing is specified" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0 -a ") | Should MatchArray @('x64', 'x86', 'arm') 
        } 
        It "lists all architectures when nothing is specified with extra spaces" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0     -a    ") | Should MatchArray @('x64', 'x86', 'arm') 
        } 
        It "lists all architectures when nothing is specified with extra switches" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0 -r asd -os asd -a ") | Should MatchArray @('x64', 'x86', 'arm') 
        } 
        It "lists matching architectures when partial is specified" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0 -a x8") | Should MatchArray @('x86') 
        } 
    } 
    Context "name version -arch" { 
        It "lists all architectures when nothing is specified" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0 -arch ") | Should MatchArray @('x64', 'x86', 'arm') 
        } 
        It "lists all architectures when nothing is specified with extra spaces" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0     -arch    ") | Should MatchArray @('x64', 'x86', 'arm') 
        } 
        It "lists all architectures when nothing is specified with extra switches" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0 -r asd -os asd -arch ") | Should MatchArray @('x64', 'x86', 'arm') 
        } 
        It "lists matching architectures when partial is specified" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0 -arch x8") | Should MatchArray @('x86') 
        } 
    } 
    Context "name version -os" { 
        It "lists all OSes when nothing is specified" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0 -os ") | Should MatchArray @('darwin', 'linux', 'osx', 'win') 
        } 
        It "lists all OSes when nothing is specified with extra spaces" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0    -os   ") | Should MatchArray @('darwin', 'linux', 'osx', 'win') 
        } 
        It "lists all OSes when nothing is specified with extra parameters" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0 -foo assad -weq asdasd -os ") | Should MatchArray @('darwin', 'linux', 'osx', 'win') 
        } 
        It "lists matching OSes when partial is specified" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0 -os w") | Should MatchArray @('win') 
        } 
    } 
    Context "name version -r" { 
        It "lists all runtimes when nothing is specified" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0 -r ") | Should MatchArray @('coreclr', 'clr') 
        } 
        It "lists all runtimes when nothing is specified with extra spaces" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0  -r     ") | Should MatchArray @('coreclr', 'clr') 
        } 
        It "lists all runtimes when nothing is specified with extra switches" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0 -foo asdasd -awe asdasd -r ") | Should MatchArray @('coreclr', 'clr') 
        } 
        It "lists matching runtimes when partial is specified" { 
            ,(DnvmTabExpansion "dnvm alias somename 1.0 -r cor") | Should MatchArray @('coreclr') 
        } 
    } 
}

Describe "dnvm exec *" {
    Mock getAliases { @('alias1', 'alias2', 'anotherAlias') }
    Mock getVersions { @('1.0.0-beta4', '1.0.1', '2.0.0') }
    Context "general name completion" {
        It "completes names (alias/version)" {
            ,(DnvmTabExpansion "dnvm exec ") | Should MatchArray @('alias1', 'alias2', 'anotherAlias', '1.0.0-beta4', '1.0.1', '2.0.0')      
        }
        It "completes names (alias/version) filtered to matching" {
            ,(DnvmTabExpansion "dnvm exec al") | Should MatchArray @('alias1', 'alias2')      
        }
    }
    Context "exec version -switches" {
# TODO - review whether this should be a passing test 
#        It "lists all switches when none specified" { 
#            ,(DnvmTabExpansion "dnvm alias somename 1.0 ") | Should MatchArray @('-arch', '-r') 
#        } 
        It "lists all switches when only switch char is specified" { 
            ,(DnvmTabExpansion "dnvm exec somename cmd -") | Should MatchArray @('-a','-arch', '-r') 
        } 
        It "lists matching switches when partial is specified" { 
            ,(DnvmTabExpansion "dnvm exec somename cmd -a") | Should MatchArray @('-a', '-arch') 
        } 
        It "lists all switches when only switch char is specified" { 
            ,(DnvmTabExpansion "dnvm exec 1.0.1 cmd -") | Should MatchArray @('-a', '-arch', '-r') 
        } 
        It "lists matching switches when partial is specified" { 
            ,(DnvmTabExpansion "dnvm exec 1.0.1 cmd -a") | Should MatchArray @('-a', '-arch') 
        } 
    }
    Context "name version -a" { 
        It "lists all architectures when nothing is specified" { 
            ,(DnvmTabExpansion "dnvm exec somename cmd -a ") | Should MatchArray @('x64', 'x86', 'arm') 
        } 
        It "lists matching architectures when partial is specified" { 
            ,(DnvmTabExpansion "dnvm exec somename cmd -a x8") | Should MatchArray @('x86') 
        } 
    } 
    Context "name version -arch" { 
        It "lists all architectures when nothing is specified" { 
            ,(DnvmTabExpansion "dnvm exec somename cmd -arch ") | Should MatchArray @('x64', 'x86', 'arm') 
        } 
        It "lists matching architectures when partial is specified" { 
            ,(DnvmTabExpansion "dnvm exec somename cmd -arch x8") | Should MatchArray @('x86') 
        } 
    } 
    Context "name version -r" { 
        It "lists all runtimes when nothing is specified" { 
            ,(DnvmTabExpansion "dnvm exec somename cmd -r ") | Should MatchArray @('coreclr', 'clr') 
        } 
        It "lists matching runtimes when partial is specified" { 
            ,(DnvmTabExpansion "dnvm exec somename cmd -r cor") | Should MatchArray @('coreclr') 
        } 
    } 
}


Describe "dnvm help <cmd>" {
    Context "command completion" {
        It "returns a full list when no input" {
            ,(DnvmTabExpansion "dnvm help ") | Should MatchArray @('alias', 'exec', 'install', 'list', 'run', 'setup', 'uninstall', 'update-self', 'upgrade', 'use')
        }
        It "returns a partial list of matching items"{
            ,(DnvmTabExpansion "dnvm help u") | Should MatchArray @('uninstall', 'update-self', 'upgrade', 'use')
        }
    }
    Context "help -switches" {
        It "lists all switches when only switch char is specified" {
            ,(DnvmTabExpansion "dnvm help -") | Should MatchArray @('-PassThru')
        }
        It "lists matching switches when partial is specified" {
            ,(DnvmTabExpansion "dnvm help -p") | Should MatchArray @('-PassThru')
        }        
    }
    Context "help cmd -switches" {
        It "lists all switches when only switch char is specified" {
            ,(DnvmTabExpansion "dnvm help -") | Should MatchArray @('-PassThru')
        }
        It "lists matching switches when partial is specified" {
            ,(DnvmTabExpansion "dnvm help -p") | Should MatchArray @('-PassThru')
        }        
    }
}

Describe "dnvm install *" {
    Context "VersionNuPkgOrAlias" {
        It "completion suppressed " {
            ,(DnvmTabExpansion "dnvm install ") | Should Be  ''
        }
    }
    Context "install <name> -switches" {
        It "lists all switches when only switch char is specified" {
            ,(DnvmTabExpansion "dnvm install name -") | Should MatchArray @('-a', '-alias', '-arch', '-r', '-f', '-g', '-Proxy', '-NoNative', '-Ngen', '-Persistent', '-Unstable')
        }
        It "lists matching switches when partial is specified" {
            ,(DnvmTabExpansion "dnvm install name -N") | Should MatchArray @('-NoNative', '-Ngen')
        }
    }
    Context "install <name> -a" {
        It "lists all architectures when nothing is specified" {
            ,(DnvmTabExpansion "dnvm install somename -a ") | Should MatchArray @('x64', 'x86', 'arm')
        }
        It "lists matching architectures when partial is specified" {
            ,(DnvmTabExpansion "dnvm install somename -a x8") | Should MatchArray @('x86')
        }
        It "lists when combined with other switches" {
            ,(DnvmTabExpansion "dnvm install somename -foo asd -a ") | Should MatchArray @('x64', 'x86', 'arm')
        }
    }
    Context "install <name> -arch" {
        It "lists all architectures when nothing is specified" {
            ,(DnvmTabExpansion "dnvm install somename -arch ") | Should MatchArray @('x64', 'x86', 'arm')
        }
        It "lists matching architectures when partial is specified" {
            ,(DnvmTabExpansion "dnvm install somename -arch x8") | Should MatchArray @('x86')
        }
        It "lists when combined with other switches" {
            ,(DnvmTabExpansion "dnvm install somename -foo -arch ") | Should MatchArray @('x64', 'x86', 'arm')
        }
    }
    Context "install <name> -os" {
        It "lists all OSes when nothing is specified" {
            ,(DnvmTabExpansion "dnvm install somename -os ") | Should MatchArray @('darwin', 'linux', 'osx', 'win')
        }
        It "lists matching OSes when partial is specified" {
            ,(DnvmTabExpansion "dnvm install somename -os lin") | Should MatchArray @('linux')
        }
        It "lists when combined with other switches" {
            ,(DnvmTabExpansion "dnvm install somename -foo asd -os ") | Should MatchArray @('darwin', 'linux', 'osx', 'win')
        }
    }
    Context "install <name> -r" {
        It "lists all runtimes when nothing is specified" {
            ,(DnvmTabExpansion "dnvm install somename -r ") | Should MatchArray @('coreclr', 'clr')
        }
        It "lists matching runtimes when partial is specified" {
            ,(DnvmTabExpansion "dnvm install somename -r cor") | Should MatchArray @('coreclr')
        }
        It "lists when combined with other switches" {
            ,(DnvmTabExpansion "dnvm install somename -foo asd -r ") | Should MatchArray @('coreclr', 'clr')
        }
    }
}

Describe "dnvm list *" {
    Context "list  -switches" {
        It "lists all switches when only switch char is specified" {
            ,(DnvmTabExpansion "dnvm list -") | Should MatchArray @('-Detailed', '-PassThru')
        }
        It "lists matching switches when partial is specified" {
            ,(DnvmTabExpansion "dnvm list -p") | Should MatchArray @('-PassThru')
        }        
    }
}

Describe "dnvm run *" {
    Mock getAliases { @('alias1', 'alias2', 'anotherAlias') }
    Mock getVersions { @('1.0.0-beta4', '1.0.1', '2.0.0') }
    Context "general name completion" {
        It "completes names (alias/version)" {
            ,(DnvmTabExpansion "dnvm run ") | Should MatchArray @('alias1', 'alias2', 'anotherAlias', '1.0.0-beta4', '1.0.1', '2.0.0')      
        }
        It "completes names (alias/version) filtered to matching" {
            ,(DnvmTabExpansion "dnvm run al") | Should MatchArray @('alias1', 'alias2')      
        }
    }
    Context "run version -switches" {
# TODO - review whether this should be a passing test 
#        It "lists all switches when none specified" { 
#            ,(DnvmTabExpansion "dnvm alias somename 1.0 ") | Should MatchArray @('-arch', '-r') 
#        } 
        It "lists all switches when only switch char is specified" { 
            ,(DnvmTabExpansion "dnvm run somename 1.0 -") | Should MatchArray @('-a', '-arch', '-r') 
        } 
        It "lists matching switches when partial is specified" { 
            ,(DnvmTabExpansion "dnvm run somename 1.0 -a") | Should MatchArray @('-a', '-arch') 
        } 
    }
    Context "name version -a" { 
        It "lists all architectures when nothing is specified" { 
            ,(DnvmTabExpansion "dnvm run somename 1.0 -a ") | Should MatchArray @('x64', 'x86', 'arm') 
        } 
        It "lists all architectures when nothing is specified with spaces" { 
            ,(DnvmTabExpansion "dnvm run somename 1.0   -a   ") | Should MatchArray @('x64', 'x86', 'arm') 
        } 
        It "lists all architectures when nothing is specified with extra switches" { 
            ,(DnvmTabExpansion "dnvm run somename 1.0 -fo asd -a ") | Should MatchArray @('x64', 'x86', 'arm') 
        } 
        It "lists matching architectures when partial is specified" { 
            ,(DnvmTabExpansion "dnvm run somename 1.0 -a x8") | Should MatchArray @('x86') 
        } 
    } 
    Context "name version -arch" { 
        It "lists all architectures when nothing is specified" { 
            ,(DnvmTabExpansion "dnvm run somename 1.0 -arch ") | Should MatchArray @('x64', 'x86', 'arm') 
        } 
        It "lists matching architectures when partial is specified" { 
            ,(DnvmTabExpansion "dnvm run somename 1.0 -arch x8") | Should MatchArray @('x86') 
        } 
    } 
    Context "name version -r" { 
        It "lists all runtimes when nothing is specified" { 
            ,(DnvmTabExpansion "dnvm run somename 1.0 -r ") | Should MatchArray @('coreclr', 'clr') 
        } 
        It "lists matching runtimes when partial is specified" { 
            ,(DnvmTabExpansion "dnvm run somename 1.0 -r cor") | Should MatchArray @('coreclr') 
        } 
    } 
 }

Describe "dnvm setup *" {
    Context "setup  -switches" {
        It "lists all switches when only switch char is specified" {
            ,(DnvmTabExpansion "dnvm setup -") | Should MatchArray @('-SkipUserEnvironmentInstall')
        }
        It "lists matching switches when partial is specified" {
            ,(DnvmTabExpansion "dnvm setup -s") | Should MatchArray @('-SkipUserEnvironmentInstall')
        }        
    }
}

Describe "dnvm uninstall *" {
    Mock getAliases { @('alias1', 'alias2', 'anotherAlias') }
    Mock getVersions { @('1.0.0-beta4', '1.0.1', '2.0.0') }
    Context "general name completion" {
        It "completes names (alias/version)" {
            ,(DnvmTabExpansion "dnvm uninstall ") | Should MatchArray @('alias1', 'alias2', 'anotherAlias', '1.0.0-beta4', '1.0.1', '2.0.0')      
        }
        It "completes names (alias/version) filtered to matching" {
            ,(DnvmTabExpansion "dnvm uninstall al") | Should MatchArray @('alias1', 'alias2')      
        }
    }
    Context "uninstall <name> -switches" {
        It "lists all switches when only switch char is specified" {
            ,(DnvmTabExpansion "dnvm uninstall name -") | Should MatchArray @('-a', '-arch', '-r', '-os')
        }
        It "lists matching switches when partial is specified" {
            ,(DnvmTabExpansion "dnvm uninstall name -a") | Should MatchArray @('-a', '-arch')
        }
    }
    Context "uninstall <name> -a" {
        It "lists all architectures when nothing is specified" {
            ,(DnvmTabExpansion "dnvm uninstall somename -a ") | Should MatchArray @('x64', 'x86', 'arm')
        }
        It "lists matching architectures when partial is specified" {
            ,(DnvmTabExpansion "dnvm uninstall somename -a x8") | Should MatchArray @('x86')
        }
        It "lists when combined with other switches" {
            ,(DnvmTabExpansion "dnvm uninstall somename -foo -a ") | Should MatchArray @('x64', 'x86', 'arm')
        }
    }
    Context "uninstall <name> -arch" {
        It "lists all architectures when nothing is specified" {
            ,(DnvmTabExpansion "dnvm uninstall somename -arch ") | Should MatchArray @('x64', 'x86', 'arm')
        }
        It "lists matching architectures when partial is specified" {
            ,(DnvmTabExpansion "dnvm uninstall somename -arch x8") | Should MatchArray @('x86')
        }
        It "lists when combined with other switches" {
            ,(DnvmTabExpansion "dnvm uninstall somename -foo -arch ") | Should MatchArray @('x64', 'x86', 'arm')
        }
    }
    Context "uninstall <name> -os" {
        It "lists all OSes when nothing is specified" {
            ,(DnvmTabExpansion "dnvm uninstall somename -os ") | Should MatchArray @('darwin', 'linux', 'osx', 'win')
        }
        It "lists matching OSes when partial is specified" {
            ,(DnvmTabExpansion "dnvm uninstall somename -os lin") | Should MatchArray @('linux')
        }
        It "lists when combined with other switches" {
            ,(DnvmTabExpansion "dnvm uninstall somename -foo -os ") | Should MatchArray @('darwin', 'linux', 'osx', 'win')
        }
    }
    Context "uninstall <name> -r" {
        It "lists all runtimes when nothing is specified" {
            ,(DnvmTabExpansion "dnvm uninstall somename -r ") | Should MatchArray @('coreclr', 'clr')
        }
        It "lists matching runtimes when partial is specified" {
            ,(DnvmTabExpansion "dnvm uninstall somename -r cor") | Should MatchArray @('coreclr')
        }
        It "lists when combined with other switches" {
            ,(DnvmTabExpansion "dnvm uninstall somename -foo -r ") | Should MatchArray @('coreclr', 'clr')
        }
    }
}


# dnvm update-self doesn't have any completable args 

Describe "dnvm upgrade *" {
    Mock getAliases { @('alias1', 'alias2', 'anotherAlias') }
    Mock getVersions { @('1.0.0-beta4', '1.0.1', '2.0.0') }
    Context "general name completion" {
        It "completes names (alias/version)" {
            ,(DnvmTabExpansion "dnvm upgrade ") | Should MatchArray @('alias1', 'alias2', 'anotherAlias')      
        }
        It "completes names (alias/version) filtered to matching" {
            ,(DnvmTabExpansion "dnvm upgrade al") | Should MatchArray @('alias1', 'alias2')      
        }
    }
    Context "upgrade <name> -switches" {
        It "lists all switches when only switch char is specified" {
            ,(DnvmTabExpansion "dnvm upgrade name -") | Should MatchArray @('-a', '-arch', '-r', '-f', '-g', '-Proxy', '-NoNative', '-Ngen', '-Unstable')
        }
        It "lists matching switches when partial is specified" {
            ,(DnvmTabExpansion "dnvm upgrade name -N") | Should MatchArray @('-NoNative', '-Ngen')
        }
   }
    Context "upgrade <name> -a" {
        It "lists all architectures when nothing is specified" {
            ,(DnvmTabExpansion "dnvm upgrade somename -a ") | Should MatchArray @('x64', 'x86', 'arm')
        }
        It "lists matching architectures when partial is specified" {
            ,(DnvmTabExpansion "dnvm upgrade somename -a x8") | Should MatchArray @('x86')
        }
        It "lists when combined with other switches" {
            ,(DnvmTabExpansion "dnvm upgrade somename -foo -a ") | Should MatchArray @('x64', 'x86', 'arm')
        }
    }
    Context "upgrade <name> -arch" {
        It "lists all architectures when nothing is specified" {
            ,(DnvmTabExpansion "dnvm upgrade somename -arch ") | Should MatchArray @('x64', 'x86', 'arm')
        }
        It "lists matching architectures when partial is specified" {
            ,(DnvmTabExpansion "dnvm upgrade somename -arch x8") | Should MatchArray @('x86')
        }
        It "lists when combined with other switches" {
            ,(DnvmTabExpansion "dnvm upgrade somename -foo -arch ") | Should MatchArray @('x64', 'x86', 'arm')
        }
    }
    Context "upgrade <name> -os" {
        It "lists all OSes when nothing is specified" {
            ,(DnvmTabExpansion "dnvm upgrade somename -os ") | Should MatchArray @('darwin', 'linux', 'osx', 'win')
        }
        It "lists matching OSes when partial is specified" {
            ,(DnvmTabExpansion "dnvm upgrade somename -os lin") | Should MatchArray @('linux')
        }
        It "lists when combined with other switches" {
            ,(DnvmTabExpansion "dnvm upgrade somename -foo -os ") | Should MatchArray @('darwin', 'linux', 'osx', 'win')
        }
    }
    Context "upgrade <name> -r" {
        It "lists all runtimes when nothing is specified" {
            ,(DnvmTabExpansion "dnvm upgrade somename -r ") | Should MatchArray @('coreclr', 'clr')
        }
        It "lists matching runtimes when partial is specified" {
            ,(DnvmTabExpansion "dnvm upgrade somename -r cor") | Should MatchArray @('coreclr')
        }
        It "lists when combined with other switches" {
            ,(DnvmTabExpansion "dnvm upgrade somename -foo -r ") | Should MatchArray @('coreclr', 'clr')
        }
    }
}

Describe "dnvm use *" {
    Mock getAliases { @('alias1', 'alias2', 'anotherAlias') }
    Mock getVersions { @('1.0.0-beta4', '1.0.1', '2.0.0') }
    Context "general name completion" {
        It "completes names (alias/version)" {
            ,(DnvmTabExpansion "dnvm use ") | Should MatchArray @('alias1', 'alias2', 'anotherAlias', '1.0.0-beta4', '1.0.1', '2.0.0')      
        }
        It "completes names (alias/version) filtered to matching" {
            ,(DnvmTabExpansion "dnvm use al") | Should MatchArray @('alias1', 'alias2')      
        }
    }
    Context "use <name> -switches" {
        It "lists all switches when only switch char is specified" {
            ,(DnvmTabExpansion "dnvm use name -") | Should MatchArray @('-a', '-arch', '-r', '-p')
        }
        It "lists matching switches when partial is specified" {
            ,(DnvmTabExpansion "dnvm use name -a") | Should MatchArray @('-a', '-arch')
        }
   }
   Context "use <name> -a" {
        It "lists all architectures when nothing is specified" {
            ,(DnvmTabExpansion "dnvm use somename -a ") | Should MatchArray @('x64', 'x86', 'arm')
        }
        It "lists matching architectures when partial is specified" {
            ,(DnvmTabExpansion "dnvm use somename -a x8") | Should MatchArray @('x86')
        }
        It "lists when combined with other switches" {
            ,(DnvmTabExpansion "dnvm use somename -foo -a ") | Should MatchArray @('x64', 'x86', 'arm')
        }
    }
   Context "use <name> -arch" {
        It "lists all architectures when nothing is specified" {
            ,(DnvmTabExpansion "dnvm use somename -arch ") | Should MatchArray @('x64', 'x86', 'arm')
        }
        It "lists matching architectures when partial is specified" {
            ,(DnvmTabExpansion "dnvm use somename -arch x8") | Should MatchArray @('x86')
        }
        It "lists when combined with other switches" {
            ,(DnvmTabExpansion "dnvm use somename -foo -arch ") | Should MatchArray @('x64', 'x86', 'arm')
        }
    }
    Context "use <name> -r" {
        It "lists all runtimes when nothing is specified" {
            ,(DnvmTabExpansion "dnvm use somename -r ") | Should MatchArray @('coreclr', 'clr')
        }
        It "lists matching runtimes when partial is specified" {
            ,(DnvmTabExpansion "dnvm use somename -r cor") | Should MatchArray @('coreclr')
        }
        It "lists when combined with other switches" {
            ,(DnvmTabExpansion "dnvm use somename -foo -r ") | Should MatchArray @('coreclr', 'clr')
        }
    }
}