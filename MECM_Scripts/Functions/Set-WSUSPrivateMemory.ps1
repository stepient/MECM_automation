#Requires -Modules WebAdministration
Function Set-WSUSPrivateMemory
{
    [CmdletBinding()]
    param(
        [int]$WSUSMemoryLimit = 1000
        )
    
    $WSUSPool = Get-ItemProperty IIS:\AppPools\WsusPool
    [int]$CurrentMemoryLimit = $WSUSPool.recycling.periodicRestart.privateMemory
    Write-Verbose "Setting WSUS private memory limit to $WSUSMemoryLimit"
    If ($CurrentMemoryLimit -ne $WSUSMemoryLimit)
    {
        Try{
            Set-ItemProperty -Path $WSUSPool.PSPath -Name recycling.periodicrestart.privateMemory -Value $WSUSMemoryLimit
            $WSUSPool = Get-ItemProperty IIS:\AppPools\WsusPool
            $NewMemoryLimit = $WSUSPool.recycling.periodicRestart.privateMemory
            If ($NewMemoryLimit -eq $WSUSMemoryLimit)
            {
                $out = [pscustomobject]@{MemoryLimit = $NewMemoryLimit}
            }
            Write-Verbose "Successfully set WSUS private memory limit to $WSUSMemoryLimit"
        }
        Catch 
        {
            throw $_
        }
    }
    else
    {
        Write-Verbose "WSUS private memory limit is already set to to $WSUSMemoryLimit"
        $out = [pscustomobject]@{MemoryLimit = $CurrentMemoryLimit}
    }

    #$out
}
