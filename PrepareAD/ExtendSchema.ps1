#[CmdletBinding()] $PSScriptroot doesn't get expanded if used in the param block together with cmdletbinding
param(
    $extadschPath = "$PSScriptRoot\BIN\X64"
    )
$OldVerbosePreference = $VerbosePreference
$VerbosePreference = "Continue"
Push-Location
Try{
    Set-Location $extadschPath
    Write-Verbose "Extending Active Directory schema"
    .\extadsch.exe | Out-Null
    $LogContent = Get-Content C:\ExtADSch.log
    If (-not $LogContent)
    {
        throw "Failed to extend Active Directory schema. No log created."
    }
    If ($LogContent -like "*Failed to extend the Active Directory schema*")
    {
        throw "Failed to extend the Active Directory schema. Please find details in `"C:\ExtADSch.log`""
    }
    else
    {
        Write-Verbose "Successfully extended the Active Directory schema."
    }
}
Catch
{
    throw $_
}

$VerbosePreference = $OldVerbosePreference
Pop-Location