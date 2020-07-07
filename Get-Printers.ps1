<#
.SYNOPSIS
  This script is used to pull a list of machines from a .csv file with the header Computer.
.DESCRIPTION
  Pulls printer info from Windows machines using WMI. 

  Please note: Powershell 7.0 does not work with this script, Get-WmiObject was removed in 7.0
.INPUTS
  PrintServer: This variable will store the contents of a .csv file as an array. The .csv should have Computer as the column header. -Path should be set to the path of the .csv file. 
.OUTPUTS
  Outputs a .csv file for each machine and then combines them into a file named combined.csv. 
.NOTES
  Version:        1.0
  Author:         Daniel Hayes
  Creation Date:  07/07/2020
  Purpose/Change: Initial script development
  
.NOTES
  The combined.csv output may contain PCs names, you will want to remove these as they are not input corrrectly. This was found in testing of the script, I found it easier to remove those computer names for the task at hand manually. 
#>

$printserver = Import-CSV -Path "C:\Temp\CSComputers.csv" #Edit for a different path. 

#This will go through the Array for $printserver and create the .csv files for each machine. The switch -NoTypeInformation is used for a cleaner csv file. 
ForEach ($Computer in $printserver){
    Write-Output "Testing on " $Computer.Computer
    $filepath = 'C:\temp\printers_' + $Computer.Computer + '.csv'
    Get-WmiObject -class Win32_Printer -computer $Computer.Computer | Select Name,DriverName,PortName | Export-CSV -path $filepath -NoTypeInformation 
}

#This will go through and combine all of the CSV files into one. 
$getFirstLine = $true

get-childItem "C:\Temp\*.csv" | foreach {
    $filePath = $_

    $lines =  $lines = Get-Content $filePath  
    $linesToWrite = switch($getFirstLine) {
           $true  {$lines}
           $false {$lines | Select -Skip 1}

    }

    $getFirstLine = $false
    Add-Content "C:\Temp\combined.csv" $linesToWrite
    }