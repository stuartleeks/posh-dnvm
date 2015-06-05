$packageName = 'posh-dnvm'
$sourcePath = Split-Path -Parent $MyInvocation.MyCommand.Definition

$targetPath = Join-Path ([System.Environment]::GetFolderPath("MyDocuments")) "WindowsPowerShell\Modules\posh-dnvm"

if(Test-Path $targetPath){
    Write-Host "Remove previous module folder"
    Remove-Item -Path $targetPath -Recurse -Force | out-null
}
New-Item -ItemType Directory -Path $targetPath | out-null

Copy-Item "$sourcePath\*" $targetPath | out-null