$MECMDrive = "D"
$volumes = Get-Volume
$volumes.DriveLetter | Where-Object {$_ -ne $MECMDrive} | ForEach-Object {
    If (-not (Test-Path "$($_):\no_sms_on_drive.sms")) # couldn't use try catch, beacause System.IO.IOException also handles other error types 
    {
        New-Item -Path "$($_):\" -Name no_sms_on_drive.sms -ItemType File
    } 
    else{
        "The file $($_):\no_sms_on_drive.sms already exists" 
    }
}
