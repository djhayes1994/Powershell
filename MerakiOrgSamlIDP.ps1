<#
Author: Daniel Hayes
Email: dan.hayes@morefield.com
Creation Date: 03/24/2022
Last Modified: 04/06/2022
#>

<#
.Synopsis
   Updates Meraki SHA1 fingerprints for all customers under a MSP dashboard.
.DESCRIPTION
   Utilizes the Meraki API to update the SHA1 fingerprint for SAML authentication for Meraki sub tenants in a multi-tenant environment.

   When you update the SHA1 fingerprint it will update the SAML Assertion Consumer Service URL, you will need a break glass account to grab the new value from the Meraki dashboard so it can be updated in your SAML provider.
.EXAMPLE
   Modify the API Key variable to use your API key from your Multi-tenant dashboard.
   Modify the previousFingerPrint variable to use your current SHA1 fingerprint.
   Modify the newFingerPrint variable ot use your current SHA1 fingerprint. 
.INPUTS
   previousFingerPrint = Your previous SHA1 fingerprint.
   newFingerPrint = Your new SHA1 fingerprint.
   apiKey = Your API key
#>

<#
Global Variables
#>
$baseurl = "https://api.meraki.com/api/v1/"
$endpoint = "organizations"
$fullurl = $baseurl+$endpoint
$apiKey = "API KEY"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("X-Cisco-Meraki-API-Key", $apiKey)
$headers.Add("Content-Type", "application/json")
$previousFingerPrint = "Old fingerprint"
$newFingerPrint = "New fingerprint"


$response = Invoke-RestMethod $fullurl -Method 'GET' -Headers $headers

#Iterate through each comapny returned by the initial request.
ForEach ($CompanyID in $response){
    #Local variables for each company when iterated via ForEach.
    $APIEnabled = $CompanyID.api.enabled
    $CustomerName = $CompanyID.name
    #Checks if API is enabled for the org, if it is not return the name. If it is returned then change SHA1 value.
    if ($APIEnabled -eq "True"){
        $id = $CompanyID.id
        $endpoint = "organizations/$id/saml/idps"
        $fullurlidp = $baseurl+$endpoint
        $idpid = Invoke-RestMethod $fullurlidp -Method 'GET' -Headers $headers
        #Checks if fingerprint matches variable for each idp under subtenant. 
        foreach($idppostid in $idpid){
            #If it matches then update it to the new one.
            if($idppostid.x509certsha1fingerprint -eq $previousFingerPrint){
                $idpidendpostid = $idppostid.idpID
                $idpendpoint = "/$idpidendpostid/"
                $fullurlidpput = $fullurlidp+$idpendpoint
                $putBody = @{
                    "idpId" = "$idpidendpostid"
                    "x509certSha1Fingerprint" = "$newFingerPrint"
                }
                $idpresponse = Invoke-RestMethod $fullurlidpput -Method 'PUT' -Headers $headers -Body ($putBody|ConvertTo-Json)
            }
            #Return the value of a non matching fingerprint and it's value.
            else{
                $fingerprint = $idppostid.x509certsha1fingerprint
                Write-Output "Fingerprint was not changed for $CustomerName it's value was: $fingerprint"
            }
        }
    }
    else{
        Add-Content -Path C:\Temp\NoAPIOrg.txt -Value $CustomerName
    }
}