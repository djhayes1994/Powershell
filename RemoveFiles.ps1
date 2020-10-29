$files = Get-Content "C:\Users\dhayes\Desktop\files.csv"

foreach ($file in $files) {
    Remove-Item -Path $file -Force
    Write-Host "Delete action complete for $file"
}

Write-Host -foregroundcolor yellow "Delete action complete"
