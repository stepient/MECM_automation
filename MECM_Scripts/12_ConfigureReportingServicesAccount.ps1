# Source: https://argonsys.com/microsoft-cloud/library/install-configmgr-cb-1902-using-powershell/

param(
$serviceAccount = "dev\MECM-SQLReporting",
$useBuiltInServiceAccount = $false
)

$Credential = Get-Credential -UserName $serviceAccount -Message "Type in the password for the $serviceAccount account"
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
$strPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

$ns = "root\Microsoft\SqlServer\ReportServer\RS_SSRS\v15\Admin"
$RSObject = Get-WmiObject -class "MSReportServer_ConfigurationSetting" -namespace "$ns"
$RSObject.SetWindowsServiceIdentity($useBuiltInServiceAccount, $serviceAccount, $strPassword) | out-null

# Need to reset the URLs for domain service account to work
$HTTPport = 80
$RSObject.RemoveURL("ReportServerWebService", "http://+:$HTTPport", 1033) | out-null
$RSObject.RemoveURL("ReportServerWebApp", "http://+:$HTTPport", 1033) | out-null
$RSObject.SetVirtualDirectory("ReportServerWebService", "ReportServer", 1033) | out-null
$RSObject.SetVirtualDirectory("ReportServerWebApp", "Reports", 1033) | out-null
$RSObject.ReserveURL("ReportServerWebService", "http://+:$HTTPport", 1033) | out-null
$RSObject.ReserveURL("ReportServerWebApp", "http://+:$HTTPport", 1033) | out-null

# Restart SSRS service for changes to take effect
$serviceName = $RSObject.ServiceName
Restart-Service -Name $serviceName -Force

Restart-Computer