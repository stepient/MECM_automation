Get-Module WindowsServer
$Features=@(
    "Web-Windows-Auth",
    "Web-ISAPI-Ext",
    "Web-Metabase",
    "Web-WMI",
    "BITS",
    "RDC",
    "NET-Framework-Features", # -source \\yournetwork\yourshare\sxs",
    "Web-Asp-Net",
    "Web-Asp-Net45",
    "NET-HTTP-Activation",
    "NET-Non-HTTP-Activ",
    "UpdateServices-Ui"
)

$Features | Install-WindowsFeature