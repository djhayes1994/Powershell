$1year = (Get-Date).AddDays(-365) # The 365 is the number of days from today since the last logon. Disables the computer and moves to the disabled computer OU.
$1y1m = (Get-Date).AddDays(-395) #1 year and 1 month after last log on date, this removes the computer.

#Modify line 8's property for Target Path to the DistinguishedName of the disabled computers OU. 

# Disable computer objects and move to disabled OU (Older than 1 year):
Get-ADComputer -Property Name,lastLogonDate -Filter {lastLogonDate -lt $1year} | Set-ADComputer -Enabled $false 
Get-ADComputer -Property Name,Enabled -Filter {Enabled -eq $False} | Move-ADObject -TargetPath "<MODIFY ME>" 

# Delete Older Disabled computer objects:
# IF you would like to test this modify line 12 and add -WhatIf after the recursive command.
Get-ADComputer -Property Name,lastLogonDate -Filter {lastLogonDate -lt $1y1m} | Remove-ADObject -Recursive
