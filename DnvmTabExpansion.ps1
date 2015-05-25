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
        "^alias (?<name>\S*)\s+(?<version>\S*)$" {
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
            @('clr', 'coreclr') | filterMatches $matches['runtime'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $runtime parameters)
        }
        

        ##########################################
        #
        # TODO: dnvm install



        ##########################################
        #
        # TODO: dnvm list



        ##########################################
        #
        # TODO: dnvm name



        ##########################################
        #
        # TODO: dnvm setup 



        ##########################################
        #
        # TODO: dnvm upgrade



        ##########################################
        #
        # TODO: dnvm use

        # Handle dnvm use<name>
        "^use (?<name>\S*)$" {
            DebugMessage "DnvmExpansion: use <name>; name=$($matches['name'])"
            getAliasesAndVersions | filterMatches $matches['name']
        }
        # Handle dnvm use <name> [switches...] -<switch>
        "^use (?<name>\S*).*\s(?<switch>-\S*)$" {
            DebugMessage "DnvmExpansion: use <name> -<switch>; name=$($matches['name']); switch=$($matches['switch'])"
            @('-arch', '-r', '-p') | filterMatches $matches['switch']
        }
        # Handle dnvm use <name> [switches...] -arch <arch>
        "^use (?<name>\S*).*\s-arch\s*(?<arch>\S*)$" {
            DebugMessage "DnvmExpansion: use <name> -arch <arch>; name=$($matches['name']); arch=$($matches['arch'])"
            @('x86', 'x64') | filterMatches $matches['arch'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $architecture parameters)
        }
        # Handle dnvm use <name> [switches...] -r <runtime>
        "^use (?<name>\S*).*\s-r\s*(?<runtime>\S*)$" {
            DebugMessage "DnvmExpansion: use <name> -r <runtime>; name=$($matches['name']); runtime=$($matches['runtime'])"
            @('clr', 'coreclr') | filterMatches $matches['runtime'] # values taken from inspecting dnvm.ps1 (look for ValidateSet on $runtime parameters)
        }


        default {
            DebugMessage "DnvmExpansion - not handled: $cmd"
        }
    }
}

$commands = @('alias', 'help', 'install', 'list', 'name', 'setup', 'upgrade', 'use');

function filterMatches($filter){
  if($filter) {
     $input| ? { $_.StartsWith($filter) } | sort  
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

# TODO - look at posh-git/posh-hg to link with powertab

if(-not (Test-Path Function:\DnvmTabExpansionBackup)){

    if (Test-Path Function:\TabExpansion) {
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