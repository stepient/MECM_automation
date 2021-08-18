[CmdletBinding()]
param(
    $DomainName = "dev.local",
    $SQLServiceAccount = "dev\MECM-SQLService",
    $DBServer = "CM01",
    $PortName = 1433  
)

$DBServerFQDN = $DBServer + "." + $DomainName
Write-Verbose "Running command: setspn -A MSSQLSvc/$DBServer`:$PortName $SQLServiceAccount"
$out1 = setspn -A MSSQLSvc/$DBServer`:$PortName $SQLServiceAccount
Write-Verbose $out1[-1]
Write-Verbose "Running command: setspn -A MSSQLSvc/$DBServerFQDN`:$PortName $SQLServiceAccount"
$out2 = setspn -A MSSQLSvc/$DBServerFQDN`:$PortName $SQLServiceAccount
Write-Verbose $out2[-1]
