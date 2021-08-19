Function CreateADComputer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $ComputerName,
        [Parameter(Mandatory)]
        $OUPath
    )

    Write-Verbose -Message "Creating AD Computer $ComputerName in OU $OUPath"

    Try{
        $ComputerObj = Get-ADComputer $ComputerName -ErrorAction Stop
        Write-Verbose -Message ("Computer account $ComputerName already exists")
        If ($ComputerObj.DistinguishedName -ne "CN=$ComputerName,$OUPath")
        {
        Try{
            Write-Verbose "Moving $Computername to $OUPath"
            $ComputerObj | Move-ADObject -TargetPath $OUPath -ErrorAction Stop
            Write-Verbose "Successfully moved $Computername to $OUPath"
            }
            Catch{
                throw $_
            }
        }
        else
        {
            Write-Verbose "Computer $ComputerName is already in the OU $OUPath"
        }
    }
    Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
        New-ADComputer -Name $ComputerName -AccountPassword $Password -CannotChangePassword $true -ChangePasswordAtLogon $false -PasswordNeverExpires $true -Path $OUPath -enabled $true
        Write-Verbose "Successfully created AD computer $ComputerName in OU $OUPath"
    }
    Catch{
        throw $_
    } 
}