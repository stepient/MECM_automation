#You need to configure SQL Reporting Services before running this script
param(
$SiteCode = "AUR",
$SiteSystemServerName = "CM01.dev.local",
$ReportingUserName = "DEV\MECM-SQLReporting"
)

#
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
#
# This script was auto-generated at '8/30/2021 11:33:13 AM'.

# Uncomment the line below if running in an environment where script signing is 
# required.
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Site configuration
$SiteCode = "AUR" # Site code 
$ProviderMachineName = "CM01.dev.local" # SMS Provider machine name

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Do not change anything below this line

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

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



#you need  to configure SUP settings in site properties now