# posh-dnvm
Provides tab completion for dnvm commands in PowerShell

Inspired by [posh-git](https://github.com/dahlbyk/posh-git)


## Installation etc
Ensure that you have [chocoloatey](https://chocolatey.org/) installed.


To install milestone drops (note these are still 'pre-release' as the version matches dnx versioning which is pre-release):

```
    choco install posh-dnvm -pre
```

There is also a [non-milestone feed](https://www.myget.org/F/posh-dnvm/api/v2) now up on MyGet. 
To install these interim drops use:

```
    choco install posh-dnvm -source 'https://www.myget.org/F/posh-dnvm/api/v2' -pre
```