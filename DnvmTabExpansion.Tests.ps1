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
        ,(DnvmTabExpansion "dnvm ") | Should MatchArray @('alias', 'exec', 'help', 'install', 'list', 'run', 'setup', 'update-self', 'upgrade', 'use')
    }
    It "returns a partial list of matching items"{
        ,(DnvmTabExpansion "dnvm u") | Should MatchArray @('update-self', 'upgrade', 'use')
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
    Context "name version arch" {
        It "lists all architectures when nothing is specified" {
            ,(DnvmTabExpansion "dnvm alias somename 1.0 ") | Should MatchArray @('x64', 'x86', 'arm')
        }
        It "lists matching architectures when partial is specified" {
            ,(DnvmTabExpansion "dnvm alias somename 1.0 x8") | Should MatchArray @('x86')
        }
    }
    Context "name version arch runtime" {
        It "lists all runtimes when nothing is specified" {
            ,(DnvmTabExpansion "dnvm alias somename 1.0 x86 ") | Should MatchArray @('coreclr', 'clr')
        }
        It "lists matching runtimes when partial is specified" {
            ,(DnvmTabExpansion "dnvm alias somename 1.0 x86 cor") | Should MatchArray @('coreclr')
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
            ,(DnvmTabExpansion "dnvm exec somename cmd -") | Should MatchArray @('-arch', '-r') 
        } 
        It "lists matching switches when partial is specified" { 
            ,(DnvmTabExpansion "dnvm exec somename cmd -a") | Should MatchArray @('-arch') 
        } 
        It "lists all switches when only switch char is specified" { 
            ,(DnvmTabExpansion "dnvm exec 1.0.1 cmd -") | Should MatchArray @('-arch', '-r') 
        } 
        It "lists matching switches when partial is specified" { 
            ,(DnvmTabExpansion "dnvm exec 1.0.1 cmd -a") | Should MatchArray @('-arch') 
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
            ,(DnvmTabExpansion "dnvm help ") | Should MatchArray @('alias', 'exec', 'install', 'list', 'run', 'setup', 'update-self', 'upgrade', 'use')
        }
        It "returns a partial list of matching items"{
            ,(DnvmTabExpansion "dnvm help u") | Should MatchArray @('update-self', 'upgrade', 'use')
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
            ,(DnvmTabExpansion "dnvm install name -") | Should MatchArray @('-arch', '-r', '-a', '-f', '-Proxy', '-NoNative', '-Ngen', '-Persistent', '-Unstable')
        }
        It "lists matching switches when partial is specified" {
            ,(DnvmTabExpansion "dnvm install name -N") | Should MatchArray @('-NoNative', '-Ngen')
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
    Context "install <name> -r" {
        It "lists all runtimes when nothing is specified" {
            ,(DnvmTabExpansion "dnvm install somename -r ") | Should MatchArray @('coreclr', 'clr')
        }
        It "lists matching runtimes when partial is specified" {
            ,(DnvmTabExpansion "dnvm install somename -r cor") | Should MatchArray @('coreclr')
        }
        It "lists when combined with other switches" {
            ,(DnvmTabExpansion "dnvm install somename -foo -r ") | Should MatchArray @('coreclr', 'clr')
        }
    }
    Context "install <name> -a" {
        Mock getAliases { @('alias1', 'alias2', 'anotherAlias') }
        It "completes alias names" {
            ,(DnvmTabExpansion "dnvm install name -a ") | Should MatchArray @('alias1', 'alias2', 'anotherAlias')      
        }
        It "completes alias names filtered to matching" {
            ,(DnvmTabExpansion "dnvm install name -a al") | Should MatchArray @('alias1', 'alias2')      
        }
        It "completes alias names when combined with other switches" {
            ,(DnvmTabExpansion "dnvm install somename -foo -a ") | Should MatchArray @('alias1', 'alias2', 'anotherAlias')
        }
    }
}

Describe "dnvm list *" {
    Context "list  -switches" {
        It "lists all switches when only switch char is specified" {
            ,(DnvmTabExpansion "dnvm list -") | Should MatchArray @('-PassThru')
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
            ,(DnvmTabExpansion "dnvm run somename 1.0 -") | Should MatchArray @('-arch', '-r') 
        } 
        It "lists matching switches when partial is specified" { 
            ,(DnvmTabExpansion "dnvm run somename 1.0 -a") | Should MatchArray @('-arch') 
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
            ,(DnvmTabExpansion "dnvm upgrade name -") | Should MatchArray @('-arch', '-r', '-f', '-Proxy', '-NoNative', '-Ngen', '-Unstable')
        }
        It "lists matching switches when partial is specified" {
            ,(DnvmTabExpansion "dnvm upgrade name -N") | Should MatchArray @('-NoNative', '-Ngen')
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
            ,(DnvmTabExpansion "dnvm use name -") | Should MatchArray @('-arch', '-r', '-p')
        }
        It "lists matching switches when partial is specified" {
            ,(DnvmTabExpansion "dnvm use name -a") | Should MatchArray @('-arch')
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