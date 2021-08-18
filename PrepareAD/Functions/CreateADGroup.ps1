Function CreateADGroup
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $GroupName,
        [Parameter(Mandatory)]
        $OU,
		$Universal = $false
    )
    
    Try{
        Write-Verbose "Creating AD group $GroupName"
        $ADGroup = Get-ADGroup $GroupName
        Write-Verbose -Message "AD group $GroupName already exists"
    }
    Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
    {
        try
        {
			if ($Universal)
			{ 
                New-ADGroup -Name $GroupName -Path $OU -groupScope Universal }
			else
			{ New-ADGroup -Name $GroupName -Path $OU -groupScope Global }
        }
        catch
        {
            throw $_
        }
       Write-Verbose -Message "Successfully created AD group $GroupName"
    }
}