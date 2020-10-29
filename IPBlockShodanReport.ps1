<#
.SYNOPSIS
    Checks external IPs for known vulnerabilities via the ShodanAPI. 

.DESCRIPTION
    Checks external IPs for known vulnerabilities via the ShodanAPI. 

    This script is a modified version of the Automate API/Shodan API vulnerability check from https://www.gavsto.com/one-script-to-get-an-overview-of-all-your-clients-open-ports-and-cve-vulnerabilities-using-powershell-connectwise-automate-and-shodans-free-api/

.INPUTS
    No inputs.
.OUTPUTS Log File
    Outputs .csv file containing vulnerabilities that were found via the Shodan API for the IPs specified in the IP csv file to location specified by user at the end of the script. 
.NOTES
  Version:        1.0
  Author:         Daniel Hayes
  Creation Date:  10/29/2020
  Purpose/Change: Initial script development; Removed AutomateAPI functionality.
.EXAMPLE
  .\IPBlockShodanReport.ps1
#>

#----------User Variables-----------------
$ShodanAPIKey = "<API KEY>" #Input your Shodan.io API key here.  
$OpenPortsAreErrors = $False
#----------End User Variables-------------


$FinalArray = @()

$AllResults = Import-CSV -Path "C:\Temp\IPs.csv" #Modify this to be the location of the IPs csv file. File should be in comma delimited format and the header should be IP.
$Test = $AllResults | Sort-Object -Property @{e={$_.IP}} | Group-Object -Property IP | ? {$_.Count -gt 0}

foreach ($IP in $Test) {
    if ($($IP.Name).StartsWith('10.') -or $($IP.Name).StartsWith('192.168') -or $($IP.Name).StartsWith('127.') -or ($($IP.Name).StartsWith('172.') -and ($($IP.Name).split('.')[1] -as [int] -in 16..31)))
    {
        Write-Host "$($IP.Name | Select-Object -First 1) has not been tested on IP $($IP.Name) as this is a private IP address" -ForegroundColor White -BackgroundColor DarkBlue
        continue;
    }

    $Shodan = ""
    try {
        $Shodan = Invoke-RestMethod -uri "https://api.shodan.io/shodan/host/$($IP.Name)?key=$ShodanAPIKey" -ErrorAction SilentlyContinue
    }
    catch {
        Write-Debug $_.Exception.Message
    }
    
    $ShodanResult = ""
    $ShodanResult = New-Object -TypeName psobject
    $ShodanResult | Add-Member -MemberType NoteProperty -Name ExternalIP -Value $IP.Name
    $ShodanResult | Add-Member -MemberType NoteProperty -Name RawShodanResults -Value $Shodan
    $ShodanResult | Add-Member -MemberType NoteProperty -Name ISP -Value $Shodan.ISP
    $ShodanResult | Add-Member -MemberType NoteProperty -Name VulnerabilitiesFound -Value $($Shodan.Vulns -join "|")
    $ShodanResult | Add-Member -MemberType NoteProperty -Name Ports -Value $($Shodan.Ports -join "|")
    $ShodanResult | Add-Member -MemberType NoteProperty -Name LastUpdate -Value $Shodan.last_update

    $FinalStatus = "Condition detected. "
    $ConditionsDetected = $False

    If($($Shodan.Vulns).Count -gt 0)
    {
        $ConditionsDetected = $True
        $FinalStatus = $FinalStatus += "$(($Shodan.Vulns).Count) Vulnerabilities found. $($Shodan.Vulns)"
    }

    If($($Shodan.Ports).Count -gt 0 -and $OpenPortsAreErrors)
    {
        $ConditionsDetected = $True
        $FinalStatus = $FinalStatus += "$(($Shodan.Ports).Count) ports found open. $($Shodan.Ports)"
    }

    if ($ConditionsDetected) {
        Write-Host "$($IP.Name | Select-Object -First 1) has been tested on IP $($IP.Name). $FinalStatus" -BackgroundColor Red -ForegroundColor Black
    }

    if (!$ConditionsDetected) {
        Write-Host "$($IP.Name | Select-Object -First 1) has been tested on IP $($IP.Name) and no conditions were found" -BackgroundColor DarkGreen -ForegroundColor White
    }

    $FinalArray += $ShodanResult
    Start-Sleep -Milliseconds 1100
}

$output = Read-Host 'Enter full path where CSV should be saved (IE C:\Temp\Output.csv)' #Path needs to exist for the file to be created. 
try {
    $FinalArray | Export-Csv -Path $output -NoClobber -NoTypeInformation
}
catch {
    Write-Host "File Save failed with error $_.Exception.Message. The results are stored in a variable called FinalArray so you may be able to export them manually" -BackgroundColor Red -ForegroundColor Black
}
