Function CreateADUser {
    [CmdletBinding()]
    param(
        [CmdletBinding()]
        [string]$Username,
        $Password,
        [string]$OUPath
    )
   <# 
    $UserObj = Get-ADUser -Filter "name -eq '$UserName'" -ErrorAction SilentlyContinue
    Write-Verbose -Message "Creating AD user $UserName in OU $OUPath"
    if ($UserObj -eq $null)
    {
        New-ADUser -Name $UserName -AccountPassword $Password -CannotChangePassword $true -ChangePasswordAtLogon $false -PasswordNeverExpires $true -Path $OUPath -enabled $true
        Write-Verbose "Successfully created AD User $UserName in OU $OUPath"
    }
    else
    {
        Write-Verbose -Message ("User account $UserName already exists")
        Try{
            Write-Verbose "Moving $Username to $OUPath"
            $UserObj | Move-ADObject -TargetPath $OUPath -ErrorAction Stop
        }
        Catch{
            throw $_
        }
    } 
    #>
    Write-Verbose -Message "Creating AD User $UserName in OU $OUPath"

    Try{
        $UserObj = Get-ADUser $UserName -ErrorAction Stop
        Write-Verbose -Message ("User account $UserName already exists")
        If ($UserObj.DistinguishedName -ne "CN=$UserName,$OUPath")
        {
        Try{
            Write-Verbose "Moving $Username to $OUPath"
            $UserObj | Move-ADObject -TargetPath $OUPath -ErrorAction Stop
            Write-Verbose "Successfully moved $Username to $OUPath"
            }
            Catch{
                throw $_
            }
        }
        else
        {
            Write-Verbose "User $UserName is already in the OU $OUPath"
        }
    }
    Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
        New-ADUser -Name $UserName -AccountPassword $Password -CannotChangePassword $true -ChangePasswordAtLogon $false -PasswordNeverExpires $true -Path $OUPath -enabled $true
        Write-Verbose "Successfully created AD User $UserName in OU $OUPath"
    }
    Catch{
        throw $_
    }    
}