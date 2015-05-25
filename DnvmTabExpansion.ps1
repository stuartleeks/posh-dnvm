function DebugMessage($message){
    [System.Diagnostics.Debug]::WriteLine("PoshDnvm:$message")
}
function DnvmTabExpansion($lastBlock) {

    DebugMessage "DnvmExpansion: $lastBlock"
    $cmd = $lastBlock -replace "^dnvm\s*", ""
    switch -Regex ($cmd) {
    
        # Handle dnvm <cmd>
        "^(?<cmd>\S*)$" {
            dnvmCommands $matches['cmd']
        }

        # Handle dnvm help <cmd>
        "^help (?<cmd>\S*)$" {
            dnvmCommands $matches['cmd'] | ?{$_ -ne 'help'}
        }

        # Handle dnvm alias -d <name>
        "^alias -d (?<name>\S*)$" {
            dnvmAliases $matches['name']
        }



    }
}

$commands = @('alias', 'help', 'install', 'list', 'name', 'setup', 'upgrade', 'use');

function dnvmCommands($filter) {
  DebugMessage "dnvmCommands: $filter"

  if($filter) {
     $commands | ? { $_.StartsWith($filter) } | sort  
  }
  else {
    $commands | % { $_.Trim() } | sort
  }
}

function dnvmAliases($filter) {
  DebugMessage "dnvmAliases: $filter"

  if($filter) {
     getAliases | ? { $_.StartsWith($filter) } | sort  
  }
  else {
    getAliases | % { $_.Trim() } | sort
  }
}

function getAliases(){
    dnvm list -PassThru | ?{$_.Alias -ne ""} | %{$_.Alias}
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