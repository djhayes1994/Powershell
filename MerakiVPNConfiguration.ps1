<#
.SYNOPSIS
  The purpose of this script is to minimize the ammount of work required to create a VPN connection on a Windows 7, 8, 8.1, or 10 workstation for Meraki VPN.
.DESCRIPTION
  Collects input from shell and inputs it into Add-VPNConnection command with the command structured for Meraki L2TP VPN connections.
.INPUTS
  Name - This is the name of the VPN connection that will show within the Windows UI.
  ServerAddr - This is the server address which can be found either via the Meraki Dashboard or via CWM configurations, typically the configuration is named Remote Access.
  L2TPPSK - This is the preshared key for the L2TP connection. This can be found either via the Meraki Dashboard or via the customers configurations.
.OUTPUTS
  Add-VPNConnection creates the VPN connection. 
.NOTES
  Version:        1.1
  Author:         Daniel Hayes
  Creation Date:  03/28/2019
  Purpose/Change: Added pause at end of script so info could be read.
  
.EXAMPLE
  End user is requesting VPN access and the customer utilizes Meraki VPN. Meraki VPN does not have a client so it uses the Windows native VPN client. 
#>

#----------------------------------------------------------[Declarations]----------------------------------------------------------

$Name = Read-Host -Prompt 'Input name of VPN connection; Ie. Company VPN'
$ServerAddr = Read-Host -Prompt 'Input server address can be WAN IP or Meraki Hostname'
$L2TPPSK = Read-Host -Prompt 'Input Pre-shared key for VPN, can be found in Remote Access configuration'

#-----------------------------------------------------------[Execution]------------------------------------------------------------
Import-Module VpnClient
Add-VpnConnection -RememberCredential -Name $Name -ServerAddress $ServerAddr -AuthenticationMethod Pap -TunnelType L2tp -EncryptionLevel Optional -L2tpPsk $L2TPPSK -Force
Write-Host "VPN Connection has been created..."
Write-Host "You named the connection:" $Name
Write-Host "For the server address you entered:" $ServerAddr
Write-Host "For the Pre-Shared key:" $L2TPPSK "was used."
Write-Host "Detailed information is located below...."
Get-VpnConnection | fl
Pause
