param(
    $SiteSystemServerFQDN = "CM01.dev.local",
    $WSUSDir = "D:\WSUS Content",
    [int]$WSUSHTTPPort = 8530,
    [int]$WSUSHTTPSPort = 8531,
    [int]$WSUSQueueLength = 5000,
    [int]$WSUSMemoryLimit = 1000
)

$OldErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Stop"
Try{

#Import functions
. "$PSScriptRoot\Functions\Set-WSUSPoolQueueLength.ps1"
. "$PSScriptRoot\Functions\Set-WSUSPrivateMemory.ps1"

$Rules = @(
                @{
                    DisplayName = "WSUS HTTP"
                    Direction = "Inbound"
                    Action = "Allow"
                    Protocol = "TCP"
                    LocalPort = $WSUSHTTPPort
                }

                @{
                    DisplayName = "WSUS HTTPS"
                    Direction = "Inbound"
                    Action = "Allow"
                    Protocol = "TCP"
                    LocalPort = $WSUSHTTPSPort
                }
)

$FWRules = Get-NetFirewallRule

Foreach ($Rule in $Rules)
{
    
    If ($FWRules.DisplayName -notcontains $Rule.DisplayName)
    {
        New-NetFirewallRule @Rule
    }
    else
    {
        Write-Output "Firewall rule `"$($Rule.DisplayName)`" already exists"
    }
}

#netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol=icmpv4:8,any dir=in action=allow

powershell -executionpolicy bypass -file $PSScriptRoot\2_NoSMSOnDrive.ps1

If (-not (Test-Path "$WSUSDir")) # couldn't use try catch, beacause System.IO.IOException also handles other error types 
    {
        New-Item -Path $WSUSDir -ItemType Directory
    } 
    else{
        "The directory $WSUSDir already exists" 
    }

#Install-WindowsFeature -Name UpdateServices-Services,UpdateServices-DB -IncludeManagementTools #install WSUS
Set-Location "C:\Program Files\Update Services\Tools"
.\wsusutil.exe postinstall SQL_INSTANCE_NAME=$SiteSystemServerFQDN CONTENT_DIR=$WSUSDir #configure WSUS

Import-Module WebAdministration

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