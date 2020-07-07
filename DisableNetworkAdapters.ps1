
<#
    Name: Disable Network Adapters
    Version: 1.0
    Description: Disables network adapters so that a host can be disconnected from the network should the need arise. 
    Functions:
        1. Set-PreviousAdapters: This function will check for network adapters that are currently enabled and will write them to a CSV file.
        2. Disconnect-Adapters: This function will disable all network adapters that were written to the CSV file generated by Set-PreviousAdapters.
        3. Connect-Adapters: This function will enable all network adapters that were written to the CSV file generated by Set-PreviousAdapters.

#>

<# Global Variables #>
$LogPath = "C:\temp\"
$OldAdapters ="C:\temp\NetAdaptersPreDisable.csv"

<# Functions #>

Function Set-PreviousAdapters{
    If(Test-Path $LogPath)
    {
        Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Select-Object -Property Name | Export-CSV C:\Temp\NetAdaptersPreDisable.csv -Force
    }
    else {
        New-Item $LogPath -type Directory | Out-Null
        Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Select-Object -Property Name | Export-CSV C:\Temp\NetAdaptersPreDisable.csv
    }
}

Function Disconnect-Adapters{
    If(Test-Path $OldAdapters)
    {
        $Adapters = Import-CSV -Path $OldAdapters
        ForEach ($Name in $Adapters)
        {
            Disable-NetAdapter -Name $Name.Name -Confirm:$False 
        }
    }
    Else
    {
        Write-Output "Please run the Set-PreviousAdapters function first..."
    }
}

Function Connect-Adapters{
    If(Test-Path $OldAdapters)
    {
        $Adapters = Import-CSV -Path $OldAdapters
        ForEach ($Name in $Adapters)
        {
            Enable-NetAdapter -Name $Name.Name -Confirm:$False 
        }
    }
    Else
    {
        Write-Output "Please run the Set-PreviousAdapters function first..."
    }
}

<# Script #>
### Gathers network adapters
Set-PreviousAdapters

### Disables network adapters
Disconnect-Adapters