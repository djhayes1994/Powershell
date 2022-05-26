    <#

    Variable Declaration

    #>
    $DLDir = "C:\Temp\"
    $TreeSizeRepo = "https://downloads.jam-software.de/treesize_free/TreeSizeFree-Portable.zip"
    $TgtFile = "C:\Temp\TreeSize.zip"
    $TgtFileTst = Test-Path -Path $TgtFile
    $ValidPath = Test-Path -Path $DLDir
    $TgtExtract = "C:\Temp\TreeSize\"
    $AlreadyExtracted = Test-Path $TgtExtract
    $TgtFinal = "C:\Temp\TreeSize\TreesizeFree.exe"

Function Get-TreeSizeFree{
    <#

    Directory Check for destination

    #>
    If ($ValidPath -eq $true){
        Write-Output "Directory $DLDir already exists"
    }
    Else {
        New-Item -Path $DLDir -ItemType Directory
        Write-Output "Path $DLDir has been created."
    }

    <#

    Check to see if the file is downloaded, if it is then extract and run. 
    If not then download, extract, and run. 

    #>


    If ($TgtFileTst -eq $true){
        Write-Output "TreeSize Zip already exists..."
        If($AlreadyExtracted -eq $true){
            Write-Output "Zip is already extracted..."
            Write-Output "Launching TreeSize"
            Start-Process $TgtFinal
        }
        else {
            Write-Output "Extracting ZIP"
            Expand-Archive -LiteralPath $TgtFile -DestinationPath $TgtExtract
            Write-Output "Launching TreeSize"
            Start-Process $TgtFinal
        }
    }
    Else{
        Write-Output "Downloading file from: $TreeSizeRepo"
        Start-BitsTransfer –Source $TreeSizeRepo  -Destination $TgtFile
        Write-Output "Extracting TreeSize..."
        Expand-Archive -LiteralPath $TgtFile -DestinationPath $TgtExtract
        Write-Output "Launching TreeSize"
        Start-Process $TgtFinal
    }
}

Get-TreeSizeFree