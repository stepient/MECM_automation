Function New-AURCMAccount {
    [CmdletBinding()]
    param(
    [Parameter(Mandatory=$true, 
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true)]
    $UserName
    )
    Process{
        Try{
            If (-not $(Get-CMAccount -UserName $UserName -ErrorAction Stop))
            {
                Write-Verbose "Creating account $UserName"
                $AccountCred = Get-Credential -UserName $Username -Message "Type in the password for the Username account"
                New-CMAccount  -Password $AccountCred.Password -UserName $Username -ErrorAction Stop
                Write-Verbose "Successfully created account $UserName"
            }
            else
            {
                Write-Verbose "Account $UserName already exists"
            }
        }
        Catch
        {
            throw $_
        }
    }
}