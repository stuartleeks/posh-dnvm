function DebugMessage($message){
    [System.Diagnostics.Debug]::WriteLine("PoshDnvm:$message")
}
function DnvmTabExpansion($lastBlock) {

    $cmd = $lastBlock -replace "^dnvm\s*", ""
    switch -Regex ($cmd)  {

        ##########################################
        #
        # dnvm <cmd>
        
        # Handle dnvm <cmd>
        "^(?<cmd>\S*)$" {
            DebugMessage "DnvmExpansion: <cmd>; cmd=$($matches['cmd'])"
            $commands | filterMatches $matches['cmd'] 
        }

        
        ##########################################
        #
        # dnvm alias
        
        # Handle dnvm alias <name>
        "^alias (?<name>\S*)$" {
            DebugMessage "DnvmExpansion: alias <name>; name=$($matches['name'])"
            getAliases | filterMatches $matches['name']
        }
        # Handle dnvm alias -d <name>
        "^alias -d (?<name>\S*)$" {
            DebugMessage "DnvmExpansion: alias -d <name>; name=$($matches['name'])"
            getAliases | filterMatches $matches['name']
        }
        # Handle dnvm alias <name> <version>
        "^alias (?<name>[^-]\S*)\s+(?<version>\S*)$" {
            DebugMessage "DnvmExpansion: alias <name> <version>; name=$($matches['name']); version=$($matches['version'])"
            getVersions | filterMatches $matches['version']
        }
        # Handle dnvm alias <name> <version> [switches...] -<switch>
        "^alias (?<name>\S*)\s+(?<version>\S*)\s+.*(?<switch>-\S*)$" {
            DebugMessage "DnvmExpansion: alias <name> <name> -<switch>; name=$($matches['name']); version=$($matches['version']); switch=$($matches['switch'])"
            @('-a', '-arch', '-os', '-r') | filterMatches $matches['switch']
        }

        # Handle dnvm alias <name> <version> -a <arch>
        "^alias (?<name>\S*)\s+(?<version>\S*)\s+.*-a\s+(?<arch>\S*)$" {
           DebugMessage "DnvmExpansion: alias <name> <version> -a <arch>; name=$($matches['name']); version=$($matches['version']); arch=$($matches['arch'])"
           getArchitectures | filterMatches $matches['arch']
        }
        # Handle dnvm alias <name> <version> -arch <arch>
        "^alias (?<name>\S*)\s+(?<version>\S*)\s+.*-arch\s+(?<arch>\S*)$" {
           DebugMessage "DnvmExpansion: alias <name> <version> -arch <arch>; name=$($matches['name']); version=$($matches['version']); arch=$($matches['arch'])"
           getArchitectures | filterMatches $matches['arch']
        }

        # Handle dnvm alias <name> <version> -os <os>
        "^alias (?<name>\S*)\s+(?<version>\S*)\s+.*-os\s+(?<os>\S*)$" {
           DebugMessage "DnvmExpansion: alias <name> <version> -os <os>; name=$($matches['name']); version=$($matches['version']); os=$($matches['os'])"
           getOSes | filterMatches $matches['os']
        }

        # Handle dnvm alias <name> <version> -r <runtime>
        "^alias (?<name>\S*)\s+(?<version>\S*)\s+.*-r\s+(?<runtime>\S*)$" {
            DebugMessage "DnvmExpansion: alias <name> <version> -r <runtime>; name=$($matches['name']); version=$($matches['version']); runtime=$($matches['runtime'])"
            getRuntimes | filterMatches $matches['runtime'] 
        }
        
        
        ##########################################
        #
        # dnvm exec

        # Handle dnvm exec <VersionOrAlias>
        "^exec (?<name>\S*)$" {
            DebugMessage "DnvmExpansion: exec <VersionOrAlias>; name=$($matches['name'])"
            getAliasesAndVersions | filterMatches $matches['name']
        }
        # Handle dnvm exec <cmd> <version> [switches...] -<switch>
        "^exec (?<name>\S*)\s+(?<version>\S*).*\s(?<switch>-\S*)$" {
            DebugMessage "DnvmExpansion: exec <name> <version> -<switch>; name=$($matches['name']); version=$($matches['version']); switch=$($matches['switch'])"
            @('-a', '-arch', '-r') | filterMatches $matches['switch']
        }
        # Handle dnvm exec <name> <version> [switches...] -a <arch>
        "^exec (?<name>\S*)\s+(?<version>\S*).*\s-a\s+(?<arch>\S*)$" {
            DebugMessage "DnvmExpansion: exec <name> <version> -arch <arch>; name=$($matches['name']); version=$($matches['version']); arch=$($matches['arch'])"
            getArchitectures | filterMatches $matches['arch'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
        }
        # Handle dnvm exec <name> <version> [switches...] -arch <arch>
        "^exec (?<name>\S*)\s+(?<version>\S*).*\s-arch\s*(?<arch>\S*)$" {
            DebugMessage "DnvmExpansion: exec <name> <version> -arch <arch>; name=$($matches['name']); version=$($matches['version']); arch=$($matches['arch'])"
            getArchitectures | filterMatches $matches['arch'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
        }
        # Handle dnvm exec <name> <version> [switches...] -r <runtime>
        "^exec (?<name>\S*)\s+(?<version>\S*).*\s-r\s*(?<runtime>\S*)$" {
            DebugMessage "DnvmExpansion: exec <name> <version> -r <runtime>; name=$($matches['name']); version=$($matches['version']); runtime=$($matches['runtime'])"
            getRuntimes | filterMatches $matches['runtime'] 
        }        
        
        ##########################################
        #
        # dnvm help <cmd>

        # Handle dnvm help <cmd>
        "^help (?<cmd>\S*)$" {
            DebugMessage "DnvmExpansion: help <cmd>; cmd=$($matches['cmd'])"
            $commands | filterMatches $matches['cmd'] | ?{$_ -ne 'help'}
        }
        # Handle dnvm help -<switch>
        "^help.*\s(?<switch>-\S*)$" {
            DebugMessage "DnvmExpansion: help -<switch>; switch=$($matches['switch'])"
            @('-PassThru') | filterMatches $matches['switch']
        }
        # Handle dnvm help cmd -<switch>
        "^help\s+(?<switch>-\S*)\s+(?<switch>-\S*)$" {
            DebugMessage "DnvmExpansion: help <cmd> -<switch>; cmd=$($matches['cmd']); switch=$($matches['switch'])"
            @('-PassThru') | filterMatches $matches['switch']
        }

        ##########################################
        #
        # dnvm install

        # Handle dnvm install <name>
        "^install (?<name>\S*)$" {
            DebugMessage "DnvmExpansion: install <name>; name=$($matches['name'])"
            # TODO - name can be path to .nupkg, 'latest', or a version!
            # for now, just disable tab expansion?!
            ''
        }
        # Handle dnvm install <name> [switches...] -<switch>
        "^install (?<name>\S*).*\s(?<switch>-\S*)$" {
            DebugMessage "DnvmExpansion: install <name> -<switch>; name=$($matches['name']); switch=$($matches['switch'])"
            @('-a', '-alias', '-arch', '-r', '-f', '-g', '-Proxy', '-NoNative', '-Ngen', '-Persistent', '-Unstable') | filterMatches $matches['switch']
        }
        # Handle dnvm install <name> [switches...] -a <arch>
        "^install (?<name>\S*).*\s-a\s*(?<arch>\S*)$" {
            DebugMessage "DnvmExpansion: install <name> -arch <arch>; name=$($matches['name']); arch=$($matches['arch'])"
            getArchitectures | filterMatches $matches['arch'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
        }
        # Handle dnvm install <name> [switches...] -arch <arch>
        "^install (?<name>\S*).*\s-arch\s*(?<arch>\S*)$" {
            DebugMessage "DnvmExpansion: install <name> -arch <arch>; name=$($matches['name']); arch=$($matches['arch'])"
            getArchitectures | filterMatches $matches['arch'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
        }
        # Handle dnvm install <name> [switches...] -r <runtime>
        "^install (?<name>\S*).*\s-r\s*(?<runtime>\S*)$" {
            DebugMessage "DnvmExpansion: install <name> -r <runtime>; name=$($matches['name']); runtime=$($matches['runtime'])"
            getRuntimes | filterMatches $matches['runtime'] 
        }
        # Handle dnvm install <name> [switches...] -os <os>
        "^install (?<name>\S*).*\s-os\s*(?<os>\S*)$" {
            DebugMessage "DnvmExpansion: install <name> -os <os>; name=$($matches['name']); os=$($matches['os'])"
            getOSes | filterMatches $matches['os'] 
        }
        # Handle dnvm install <name> [switches...] -alias <alias>
        "^install (?<name>\S*).*\s-alias\s*(?<alias>\S*)$" {
            DebugMessage "DnvmExpansion: install <name> -alias <alias>; name=$($matches['name']); alias=$($matches['alias'])"
            getAliases | filterMatches $matches['alias'] 
        }

        ##########################################
        #
        # dnvm list

        # Handle dnvm list -<switch>
        "^list.*\s(?<switch>-\S*)$" {
            DebugMessage "DnvmExpansion: list -<switch>; switch=$($matches['switch'])"
            @('-Detailed', '-PassThru') | filterMatches $matches['switch']
        }

        ##########################################
        #
        # dnvm name

        # Handle dnvm name <name>
        "^name (?<name>\S*)$" {
            DebugMessage "DnvmExpansion: name <name>; name=$($matches['name'])"
            getAliasesAndVersions | filterMatches $matches['name']
        }
        # Handle dnvm name <name> [switches...] -<switch>
        "^name (?<name>\S*).*\s(?<switch>-\S*)$" {
            DebugMessage "DnvmExpansion: name <name> -<switch>; name=$($matches['name']); switch=$($matches['switch'])"
            @('-arch', '-r') | filterMatches $matches['switch']
        }
        # Handle dnvm name <name> [switches...] -arch <arch>
        "^name (?<name>\S*).*\s-arch\s*(?<arch>\S*)$" {
            DebugMessage "DnvmExpansion: name <name> -arch <arch>; name=$($matches['name']); arch=$($matches['arch'])"
            getArchitectures | filterMatches $matches['arch'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
        }
        # Handle dnvm name <name> [switches...] -r <runtime>
        "^name (?<name>\S*).*\s-r\s*(?<runtime>\S*)$" {
            DebugMessage "DnvmExpansion: name <name> -r <runtime>; name=$($matches['name']); runtime=$($matches['runtime'])"
            getRuntimes | filterMatches $matches['runtime'] 
        }


        ##########################################
        #
        # dnvm run

        # Handle dnvm run <VersionOrAlias>
        "^run (?<name>\S*)$" {
            DebugMessage "DnvmExpansion: run <VersionOrAlias>; name=$($matches['name'])"
            getAliasesAndVersions | filterMatches $matches['name']
        }
        # Handle dnvm run <cmd> <version> [switches...] -<switch>
        "^run (?<name>\S*)\s+(?<version>\S*).*\s(?<switch>-\S*)$" {
            DebugMessage "DnvmExpansion: run <name> <version> -<switch>; name=$($matches['name']); version=$($matches['version']); switch=$($matches['switch'])"
            @('-a', '-arch', '-r') | filterMatches $matches['switch']
        }
        # Handle dnvm run <name> <version> [switches...] -a <arch>
        "^run (?<name>\S*)\s+(?<version>\S*).*\s-a\s+(?<arch>\S*)$" {
            DebugMessage "DnvmExpansion: run <name> <version> -a <arch>; name=$($matches['name']); version=$($matches['version']); arch=$($matches['arch'])"
            getArchitectures | filterMatches $matches['arch'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
        }
        # Handle dnvm run <name> <version> [switches...] -arch <arch>
        "^run (?<name>\S*)\s+(?<version>\S*).*\s-arch\s+(?<arch>\S*)$" {
            DebugMessage "DnvmExpansion: run <name> <version> -arch <arch>; name=$($matches['name']); version=$($matches['version']); arch=$($matches['arch'])"
            getArchitectures | filterMatches $matches['arch'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
        }
        # Handle dnvm run <name> <version> [switches...] -r <runtime>
        "^run (?<name>\S*)\s+(?<version>\S*).*\s-r\s*(?<runtime>\S*)$" {
            DebugMessage "DnvmExpansion: run <name> <version> -r <runtime>; name=$($matches['name']); version=$($matches['version']); runtime=$($matches['runtime'])"
            getRuntimes | filterMatches $matches['runtime'] 
        }  

        ##########################################
        #
        # dnvm setup 

        # Handle dnvm setup -<switch>
        "^setup.*\s(?<switch>-\S*)$" {
            DebugMessage "DnvmExpansion: setup -<switch>; switch=$($matches['switch'])"
            @('-SkipUserEnvironmentInstall') | filterMatches $matches['switch']
        }
        
        ##########################################
        #
        # dnvm uninstall

        # Handle dnvm uninstall <VersionOrAlias>
        "^uninstall (?<name>\S*)$" {
            DebugMessage "DnvmExpansion: uninstall <name>; name=$($matches['name'])"
            getAliasesAndVersions | filterMatches $matches['name']
        }
        # Handle dnvm uninstall <name> [switches...] -<switch>
        "^uninstall (?<name>\S*).*\s(?<switch>-\S*)$" {
            DebugMessage "DnvmExpansion: uninstall <name> -<switch>; name=$($matches['name']); switch=$($matches['switch'])"
            @('-a', '-arch', '-r', '-os') | filterMatches $matches['switch']
        }
        # Handle dnvm install <name> [switches...] -a <arch>
        "^uninstall (?<name>\S*).*\s-a\s+(?<arch>\S*)$" {
            DebugMessage "DnvmExpansion: uninstall <name> -arch <arch>; name=$($matches['name']); arch=$($matches['arch'])"
            getArchitectures | filterMatches $matches['arch'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
        }
        # Handle dnvm install <name> [switches...] -arch <arch>
        "^uninstall (?<name>\S*).*\s-arch\s+(?<arch>\S*)$" {
            DebugMessage "DnvmExpansion: uninstall <name> -arch <arch>; name=$($matches['name']); arch=$($matches['arch'])"
            getArchitectures | filterMatches $matches['arch'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
        }
        # Handle dnvm install <name> [switches...] -r <runtime>
        "^uninstall (?<name>\S*).*\s-r\s+(?<runtime>\S*)$" {
            DebugMessage "DnvmExpansion: uninstall <name> -r <runtime>; name=$($matches['name']); runtime=$($matches['runtime'])"
            getRuntimes | filterMatches $matches['runtime'] 
        }
        # Handle dnvm install <name> [switches...] -os <os>
        "^uninstall (?<name>\S*).*\s-os\s+(?<os>\S*)$" {
            DebugMessage "DnvmExpansion: uninstall <name> -os <os>; name=$($matches['name']); os=$($matches['os'])"
            getOSes | filterMatches $matches['os'] 
        }



        ##########################################
        #
        # dnvm upgrade

        # Handle dnvm upgrade <alias>
        "^upgrade (?<alias>\S*)$" {
            DebugMessage "DnvmExpansion: upgrade <alias>; alias=$($matches['alias'])"
            getAliases | filterMatches $matches['alias'] 
        }
        # Handle dnvm upgrade <alias> [switches...] -<switch>
        "^upgrade ((?<alias>\S*)?.*\s)?(?<switch>-\S*)$" {
            DebugMessage "DnvmExpansion: upgrade <alias> -<switch>; alias=$($matches['alias']); switch=$($matches['switch'])"
            @('-a', '-arch', '-r', '-f', '-g', '-Proxy', '-NoNative', '-Ngen', '-Unstable') | filterMatches $matches['switch']
        }
        # Handle dnvm upgrade <alias> [switches...] -arch <arch>
        "^upgrade ((?<alias>\S*)?.*\s)?-a\s*(?<arch>\S*)$" {
            DebugMessage "DnvmExpansion: upgrade <alias> -a <arch>; alias=$($matches['alias']); arch=$($matches['arch'])"
            getArchitectures | filterMatches $matches['arch'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
        }
        # Handle dnvm upgrade <alias> [switches...] -arch <arch>
        "^upgrade ((?<alias>\S*)?.*\s)?-arch\s*(?<arch>\S*)$" {
            DebugMessage "DnvmExpansion: upgrade <alias> -arch <arch>; alias=$($matches['alias']); arch=$($matches['arch'])"
            getArchitectures | filterMatches $matches['arch'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
        }
        # Handle dnvm upgrade <alias> [switches...] -os <os>
        "^upgrade ((?<alias>\S*)?.*\s)?-os\s*(?<os>\S*)$" {
            DebugMessage "DnvmExpansion: upgrade <alias> -a <os>; alias=$($matches['alias']); os=$($matches['os'])"
            getOSes | filterMatches $matches['os'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
        }
        # Handle dnvm upgrade <alias> [switches...] -r <runtime>
        "^upgrade ((?<alias>\S*)?.*\s)?-r\s*(?<runtime>\S*)$" {
            DebugMessage "DnvmExpansion: upgrade <alias> -r <runtime>; alias=$($matches['alias']); runtime=$($matches['runtime'])"
            getRuntimes | filterMatches $matches['runtime'] 
        }


        ##########################################
        #
        # dnvm use

        # Handle dnvm use <VersionOrAlias>
        "^use (?<name>\S*)$" {
            DebugMessage "DnvmExpansion: use <name>; name=$($matches['name'])"
            getAliasesAndVersions | filterMatches $matches['name']
        }
        # Handle dnvm use <VersionOrAlias> [switches...] -<switch>
        "^use (?<name>\S*).*\s(?<switch>-\S*)$" {
            DebugMessage "DnvmExpansion: use <name> -<switch>; name=$($matches['name']); switch=$($matches['switch'])"
            @('-a', '-arch', '-r', '-p') | filterMatches $matches['switch']
        }
        # Handle dnvm use <VersionOrAlias> [switches...] -a <arch>
        "^use (?<name>\S*).*\s-a\s+(?<arch>\S*)$" {
            DebugMessage "DnvmExpansion: use <name> -a <arch>; name=$($matches['name']); arch=$($matches['arch'])"
            getArchitectures | filterMatches $matches['arch'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
        }
        # Handle dnvm use <VersionOrAlias> [switches...] -arch <arch>
        "^use (?<name>\S*).*\s-arch\s+(?<arch>\S*)$" {
            DebugMessage "DnvmExpansion: use <name> -arch <arch>; name=$($matches['name']); arch=$($matches['arch'])"
            getArchitectures | filterMatches $matches['arch'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
        }
        # Handle dnvm use <VersionOrAlias> [switches...] -r <runtime>
        "^use (?<name>\S*).*\s-r\s+(?<runtime>\S*)$" {
            DebugMessage "DnvmExpansion: use <name> -r <runtime>; name=$($matches['name']); runtime=$($matches['runtime'])"
            getRuntimes | filterMatches $matches['runtime']
        }


        default {
            DebugMessage "DnvmExpansion - not handled: $cmd"
        }
    }
}

$commands = @('alias', 'exec', 'help', 'install', 'list', 'run', 'setup', 'uninstall', 'update-self', 'upgrade', 'use');

function filterMatches($filter){
  if($filter) {
     $input| ? { $_.StartsWith($filter, "InvariantCultureIgnoreCase") } | sort  
  }
  else {
    $input | % { $_.Trim() } | sort
  }
}

function getAliasesAndVersions(){
    $aliases = getAliases
    $versions = getVersions
    $aliases + $versions
}
function getAliases(){
    dnvm list -PassThru | ?{$_.Alias -ne ""} | %{$_.Alias}
}

function getVersions(){
    dnvm list -PassThru | select -Unique -ExpandProperty Version
}
function getRuntimes(){
    @('clr', 'coreclr') # values taken from inspecting dnvm.ps1 (look for ValidateSet on $runtime parameters)
}
function getArchitectures(){
    @('x64', 'x86', 'arm') # values taken from inspecting dnvm.ps1 (look for ValidateSet on $runtime parameters)
}
function getOSes(){
    @('darwin', 'linux', 'osx', 'win') # values taken from inspecting dnvm.ps1 (look for ValidateSet on $OS parameters)
}

# TODO - look at posh-git/posh-hg to link with powertab
DebugMessage "Installing: Test DnvmTabExpansionBackup function"
if(-not (Test-Path Function:\DnvmTabExpansionBackup)){

    if (Test-Path Function:\TabExpansion) {
        DebugMessage "Installing: Backup TabExpansion function"
        Rename-Item Function:\TabExpansion DnvmTabExpansionBackup
    }

    function TabExpansion($line, $lastWord) {
       $lastBlock = [regex]::Split($line, '[|;]')[-1].TrimStart()

       switch -Regex ($lastBlock) {
            "^dnvm (.*)" { DnvmTabExpansion $lastBlock }

            # Fall back on existing tab expansion
            default { if (Test-Path Function:\DnvmTabExpansionBackup) { DnvmTabExpansionBackup $line $lastWord } }
       }
    }
}