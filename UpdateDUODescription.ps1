$Users = Import-Csv -Path C:\Scripts\DUO\Users.csv

Import-Module ActiveDirectory

ForEach ($User in $Users)
{
    $Description = "[duo: " + $User.DUOName + "]"
    Write-Host $User.SamAccountName " Done."
    Set-ADUser $User.SamAccountName -Description $Description 
}
