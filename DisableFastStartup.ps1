# Based on https://github.com/ChrisTitusTech/win10script
Write-Output 'Disabling Fast Startup...'
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name 'HiberbootEnabled' -Type DWord -Value 0
