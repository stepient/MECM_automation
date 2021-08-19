[CmdletBinding()]
param(
    $MECMServersADGroup = "MECM-Servers"
)

$OldVerbosePreference = $VerbosePreference
$VerbosePreference = "Continue"

$root = (Get-ADRootDSE).defaultNamingContext
        $arrOU = ($ouParent + ',' + $OUGroup).split(',')    
        $objOU = ''
        foreach ($ou in $arrOU)
        { 
            if ($objOU -ne '') { $objOU = ',' + $objOU }
            $objOU = "OU=$ou" + $objOU
        }
        
        $objOU += ",$root"

        
        if (!([adsi]::Exists("LDAP://CN=System Management,CN=System,$root")))
        {
            Write-Verbose -Message "Creating object CN=System Management,CN=System,$root"
            try
            {
                $smcontainer = New-ADObject -Type Container -name "System Management" -Path "CN=System,$root" -Passthru         
            }
            catch
            {
                throw $_        
            }
            Write-Verbose -Message "Successfully created object CN=System Management,CN=System,$root"
        }
        else
        {
            Write-Verbose -Message "Object CN=System Management,CN=System,$root already exists"
        }

        Write-Verbose -Message "Setting permissions for object CN=System Management,CN=System,$root"
        $acl = get-acl "ad:CN=System Management,CN=System,$root"

        $objGroup = Get-ADGroup -filter {Name -eq $MECMServersADGroup}
        if ($objGroup -eq $null)
        {
            Write-Verbose -Message "Unable to find group $MECMServersADGroup"
        }
        else
        {
            $All = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::SelfAndChildren
            
            $ace = new-object System.DirectoryServices.ActiveDirectoryAccessRule $objGroup.SID, "GenericAll", "Allow", $All

            $acl.AddAccessRule($ace) 
            Set-acl -aclobject $acl "ad:CN=System Management,CN=System,$root"
            Write-Verbose -Message "Permissions on container System Management sucessfully granted to group $MECMServersADGroup"
        }

$VerbosePreference = $OldVerbosePreference