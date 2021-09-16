Function CreateADOURecurse {

param(
    [Parameter(Mandatory)]
    $OUPath
)
    #Import function
    . "$PSScriptRoot\CreateADOU.ps1"

    $OUSplit = $OUPath -split ","
    $OUNames = ($OUSplit -like "OU=*") -replace "OU="
    [array]::Reverse($OUNames)

    $ParamsArray = @()

    Foreach ($OUName in $OUNames)
    {
        [int]$index = [array]::IndexOf($OUNames,$OUName)
        If ($index -eq 0){
            $ParentOuPath = $root
        }
        else
        {
            $ParentOuPath = "OU=" + $ParamsArray[$index-1].Name + "," + $ParamsArray[$index-1].ParentOuPath
        }
        $params = @{
            Name = $OUName
            ParentOuPath = "$ParentOuPath"
        }
        $ParamsArray+=$params
        CreateADOU @params
    }
}
