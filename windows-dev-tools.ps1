try {
	Disable-UAC

	$Boxstarter.RebootOk = $true

	#--- Powershell Module Repository
	Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

	#--- Windows Subsystems/Features ---
	choco install Microsoft-Hyper-V-All -source windowsFeatures
	choco install Microsoft-Windows-Subsystem-Linux -source windowsfeatures

	#--- Windows Dev Essentials
	choco install -y dotnet
	choco install -y dotnet-sdk
	choco install -y dotnetcore
	choco install -y dotnetcore-sdk
	choco install -y dotnetcoresdk
	# choco install -y dotpeek # Installer appears to be broken on my machine
	choco install -y linqpad
	choco install -y vscode
	choco install -y chocolatey-vscode
	choco install -y git --package-parameters="'/WindowsTerminal'"
	refreshenv

	#--- Gitkraken ---
	choco install -y gitkraken

	#--- Other Git Tools ---
	choco install -y Gpg4win
	choco install -y lepton
	refreshenv

	#--- Configure Git ---
	try { Boxstarter.bat nerdygriffin.Configure-Git } catch {
		try {
			Install-BoxstarterPackage -PackageName 'https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/configure-git.ps1'
		} catch {}
	}

	# Make a folder for my GitHub repos and make SymbolicLinks to it
	if (-Not(Test-Path 'C:\GitHub')) { New-Item -Path 'C:\GitHub' -ItemType Directory }
	if (-Not(Test-Path (Join-Path $env:USERPROFILE 'GitHub'))) { New-Item -Path (Join-Path $env:USERPROFILE 'GitHub') -ItemType SymbolicLink -Value 'C:\GitHub' }
	if ((Test-Path 'D:\') -And -Not(Test-Path 'D:\GitHub')) { New-Item -Path 'D:\GitHub' -ItemType SymbolicLink -Value 'C:\GitHub' }

	choco upgrade -y powershell
	choco upgrade -y au

	choco upgrade -y powershell-core
	# choco install -y azure-cli
	choco upgrade -y microsoft-windows-terminal; choco upgrade -y microsoft-windows-terminal # Does this twice because the first attempt often fails but leaves the install partially completed, and then it completes successfully the second time.
	choco install -y poshgit
	# Install-Module -Force Az

	# choco install -y azure-cosmosdb-emulator
	# choco install -y azurestorageemulator
	# choco install -y azure-functions-core-tools-3

	# choco install -y visualstudio2019enterprise
	# choco install -y visualstudio2019-workload-azure
	# choco install -y terraform
	# choco install -y docker-for-windows

	#--- Workload needed for Column UI Dev
	choco install -y visualstudio2019community
	choco install -y visualstudio2019-workload-nativedesktop
	choco install -y visualstudio2019-workload-vctools

	#--- Workload needed for gordon-360-api
	choco install -y visualstudio2017community
	choco install -y nuget.commandline
	choco install -y visualstudio2017-workload-manageddesktop
	choco install -y visualstudio2017-workload-netweb

	choco install -y gitdiffmargin

	#--- Assorted Dev Tools and Dependencies
	choco install -y androidstudio
	choco install -y arduino
	choco install -y beyondcompare
	# choco install -y console-devel
	choco install -y dbforge-mysql-studio
	choco install -y electron
	choco install -y fiddler
	choco install -y HexEdit
	choco install -y hxd
	choco install -y meld
	choco install -y ngrok
	choco install -y notepadplusplus
	choco install -y mcr-r2019a
	choco install -y nvm
	choco install -y openjdk8
	choco install -y openjdk11
	choco install -y pip
	choco install -y python3
	choco install -y sublimetext3

	#--- Advanced Network Tools ---
	# choco install -y advanced-ip-scanner # Possibly broken for FOSS users
	# choco install -y ipscan # Possibly broken for FOSS users
	choco install -y wireshark

	#--- PowerShell Tools ---
	choco install -y checksum
	# choco install -y ConEmu
	choco install -y curl
	choco install -y llvm
	choco install -y psutils
	choco install -y rsync
	choco install -y unzip
	choco install -y winscreenfetch
	choco install -y zip

	#--- GNU ---
	choco install -y awk
	choco install -y diffutils
	# choco install -y findutils # Conflicts with command 'code' for VSCode
	choco install -y gimp
	choco install -y gnuplot
	choco install -y gnuwin
	choco install -y gperf
	choco install -y grep
	choco install -y make
	choco install -y nano
	choco install -y octave
	choco install -y patch
	choco install -y sed
	choco install -y wget

	#--- SSH ---
	Write-Output 'Make sure that the OpenSSH features are available for install:'
	Get-WindowsCapability -Online | Where-Object Name -Like 'OpenSSH*'
	Get-WindowsCapability -Online | Where-Object Name -Like 'OpenSSH*' | Where-Object State -NotLike 'Installed' | ForEach-Object {
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

	# #--- Chocolatey and Boxstarter Package Dev Tools
	# choco install -y Chocolatey-AutoUpdater
	# choco install -y ChocolateyPackageUpdater
	# try { choco install -y ChocolateyDeploymentUtils } catch {}
	# choco install -y boxstarter.chocolatey
	# choco install -y Boxstarter.TestRunner

	#--- Fonts ---
	choco install -y cascadiafonts

	Enable-MicrosoftUpdate
	Install-WindowsUpdate -acceptEula

	#--- Configure Powershell Profile for Powerline and PSReadline ---
	try { Boxstarter.bat nerdygriffin.Configure-PowerShell } catch {
		try {
			Install-BoxstarterPackage -PackageName 'https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/configure-powershell.ps1'
		} catch {}
	}

	Enable-UAC
	Enable-MicrosoftUpdate
	Install-WindowsUpdate -acceptEula

	Write-Host 'nerdygriffin.DevTools completed successfully' | Write-Debug
	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
} catch {
	Write-Host 'Error occurred in nerdygriffin.DevTools' $($_.Exception.Message) | Write-Debug
	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
	throw $_.Exception
}