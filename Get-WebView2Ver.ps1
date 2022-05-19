$ErrorActionPreference = "stop"
try {
    (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" -Name "pv").pv
}
catch {
     Write-Host "Not Installed/registery not found"
}