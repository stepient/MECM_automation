Function CreateADComputer {
    param(
        [Parameter(Mandatory)]
        $ComputerName,
        [Parameter(Mandatory)]
        $OUPath
    )
Try{
    Write-Verbose "Creating computer account $ComputerName in the $OUPath OU "
    New-ADComputer $ComputerName -Path $ServersOUPath
    }
    Catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException]
    {
        Write-Verbose $_.Exception.Message
    }
    Catch
    {
        throw $_
    }
}