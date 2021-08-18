Function CreateADOU
{
    [CmdletBinding()]
    param(

    [Parameter(Mandatory)]
    $Name,
    $ParentOUPath
      )

    $Root = (Get-ADRootDSE).defaultNamingContext    
    if ([System.String]::IsNullOrEmpty($ParentOUPath)) 
    { 
        $ParentOUPath = $root 
    }

    $objOU = "OU=$Name,$ParentOUPath"
    $objOUFilter = $objOU -replace ',,', ','

    Write-Verbose -Message "Creating OU $objOU"
        if (-not([adsi]::Exists("LDAP://$objOUFilter")))
        {
            try
            {
                New-ADOrganizationalUnit -Name $Name -path $ParentOUPath #-ProtectedFromAccidentalDeletion $false #for development only
            }
            catch
            {
                throw $_
            }
            Write-Verbose -Message "OU $objOU created successfully"
            #[pscustomobject]@{OUPath=$objOU}
        }
        else
        {
            Write-Verbose -Message "OU $objOU already exists"
            #[pscustomobject]@{OUPath=$objOU}
        }
}