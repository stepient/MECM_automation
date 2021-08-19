$Directories = @(
    "D:\Program Files", 
    "D:\Program Files (x86)",
    "E:\SQL_Database",
    "F:\Temp_DB",
    "G:\SQL_Logs",
    "G:\SQL_Backup"
    )
$Directories | ForEach-Object {
    If (-not (Test-Path "$_")) # couldn't use try catch, beacause System.IO.IOException also handles other error types 
        {
            New-Item -Path $_ -ItemType Directory
        } 
        else{
            "The directory $_ already exists" 
        }
}