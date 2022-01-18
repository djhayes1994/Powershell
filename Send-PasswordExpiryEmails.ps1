## Send-PasswordExpiryEmails.ps1
## Author: Mike Kanakos - www.networkadm.in
## Sanitized by Dan Hayes. Was previously modified for use at employer, some code was modified. 
## Created: 2018-03-23
## -----------------------------
## https://4sysops.com/archives/a-password-expiration-reminder-script-in-powershell/

#Import AD Module
 Import-Module ActiveDirectory


#Create warning dates for future password expiration
$SevenDayWarnDate = (get-date).adddays(7).ToLongDateString()
$ThreeDayWarnDate = (get-date).adddays(3).ToLongDateString()
$OneDayWarnDate = (get-date).adddays(1).ToLongDateString()

#Email Variables
$MailSender = "Example <Example@Example.com>"
$Subject = 'Your account password will expire soon'
#$EmailStub1 = 'This is an automatically generated email to inform you that your password'
#$EmailStub2 = 'will expire in '
#$EmailStub3 = ' days on'
#$EmailStub4 = '. Please contact the helpdesk if you need assistance changing your password.'
$SMTPServer = 'Insert mail server here'

$Body7 = @"

<br>

This is an automatically generated email to inform you that your Active Directory password will expire in 7 days.<br>
Please contact the helpdesk if you need assistance changing your password.<br>

<br>

Once your password has expired you will likely be unable to connect to VPN and other services.<br>
You can follow the instructions below to change your password remotely from your computer.
<ol type="1">
    <li>Connect to the company VPN using Cisco AnyConnect and Duo Mobile.</li>
    <li>Press CTRL+ALT+DEL and click "Change Password".</li>
    <li>Enter your current password and your new password two times.</li>
    <li>You may disconnect from the VPN if you no longer need it.</li>
</ol>

Once you have followed those steps then your password has been updated and it will expire again in 90 days.<br>
"@
$Body3 = @"

<br>

This is an automatically generated email to inform you that your Active Directory password will expire in 3 days.<br>
Please contact the helpdesk if you need assistance changing your password.<br>

<br>

Once your password has expired you will likely be unable to connect to VPN and other services.<br>
You can follow the instructions below to change your password remotely from your computer.
<ol type="1">
    <li>Connect to the company VPN using Cisco AnyConnect and Duo Mobile.</li>
    <li>Press CTRL+ALT+DEL and click "Change Password".</li>
    <li>Enter your current password and your new password two times.</li>
    <li>You may disconnect from the VPN if you no longer need it.</li>
</ol>

Once you have followed those steps then your password has been updated and it will expire again in 90 days.<br>
"@
$Body1 = @"

<br>

This is an automatically generated email to inform you that your Active Directory password will expire in 1 day.<br>
Please contact the helpdesk if you need assistance changing your password.<br>

<br>

Once your password has expired you will likely be unable to connect to VPN and other services.<br>
You can follow the instructions below to change your password remotely from your computer.
<ol type="1">
    <li>Connect to the company VPN using Cisco AnyConnect and Duo Mobile.</li>
    <li>Press CTRL+ALT+DEL and click "Change Password".</li>
    <li>Enter your current password and your new password two times.</li>
    <li>You may disconnect from the VPN if you no longer need it.</li>
</ol>

Once you have followed those steps then your password has been updated and it will expire again in 90 days.<br>
"@

#Find accounts that are enabled and have expiring passwords
$users = Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False -and PasswordLastSet -gt 0 } `
 -Properties "Name", "EmailAddress", "msDS-UserPasswordExpiryTimeComputed" | Select-Object -Property "Name", "EmailAddress", `
 @{Name = "PasswordExpiry"; Expression = {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed").tolongdatestring() }}

#check password expiration date and send email on match
foreach ($user in $users) {
	 if ($user.PasswordExpiry -eq $SevenDayWarnDate) {
		 $days = 7
		 #$EmailBody = $EmailStub1, $user.name, $EmailStub2, $days, $EmailStub3, $SevenDayWarnDate, $EmailStub4 -join ' '

		 Send-MailMessage -To $user.EmailAddress -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $Body7 -BodyAsHtml
 	}
 	elseif ($user.PasswordExpiry -eq $ThreeDayWarnDate) {
		 $days = 3
		 #$EmailBody = $EmailStub1, $user.name, $EmailStub2, $days, $EmailStub3, $ThreeDayWarnDate, $EmailStub4 -join ' '

		 Send-MailMessage -To $user.EmailAddress -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $Body3 -BodyAsHtml
 	}
 	elseif ($user.PasswordExpiry -eq $oneDayWarnDate) {
		 $days = 1
		 #$EmailBody = $EmailStub1, $user.name, $EmailStub2, $days, $EmailStub3, $OneDayWarnDate, $EmailStub4 -join ' '

		 Send-MailMessage -To $user.EmailAddress -From $MailSender -SmtpServer $SMTPServer -Subject $Subject -Body $Body1 -BodyAsHtml
 	}
	else {}
 }
