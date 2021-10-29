$clientId = "(REPLACE ME)"
$clientSecret = "(REPLACE ME)"

# Manually construct Basic Authentication Header
$pair = "${clientId}:${clientSecret}"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
$headers = @{ "Authorization" = $basicAuthValue }
# Use param to tell type of credentials we request
$postParams = @{ grant_type = "client_credentials" }

# Add the request content type to the headers
$headers.Add("Content-Type", "application/x-www-form-urlencoded")

$token = Invoke-RestMethod -Method Post -Uri "https://us-cloud.acronis.com/api/2/idp/token" -Headers $headers -Body $postParams

#Specifies what the header array can hold, in this case string and string.
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
#Adds auth info to header variable.
$bearerVal = $token.access_token
$headers.Add("Authorization", "Bearer $bearerVal")
$baseuri = "https://us-cloud.acronis.com/"
$endpoint = "api/alert_manager/v1/alerts"
$fullurl = $baseuri+$endpoint
#Sends a GET request to the Acronis API.
$response = Invoke-RestMethod $fullurl -Method 'GET' -Headers $headers

#Takes the items property from the JSON response. 
$retdata = ($response).items

# Creates new CSV files so that alerts can be appended to them.
# There are two seperate CSV files at this time, one for the Failures and one for the offline machines.
# CSV files are stored in the temp folder at this time. 
$outfileFailed = "C:\temp\alertsFailed.csv"
$newcsvFailed = {} | Select "resourcename","planname","errortext", "errormessagereason", "alertreceived" | Export-Csv $outfileFailed
$csvfileFailed = Import-CSV $outfileFailed

$outfileOffline = "C:\temp\alertsOfflineMachine.csv"
$newcsvOffline = {} | Select "resourcename","dayspassed" | Export-Csv $outfileOffline
$csvfileOffline = Import-CSV $outfileOffline

ForEach($id in $retdata){
    if($id.type -like "BackupFailed"){
        $resourceName = $id.details.resourceName
        $planName = $id.details.planName
        $errorText = $id.details.error.text
        $errorMessageReason = $id.details.errorMessage.reason
        $alertRec = $id.createdAt
        $alertUp = $id.updatedAt
        Write-Output "Name: $resourceName"
        Write-Output "Plan: $planName"
        Write-Output "Error: $errorText"
        Write-Output "Error Reason: $errorMessageReason"
        Write-Output "Alert Received: $alertRec"
        Write-Output "Alert Last Updated: $alertUp"
        $csvfileFailed.resourcename = $resourceName
        $csvfileFailed.planname = $planName
        $csvfileFailed.errortext = $errorText
        $csvfileFailed.errorMessageReason = $errorMessageReason
        $csvfileFailed.alertreceived = $alertRec
        $csvfileFailed | Export-Csv $outfileFailed -Append
        "`n"
    }

    if($id.type -like "BackupDidNotStart"){
        $resourceName = $id.details.resourceName
        Write-Output "Name: $resourceName"
        Write-Output "Error: Backup did not start."
        $csvfileFailed.resourcename = $resourceName
        $csvfileFailed.planname = $null
        $csvfileFailed.errortext = "Backup did not start"
        $csvfileFailed.errorMessageReason = $null
        $csvfileFailed.alertreceived = $alertRec
        $csvfileFailed | Export-Csv $outfileFailed -Append
        "`n"
    }
    
    if($id.type -like "MachineOffline*"){
        $resourceName = $id.details.resourceName
        $alertRec = $id.createdAt
        $alertUp = $id.updatedAt
        $daysPassed = $id.details.daysPassed
        Write-Output "Name: $resourceName"
        Write-Output "Days Since Last Check-In: $daysPassed"
        Write-Output "Alert Received: $alertRec"
        Write-Output "Alert Last Updated: $alertUp"
        $csvfileOffline.resourcename = $resourceName
        $csvfileOffline.dayspassed = $daysPassed
        $csvfileOffline | Export-Csv $outfileOffline -Append
        "`n"
    }
}
