$packageName = 'posh-dnvm'
$sourcePath = Split-Path -Parent $MyInvocation.MyCommand.Definition

$targetPath = Join-Path ([System.Environment]::GetFolderPath("MyDocuments")) "WindowsPowerShell\Modules\posh-dnvm"

if(Test-Path $targetPath){
    Remove-Item -Path $targetPath -Recurse -Force
}