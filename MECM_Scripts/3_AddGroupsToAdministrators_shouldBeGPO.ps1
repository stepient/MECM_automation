#this should be done with a GPO
$Domain = "test"
$Groups = "MECM-Admins", "MECM-SiteServers"

$Groups | ForEach-Object { Add-LocalGroupMember -Group "Administrators" -Member "$Domain\$_"}
Add-LocalGroupMember -Group "Administrators" -Member "CM01$"
