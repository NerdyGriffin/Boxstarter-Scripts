#--- SSH ---

#--- Install OpenSSH using PowerShell ---
Write-Output 'Make sure that the OpenSSH features are available for install:'
Get-WindowsCapability -Online | Where-Object Name -Like 'OpenSSH*'
Get-WindowsCapability -Online | Where-Object Name -Like 'OpenSSH*' | Where-Object State -NotLike 'Installed' | ForEach-Object {
	$Name = $_.Name
	Write-Output "Installing $Name"
	$Result = Add-WindowsCapability -Online -Name $Name;
	if ($Result.RestartNeeded) { Invoke-Reboot }
	Write-Output 'Make sure that the OpenSSH features were installed correctly'
	Get-WindowsCapability -Online | Where-Object Name -Like 'OpenSSH*'
}

#--- Start and configure SSH Server ---
Start-Service sshd
# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'
# Confirm the Firewall rule is configured. It should be created automatically by setup.
Get-NetFirewallRule -Name *ssh*
# There should be a firewall rule named "OpenSSH-Server-In-TCP", which should be enabled
$ExistingRule = Get-NetFirewallRule -Name *ssh* | Where-Object Name -Like 'OpenSSH-Server-In-TCP'
if (!($ExistingRule)) {
	# If the firewall does not exist, create one
	New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} elseif (!($ExistingRule.Enabled)) {
	# If the firewall exists but is not enabled, then enable it
	$ExistingRule | Enable-NetFirewallRule
}

#--- Configure the default shell for OpenSSH ---
$DefaultShellPath = ''
if (Get-Command pwsh.exe) {
	$DefaultShellPath = (Get-Command pwsh.exe).Source
} elseif (Get-Command powershell.exe) {
	$DefaultShellPath = (Get-Command powershell.exe).Source
}
if ($DefaultShellPath) {
	New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value "$DefaultShellPath" -PropertyType String -Force

	# $SSHDConfigPath = (Join-Path $env:ProgramData '\ssh\sshd_config')
	# $SSHSubsystemString = 'Subsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs -NoLogo'
	# if (-Not(Select-String -Pattern $SSHSubsystemString -Path $SSHDConfigPath )) {
	# 	Add-Content -Path $SSHDConfigPath -Value $SSHSubsystemString
	# }
}
