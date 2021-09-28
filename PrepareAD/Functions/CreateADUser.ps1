Function CreateADUser {
    [CmdletBinding()]
    param(
        [CmdletBinding()]
        [string]$Username,
        $Password,
        [string]$OUPath
    )

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
        New-ADUser -Name $UserName -AccountPassword $Password -ChangePasswordAtLogon $false -PasswordNeverExpires $true -Path $OUPath -enabled $true
        Write-Verbose "Successfully created AD User $UserName in OU $OUPath"
    }
    Catch{
        throw $_
    }    
}
