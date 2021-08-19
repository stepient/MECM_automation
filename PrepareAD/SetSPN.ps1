[CmdletBinding()]
param(
    $DomainName = (Get-ADDomain).DnsRoot,
    $SQLServiceAccount = "MECM-SQLService",
    $DBServer = "CM01",
    $PortNumber = 1433  
)

$OldVerbosePreference = $VerbosePreference
$VerbosePreference = "Continue"
$DomainNameShort = ($DomainName -split "\.")[0]

$DBServerFQDN = $DBServer + "." + $DomainName
Write-Verbose "Running command: setspn -A MSSQLSvc/$DBServer`:$PortName $DomainNameShort\$SQLServiceAccount"
$out1 = setspn -A MSSQLSvc/$DBServer`:$PortName $SQLServiceAccount
Write-Verbose $out1[-1]
Write-Verbose "Running command: setspn -A MSSQLSvc/$DBServerFQDN`:$PortName $SQLServiceAccount"
$out2 = setspn -A MSSQLSvc/$DBServerFQDN`:$PortName $SQLServiceAccount
Write-Verbose $out2[-1]

$VerbosePreference = $OldVerbosePreference
