Function CreateADUser {
    [CmdletBinding()]
    param(
        [CmdletBinding()]
        [string]$Username,
        $Password,
        [string]$OUPath
    )
    
    $users = Get-ADUser -Filter "name -eq '$UserName'" 
    Write-Verbose -Message "Creating AD user $UserName"
    if ($users -eq $null)
    {
        New-ADUser -Name $UserName -AccountPassword $Password -CannotChangePassword $true -ChangePasswordAtLogon $false -PasswordNeverExpires $true -Path $OUPath -enabled $true
        Write-Verbose -Message ("Successfully created AD User $UserName")
    }
    else
    {
        Write-Verbose -Message ("User account $UserName already exists")
    }    
}