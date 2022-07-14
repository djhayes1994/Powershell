<#
.SYNOPSIS
  Downloads CMS data from cms.gov.
.DESCRIPTION
  Downloads the latest archive for datasets of Nursing Homes and Rehab Services from cms.gov.
  Places into shared directory w/ latest date on folder.
  Removes downloaded archive to save on space. 
.INPUTS
  None
.OUTPUTS
  Downloads zip to file share, extracts all data sets from zip and stores them in the share. 
  Creates log file in root of share. 
.NOTES
  Version:        1.0
  Author:         Daniel Hayes
  Email:          dan.hayes@morefield.com
  Creation Date:  07/14/2022
  Purpose/Change: Initial script development
  
.EXAMPLE
 This script runs as a scheduled task, no example is needed. Can be run manually. 
#>

$date = get-date -f yyyy-MM-dd
$dlPath = "https://data.cms.gov/provider-data/sites/default/files/archive/Nursing%20homes%20including%20rehab%20services/current/nursing_homes_including_rehab_services_current_data.zip"
$archivePath = "C:\temp\NHData.zip"
$destPath = "C:\temp\NHData$date"
$logPath = "C:\temp\CMSScript.log"

Start-Transcript -Append $logPath -UseMinimalHeader
Try{
    Write-Output "Downloading archive from: $dlPath"
    Invoke-WebRequest -Uri $dlPath -OutFile $archivePath -ErrorAction Stop
    Write-Output "Downloaded Successfully."
}
Catch{
    Throw $_
}

Try{
    Write-Output "Extracting files to: $destPath"
    Expand-Archive -Path $archivePath -DestinationPath $destPath -Force -ErrorAction Stop
    Write-Output "Zip has been extracted successfully."
}
Catch{
    Throw $_
}
Try{
    Write-Output "Removing old zip file: $archivePath"
    Remove-Item -Path $archivePath -ErrorAction Stop
    Write-Output "Zip has been removed to clean up redundant data."
}
Catch{
    Throw $_
}

Stop-Transcript
