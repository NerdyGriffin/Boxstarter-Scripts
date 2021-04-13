#--- SSH ---
Write-Output 'Make sure that the OpenSSH features are available for install:'
Get-WindowsCapability -Online | Where-Object Name -Like 'OpenSSH*'
Get-WindowsCapability -Online | Where-Object Name -Like 'OpenSSH*' | Where-Object State -NotLike 'Installed' | ForEach-Object {
	Write-Output "Installing $_.Name"
	$Result = Add-WindowsCapability -Online -Name $_.Name;
	if ($Result.RestartNeeded) { Invoke-Reboot }
	Write-Output 'Make sure that the OpenSSH features were installed correctly'
	Get-WindowsCapability -Online | Where-Object Name -Like 'OpenSSH*'
}
# Now start the sshd service
Start-Service sshd
# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'
# Confirm the Firewall rule is configured. It should be created automatically by setup.
if (! (Get-NetFirewallRule -Name *ssh* | Where-Object Name -Like 'OpenSSH-Server-In-TCP' | Where-Object Enabled -EQ True)) {
	# There should be a firewall rule named "OpenSSH-Server-In-TCP", which should be enabled
	# If the firewall does not exist, create one
	New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}
# Configure the default shell for OpenSSH
if (Get-Command pwsh.exe) {
	$DefaultShellPath = (Get-Command pwsh.exe).Source
	New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value "$DefaultShellPath" -PropertyType String -Force
} elseif (Get-Command powershell.exe) {
	$DefaultShellPath = (Get-Command powershell.exe).Source
	New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value "$DefaultShellPath" -PropertyType String -Force
}
Add-Content -Path $env:ProgramData\ssh\sshd_config -Value 'Subsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs -NoLogo'
