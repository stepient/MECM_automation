﻿param(
    $SiteSystemServerFQDN = "CM01.dev.local",
    $WSUSDir = "D:\WSUS Content",
    [int]$WSUSQueueLength = 5000,
    [int]$WSUSMemoryLimit = 1000
)

$OldErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Stop"

Try{
    
    Push-Location
    Set-Location "C:\Program Files\Update Services\Tools"
    .\wsusutil.exe postinstall SQL_INSTANCE_NAME=$SiteSystemServerFQDN CONTENT_DIR=$WSUSDir #configure WSUS
    Pop-Location

    Install-Module WebAdministration

    #Import functions
    . "$PSScriptRoot\Functions\Set-WSUSPoolQueueLength.ps1"
    . "$PSScriptRoot\Functions\Set-WSUSPrivateMemory.ps1"

    Set-WSUSPoolQueueLength -WSUSQueueLength $WSUSQueueLength -Verbose

    Set-WSUSPrivateMemory -WSUSMemoryLimit $WSUSMemoryLimit -Verbose

    #Open SQL Management Studio
    #Under Databases, Right-click SUSDB, select Properties and click Files
    #Change Owner to SA
    #Change the Autogrowth value to 512MB, click Ok and close SQL MS
    #in IIS console change queue length to 10000
    #adjust the private memory limit
}
Finally
{
    $ErrorActionPreference = $OldErrorActionPreference
}