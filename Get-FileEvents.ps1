# Requires auditing to be enabled via GPO

$logs = Get-WinEvent -LogName "Security" | Where-Object {$_.ProviderName -eq "Microsoft-Windows-Security-Auditing"}

$itemPath = Read-Host "Please enter the path to the folder for file (ex. C:\FileShare\doc.txt or C:\FileShare\)"
$itemPathReg = $itemPath.replace('\', '\\')

$logs | Where-Object {$_.Message -match $itemPathReg} | Export-CSV C:\Temp\LogExport.csv
