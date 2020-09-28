<#
    Author: Daniel Hayes
    Version: 1.0
    Description: This script will pull a list of configurations from a .csv file and will update the configuration status.

    Changelog:
    
    1.0
    Created initial script. 
#>


<#
    This portion of the script will connect to the CWM instance via the CWM REST API.
#>


# We are declaring the connection info here for the CW instance. This stores as a hash table and the Connect-CWM function uses it to connect. 
$CWMConnectionInfo = @{
    # This is the URL to your manage server.
    Server      = 'yourcwserver.com'
    # This is the company entered at login
    Company     = 'CW Company'
    # Public key created for this integration
    pubkey      = 'Put your public key here'
    # Private key created for this integration
    privatekey  = 'Put your private key here'
    # ClientID found at https://developer.connectwise.com/ClientID
    clientid    = 'Your client ID here'
}
# ^This information is sensitive, take precautions to secure it.^

# Install/Update/Load the module
if(Get-InstalledModule 'ConnectWiseManageAPI' -ErrorAction SilentlyContinue) { Update-Module 'ConnectWiseManageAPI' -Verbose }
else { Install-Module 'ConnectWiseManageAPI' -Verbose }
Import-Module 'ConnectWiseManageAPI'

# Connect to your Manage server
Connect-CWM @CWMConnectionInfo -Force -Verbose

<#
    This is the body of the script and it's what makes the magic happen.

    We are importing a CSV file, path is defined by the ConfigPath variable.

    The configurations variable is what stores the info in a hash table. 

    For testing purposes the following IDs were set to 'Active'

    46914
    9199
    9200
    9174

    CSV should be formatted as:
    ID,
    46914,
    9199,
    9200,
    9174,

#>
$ConfigPath = "C:\Temp\ID.csv" 
$Configurations = Import-Csv -Path $ConfigPath
$LogPath = "C:\Temp\ConfigUpdateLog.txt"

#Enable logging to file specified in variable LogPath
Start-Transcript -Path $LogPath

#For each configuration ID listed in the CSV file we are going to change the status to 'Automate Inactive'.
ForEach ($config in $configurations){
    Update-CWMCompanyConfiguration -ID $config.ID -Operation replace -Path status/id -Value 7
}

#Stop logging because we don't care anymore. 
Stop-Transcript