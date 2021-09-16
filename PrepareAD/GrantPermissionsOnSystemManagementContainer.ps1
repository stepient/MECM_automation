[CmdletBinding()]
param(
    $MECMSiteServer = "CM01"
)

$OldVerbosePreference = $VerbosePreference
$VerbosePreference = "Continue"

$root = (Get-ADRootDSE).defaultNamingContext

Write-Verbose -Message "Setting permissions for object CN=System Management,CN=System,$root"
$acl = get-acl "ad:CN=System Management,CN=System,$root"

Try{
    $ComputerObj = Get-ADComputer $MECMSiteServer
    if ($ComputerObj -eq $null)
    {
        Write-Verbose -Message "Unable to find computer $MECMSiteServer"
    }
    else
    {
        $All = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::SelfAndChildren
            
        $ace = new-object System.DirectoryServices.ActiveDirectoryAccessRule $ComputerObj.SID, "GenericAll", "Allow", $All

        $acl.AddAccessRule($ace) 
        Set-acl -aclobject $acl "ad:CN=System Management,CN=System,$root"
        Write-Verbose -Message "Permissions on the SYSTEM container sucessfully granted to computer account $MECMSiteServer"
    }
}
Catch
{
    throw $_
}

$VerbosePreference = $OldVerbosePreference
