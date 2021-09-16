
[CmdletBinding()]
param(
    $root = (Get-ADRootDSE).defaultNamingContext,
    $ADJoinAccount = "MECM-DomainJoin",
    $OUPath = "OU=Desktops,OU=Workstations,$root" #If the OU does not exist, it will be created
)

$OldErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Stop"
$OldVerbosePreference = $VerbosePreference
$VerbosePreference = "Continue"

$OUPathNoRoot = $OUPath -replace ",$Root"
#Import function
. "$PSScriptRoot\Functions\CreateADOURecurse.ps1"

CreateADOURecurse -OUPath $OUPath

Try{
    Write-Verbose "Granting permissions to the $ADJoinAccount account"
    
    $objUser = Get-ADUser -Filter "name -eq '$ADJoinAccount'"

    $objectComputerguid = new-object Guid bf967a86-0de6-11d0-a285-00aa003049e2
    $acl = get-acl "ad:$OUPath"
    
    #Create and delete computer objects in this object and all descendant objects          
    $ace1 = new-object System.DirectoryServices.ActiveDirectoryAccessRule $objUser.SID, "CreateChild, DeleteChild", "Allow", $objectComputerguid, "All"
    $acl.AddAccessRule($ace1)
    
    #Read All Properties, Write All Properties, Read Permissions, Modify Permissions on descendant computer objects  
    $objectExtendedRightGUID = new-object Guid bf967a86-0de6-11d0-a285-00aa003049e2
    $ace2 = new-object System.DirectoryServices.ActiveDirectoryAccessRule $objUser.SID, "ReadProperty, WriteProperty, ReadControl, WriteDacl", "Allow", "Descendents", $objectExtendedRightGUID
    $acl.AddAccessRule($ace2)
    
    #Reset password on descendant computer objects         
    $objectExtendedRightGUID2 = new-object Guid 00299570-246d-11d0-a768-00aa006e0529
    $ace3 = new-object System.DirectoryServices.ActiveDirectoryAccessRule $objUser.SID,"ExtendedRight", "Allow", $objectExtendedRightGUID2, "Descendents", $objectComputerguid
    $acl.AddAccessRule($ace3) 
    
    #Change password on descendant computer objects            
    $objectExtendedRightGUID3 = new-object Guid ab721a53-1e2f-11d0-9819-00aa0040529b
    $ace4 = new-object System.DirectoryServices.ActiveDirectoryAccessRule $objUser.SID,"ExtendedRight", "Allow", $objectExtendedRightGUID3, "Descendents", $objectComputerguid
    $acl.AddAccessRule($ace4) 
    
    #Validate Write to DNS hostname on descendant computer objects             
    $objectExtendedRightGUID4 = new-object Guid 72e39547-7b18-11d1-adef-00c04fd8d5cd
    $ace5 = new-object System.DirectoryServices.ActiveDirectoryAccessRule $objUser.SID,"Self", "Allow", $objectExtendedRightGUID4, "Descendents", $objectComputerguid
    $acl.AddAccessRule($ace5) 

    #Validate Write to Service Principal on descendant computer objects  
    $objectExtendedRightGUID5 = new-object Guid f3a64788-5306-11d1-a9c5-0000f80367c1
    $ace6 = new-object System.DirectoryServices.ActiveDirectoryAccessRule $objUser.SID,"Self", "Allow", $objectExtendedRightGUID5, "Descendents", $objectComputerguid
    $acl.AddAccessRule($ace6)
                
    Set-acl -aclobject $acl "ad:$OUPath"            
    Write-Verbose -Message "Successfully granted permissions to the $ADJoinAccount account"
}
Catch
{
    $ErrorActionPreference = $OldErrorActionPreference
    $VerbosePreference = $OldVerbosePreference
    throw $_
}
