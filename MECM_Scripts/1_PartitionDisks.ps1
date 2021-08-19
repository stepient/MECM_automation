
# This script partitions the disk and creates volumes in preparation for MECM installation
# Author: Tomasz Stepien
# Email: tomasz.stepien@capgemini.com
# Requires -RunAsAdministrator

param(

$CMDriveLetter = "D",
$CMDriveSize = 100GB, #adjust in production
$CMFileSystemLabel = "CM",

$DBDriveLetter = "E",
$DBDriveSize = 40GB,
$DBFileSystemLabel = "SQL DB",

$TempDBDriveLetter = "F",
$TempDBDriveSize = 40GB,
$TempDBFileSystemLabel = "SQL Temp DB",

$DBLogsDriveLetter = "G",
$DBLogsDriveSize = 40GB,
$DBLogsFileSystemLabel = "SQL Logs",

$DiskNumber = 1

)

$CMAllocationUnitSize = 4096 #do not modify this value
$DBAllocationUnitSize = 65536 #do not modify this value

$Disks = @(
                @{
                    DiskNumber = $DiskNumber
                    DriveLetter = $CMDriveLetter
                    Size = $CMDriveSize 
                    FileSystemLabel = $CMFileSystemLabel
                    AllocationUnitSize = $CMAllocationUnitSize
                }

                @{
                    DiskNumber = $DiskNumber
                    DriveLetter = $DBDriveLetter
                    Size = $DBDriveSize
                    FileSystemLabel = $DBFileSystemLabel
                    AllocationUnitSize = $DBAllocationUnitSize
                }

                @{
                    DiskNumber = $DiskNumber
                    DriveLetter = $TempDBDriveLetter
                    Size = $TempDBDriveSize
                    FileSystemLabel = $TempDBFileSystemLabel
                    AllocationUnitSize = $DBAllocationUnitSize
                }

                @{
                    DiskNumber = $DiskNumber
                    DriveLetter = $DBLogsDriveLetter
                    Size = $DBLogsDriveSize
                    FileSystemLabel = $DBLogsFileSystemLabel
                    AllocationUnitSize = $DBAllocationUnitSize
                }

)


Get-Disk -Number $DiskNumber | Clear-Disk -RemoveData -Confirm:$false
Get-Disk -Number $DiskNumber | Initialize-Disk -PartitionStyle GPT #-PassThru 

Function New-CMPartition  {
    [CmdletBinding()]
    param(
            [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
            [int]$DiskNumber,
            [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
            [string]$DriveLetter,
            [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
            $Size,
            $FileSystem="NTFS",
            [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
            $FileSystemLabel,
            [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
            [int]$AllocationUnitSize
    )
    Process{
        New-Partition -DiskNumber $DiskNumber -Size $Size -DriveLetter $DriveLetter | 
        Format-Volume -FileSystem $FileSystem -NewFileSystemLabel $FileSystemLabel -AllocationUnitSize $AllocationUnitSize
    }
}

$Disks| ForEach-Object {New-CMPartition @_}
