#Example: https://disthost.umbrella.com/roaming/upgrade/win/stage/RoamingClient_WIN_3.0.328.msi

$baseurl = "https://disthost.umbrella.com/roaming/upgrade/win/production/"
$WebReq = Invoke-WebRequest -Uri "https://disthost.umbrella.com/roaming/upgrade/win/production/manifest.json" -UseBasicParsing | ConvertFrom-Json
$FileName = $WebReq.downloadFilename
$FullDownload = $baseurl+$FileName
$FullDownload
