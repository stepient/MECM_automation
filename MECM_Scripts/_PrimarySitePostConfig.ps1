#You need to configure SQL Reporting Services before running this script
param(
$SiteCode = "AUR",
$SiteSystemServerName = "CM01.dev.local",
$ReportingUserName = "DEV\MECM-SQLReporting",
$WSUSDir = "G:\Windows_Updates"
)

$CMDrive = $SiteCode + ":\"
$ModulePath = 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager\ConfigurationManager.psd1'
Import-Module $ModulePath
Set-Location $CMDrive
$ErrorActionPreference = "Stop"

Function Add-AURReportingServicePoint {
param(
    $ReportingPointParams = @{
        DatabaseName = "CM_AUR"
        FolderName = "ConfigMgr_AUR"
        ReportServerInstance = "SSRS"
        DatabaseServerName = "CM01.dev.local"
        Username = $ReportingUsername
        SiteCode = $SiteCode
        SiteSystemServerName = $SiteSystemServerName
        }
)

If (-not $(Get-CMAccount -UserName $ReportingUsername))
{
    $ReportingAccountCred = Get-Credential -UserName $ReportingUsername -Message "Type in the password for the $ReportingUsername account"
    New-CMAccount  -Password $ReportingAccountCred.Password -UserName $ReportingUsername
}
    Add-CMReportingServicePoint @ReportingPointParams #-SiteCode $SiteCode -SiteSystemServerName $SiteSystemServerName -DatabaseName $DatabaseName -FolderName $FolderName -ReportServerInstance $ReportServerInstance  -DatabaseServerName $DatabaseServerName -UserName $ReportingUsername

}

Add-AURReportingServicePoint

Add-CMFallbackStatusPoint -SiteCode $SiteCode -SiteSystemServerName $SiteSystemServerName

#Install-WindowsFeature -Name UpdateServices-Services,UpdateServices-DB -IncludeManagementTools #install WSUS
#Set-Location "C:\Program Files\Update Services\Tools"
#.\wsusutil.exe postinstall SQL_INSTANCE_NAME=$SiteSystemServerName CONTENT_DIR=$WSUSDir #configure WSUS

#Open SQL Management Studio
#Under Databases, Right-click SUSDB, select Properties and click Files
#Change Owner to SA
#Change the Autogrowth value to 512MB, click Ok and close SQL MS
#in IIS console change queue length to 10000
#adjust the private memory limit

Set-Location $CMDrive

#adjust the command for HTTPS-only communication
#possibly it's beeter to configure SUP from the console, 
#because there is no easy way to automate it with PowerShell
#and it is a one-off task
Add-CMSoftwareUpdatePoint -ClientConnectionType Intranet -SiteCode $SiteCode -SiteSystemServerName $SiteSystemServerName -WsusIisSslPort 8531 -WsusIisPort 8530

#you need  to configure SUP settings in site properties now