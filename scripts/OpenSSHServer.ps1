#--- SSH ---

# See https://gitlab.com/DarwinJS/ChocoPackages/tree/master/openssh#package-parameters
choco install openssh -y -params '"/SSHServerFeature /PathSpecsToProbeForShellEXEString:$env:ProgramFiles\PowerShell\*\pwsh.exe;$env:windir\System32\WindowsPowerShell\v1.0\powershell.exe"'

# ssh-keygen.exe -A

# if (Test-Path 'C:\Program Files\OpenSSH-Win64\FixHostFilePermissions.ps1') {
# 	. 'C:\Program Files\OpenSSH-Win64\FixHostFilePermissions.ps1'
# }

# # Based on this documentation: https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse
# #--- Install OpenSSH using PowerShell ---
# Write-Output 'Make sure that the OpenSSH features are available for install:'
# Get-WindowsCapability -Online | Where-Object Name -Like 'OpenSSH*' | Write-Output
# Get-WindowsCapability -Online | Where-Object Name -Like 'OpenSSH*' | Where-Object State -notLike 'Installed' | ForEach-Object {
# 	$Name = $_.Name
# 	Write-Output "Installing '$Name' ..."
# 	$Result = Add-WindowsCapability -Online -Name $Name;
# 	if ($Result.RestartNeeded) { Invoke-Reboot }
# 	Write-Output 'Make sure that the OpenSSH features were installed correctly'
# 	Get-WindowsCapability -Online | Where-Object Name -Like 'OpenSSH*' | Write-Output
# }

#--- Start and configure SSH Server ---
Write-Output "Starting 'sshd' service..."
Start-Service sshd

Write-Host 'If ''sshd'' service fails to start, try manually running ''sshd.exe -d'' to see more specific error messaged' -ForegroundColor Cyan

# OPTIONAL but recommended:
Write-Output "Setting 'sshd' startup type to 'Automatic'..."
Set-Service -Name sshd -StartupType 'Automatic'

# # Confirm the Firewall rule is configured. It should be created automatically by setup.
# Write-Output 'Confirm the Firewall rule is configured. It should be created automatically by setup.'
# Get-NetFirewallRule -Name *ssh* | Write-Output
# # There should be a firewall rule named "OpenSSH-Server-In-TCP", which should be enabled
# $ExistingRule = Get-NetFirewallRule -Name *ssh* | Where-Object Name -Like 'OpenSSH-Server-In-TCP'
# if (-not($ExistingRule)) {
# 	# If the firewall does not exist, create one
# 	Write-Warning "Firewall rule not found for 'OpenSSH Server (sshd)'."
# 	Write-Output "Creating a firewall rule for 'OpenSSH Server (sshd)'..."
# 	New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
# } elseif (-not($ExistingRule.Enabled)) {
# 	# If the firewall exists but is not enabled, then enable it
# 	Write-Warning 'Firewall rule found, but is not enabled.'
# 	Write-Output "Enabling the firewall rule for 'OpenSSH Server (sshd)'..."
# 	$ExistingRule | Enable-NetFirewallRule
# }

# # Based on this documentation: https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_server_configuration
# #--- Configure the default shell for OpenSSH ---
# $ShellName = ''
# $DefaultShellPath = ''
# if (Get-Command pwsh.exe) {
# 	$ShellName = 'PowerShell Core'
# 	$DefaultShellPath = (Get-Command pwsh.exe).Source
# } elseif (Get-Command powershell.exe) {
# 	$ShellName = 'PowerShell'
# 	$DefaultShellPath = (Get-Command powershell.exe).Source
# }
# if ($ShellName) {
# 	Write-Output "Configuring '$ShellName' as the default shell for OpenSSH"
# 	New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value "$DefaultShellPath" -PropertyType String -Force

# 	# $SSHDConfigPath = (Join-Path $env:ProgramData '\ssh\sshd_config')
# 	# $SSHSubsystemString = 'Subsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs -NoLogo'
# 	# if (-not(Select-String -SimpleMatch $SSHSubsystemString -Path $SSHDConfigPath )) {
# 	# 	# Only add the new subsystem line if it is not already in the sshd_config
# 	# 	$OldContent = @(Get-Content $SSHDConfigPath)
# 	# 	$ExistingSubsystemLines = @($OldContent | Select-String -SimpleMatch 'Subsystem' | Select-Object -ExpandProperty Line)
# 	# 	if ($ExistingSubsystemLines) {
# 	# 		# Get the last member of the array
# 	# 		$LastSubsystemLine = $ExistingSubsystemLines[$ExistingSubsystemLines.Count - 1]
# 	# 		# Add the new line after the last existing subsystem line
# 	# 		$OldContent | ForEach-Object {
# 	# 			# Output the existing line to pipeline in any case
# 	# 			$_

# 	# 			# If line matches the last existing subsystem line
# 	# 			if ($_ -like $LastSubsystemLine) {
# 	# 				# Add output additional line right after it
# 	# 				$SSHSubsystemString
# 	# 			}
# 	# 		} | Set-Content -Path $SSHDConfigPath
# 	# 	} else {
# 	# 		Add-Content -Path $SSHDConfigPath -Value $SSHSubsystemString
# 	# 	}
# 	# }
# }
