#Requires -Modules WebAdministration
Function Set-WSUSPoolQueueLength
{
    [CmdletBinding()]
    param(
        $WSUSQueueLength = 5000
        )

    $WSUSPool = Get-ItemProperty IIS:\AppPools\WsusPool
    $CurrentQueueLength = (Get-ItemProperty IIS:\AppPools\WsusPool\).queueLength

    Write-Verbose "Setting WSUS pool queue length to $WSUSQueueLength"
    If ($CurrentQueueLength -ne $WSUSQueueLength)
    {
        Try{
            Set-ItemProperty -Path $WSUSPool.PSPath -Name queueLength -Value $WSUSQueueLength
            $NewQueueLength = (Get-ItemProperty IIS:\AppPools\WsusPool\).queueLength
            If ($NewQueueLength -eq $WSUSQueueLength)
            {
                $out = [pscustomobject]@{QueueLength = $NewQueueLength}
            }
            Write-Verbose "Successfully set WSUS pool queue length to $WSUSQueueLength"
        }
        Catch 
        {
            throw $_
        }
    }
    else
    {
        Write-Verbose "WSUS pool queue length is already set to $WSUSQueueLength"
        $out = [pscustomobject]@{QueueLength = $CurrentQueueLength}
    }

    #$out
}
