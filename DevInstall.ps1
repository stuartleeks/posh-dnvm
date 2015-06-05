# clean choco cache
dir $env:ProgramData\chocolatey\lib\posh-dnvm* | Remove-Item -Recurse -Force
# install choco package from local dir
choco install posh-dnvm -source "$pwd" -pre -force