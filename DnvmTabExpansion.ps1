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
        # dnvm help <cmd>

        # Handle dnvm help <cmd>
        "^help (?<cmd>\S*)$" {
            DebugMessage "DnvmExpansion: help <cmd>; cmd=$($matches['cmd'])"
            $commands | filterMatches $matches['cmd'] | ?{$_ -ne 'help'}
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
        "^alias (?<name>\S*)\s+(?<version>\S*).*\s(?<switch>-\S*)$" {
            DebugMessage "DnvmExpansion: alias <name> <version> -<switch>; name=$($matches['name']); version=$($matches['version']); switch=$($matches['switch'])"
            @('-arch', '-r') | filterMatches $matches['switch']
        }
        # Handle dnvm alias <name> <version> [switches...] -arch <arch>
        "^alias (?<name>\S*)\s+(?<version>\S*).*\s-arch\s*(?<arch>\S*)$" {
            DebugMessage "DnvmExpansion: alias <name> <version> -arch <arch>; name=$($matches['name']); version=$($matches['version']); arch=$($matches['arch'])"
            @('x86', 'x64') | filterMatches $matches['arch'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
        }
        # Handle dnvm alias <name> <version> [switches...] -r <runtime>
        "^alias (?<name>\S*)\s+(?<version>\S*).*\s-r\s*(?<runtime>\S*)$" {
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
            @('-arch', '-r', '-a', '-f', '-Proxy', '-NoNative', '-Ngen', '-Persistent', '-Unstable') | filterMatches $matches['switch']
        }
        # Handle dnvm install <name> [switches...] -arch <arch>
        "^install (?<name>\S*).*\s-arch\s*(?<arch>\S*)$" {
            DebugMessage "DnvmExpansion: install <name> -arch <arch>; name=$($matches['name']); arch=$($matches['arch'])"
            @('x86', 'x64') | filterMatches $matches['arch'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
        }
        # Handle dnvm install <name> [switches...] -r <runtime>
        "^install (?<name>\S*).*\s-r\s*(?<runtime>\S*)$" {
            DebugMessage "DnvmExpansion: install <name> -r <runtime>; name=$($matches['name']); runtime=$($matches['runtime'])"
            getRuntimes | filterMatches $matches['runtime'] 
        }
        # Handle dnvm install <name> [switches...] -a <alias>
        "^install (?<name>\S*).*\s-a\s*(?<alias>\S*)$" {
            DebugMessage "DnvmExpansion: install <name> -a <alias>; name=$($matches['name']); alias=$($matches['alias'])"
            getAliases | filterMatches $matches['alias'] 
        }

        ##########################################
        #
        # dnvm list

        # Handle dnvm list -<switch>
        "^list.*\s(?<switch>-\S*)$" {
            DebugMessage "DnvmExpansion: list -<switch>; switch=$($matches['switch'])"
            @('-PassThru') | filterMatches $matches['switch']
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
            @('x86', 'x64') | filterMatches $matches['arch'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
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
        # dnvm upgrade

        # Handle dnvm upgrade <alias>
        "^upgrade (?<alias>\S*)$" {
            DebugMessage "DnvmExpansion: upgrade <alias>; alias=$($matches['alias'])"
            getAliases | filterMatches $matches['alias'] 
        }
        # Handle dnvm upgrade <alias> [switches...] -<switch>
        "^upgrade ((?<alias>\S*)?.*\s)?(?<switch>-\S*)$" {
            DebugMessage "DnvmExpansion: upgrade <alias> -<switch>; alias=$($matches['alias']); switch=$($matches['switch'])"
            @('-arch', '-r', '-f', '-Proxy', '-NoNative', '-Ngen', '-Unstable') | filterMatches $matches['switch']
        }
        # Handle dnvm upgrade <alias> [switches...] -arch <arch>
        "^upgrade ((?<alias>\S*)?.*\s)?-arch\s*(?<arch>\S*)$" {
            DebugMessage "DnvmExpansion: upgrade <alias> -arch <arch>; alias=$($matches['alias']); arch=$($matches['arch'])"
            @('x86', 'x64') | filterMatches $matches['arch'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
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
            @('-arch', '-r', '-p') | filterMatches $matches['switch']
        }
        # Handle dnvm use <VersionOrAlias> [switches...] -arch <arch>
        "^use (?<name>\S*).*\s-arch\s*(?<arch>\S*)$" {
            DebugMessage "DnvmExpansion: use <name> -arch <arch>; name=$($matches['name']); arch=$($matches['arch'])"
            @('x86', 'x64') | filterMatches $matches['arch'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
        }
        # Handle dnvm use <VersionOrAlias> [switches...] -r <runtime>
        "^use (?<name>\S*).*\s-r\s*(?<runtime>\S*)$" {
            DebugMessage "DnvmExpansion: use <name> -r <runtime>; name=$($matches['name']); runtime=$($matches['runtime'])"
            getRuntimes | filterMatches $matches['runtime']
        }


        default {
            DebugMessage "DnvmExpansion - not handled: $cmd"
        }
    }
}

$commands = @('alias', 'exec', 'help', 'install', 'list', 'run', 'setup', 'update-self', 'upgrade', 'use');

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