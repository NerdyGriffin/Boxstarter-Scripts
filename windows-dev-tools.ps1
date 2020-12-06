try {
	Disable-UAC

	#--- Powershell Module Repository
	Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

	#--- Install/Update PowerShellGet and PackageManagement
	# Install-PackageProvider Nuget -Force -Verbose
	# Install-Module -Name PowerShellGet -Scope AllUsers -AllowClobber -SkipPublisherCheck -Force -AcceptLicense -Verbose
	# Install-Module -Name PackageManagement -Scope AllUsers -AllowClobber -SkipPublisherCheck -Force -AcceptLicense -Verbose
	# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	# Install-Module -Name PackageManagement -Force -MinimumVersion 1.4.6 -Scope CurrentUser -AllowClobber
	# Update-Module -AcceptLicense -Verbose
	# Get-Module

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
	Install-BoxstarterPackage -PackageName 'https://raw.githubusercontent.com/NerdyGriffin/Multipurpose-Boxstarter-Scripts/main/configure-git.ps1'

	# Make a folder for my GitHub repos and make SymbolicLinks to it
	if (-Not(Test-Path 'C:\GitHub')) { New-Item -Path 'C:\GitHub' -ItemType Directory }
	if (-Not(Test-Path (Join-Path $env:USERPROFILE 'GitHub'))) { New-Item -Path (Join-Path $env:USERPROFILE 'GitHub') -ItemType SymbolicLink -Value 'C:\GitHub' }
	if ((Test-Path 'D:\') -And -Not(Test-Path 'D:\GitHub')) { New-Item -Path 'D:\GitHub' -ItemType SymbolicLink -Value 'C:\GitHub' }

	choco upgrade -y powershell
	choco upgrade -y au

	choco upgrade -y powershell-core
	# choco install -y azure-cli
	choco upgrade -y microsoft-windows-terminal; choco upgrade -y microsoft-windows-terminal
	choco install -y poshgit
	# Install-Module -Force Az

	# choco install -y azure-cosmosdb-emulator
	# choco install -y azurestorageemulator
	# choco install -y azure-functions-core-tools-3

	# choco install -y visualstudio2019enterprise
	# choco install -y visualstudio2019-workload-azure
	choco install -y visualstudio2017community
	choco install -y gitdiffmargin
	# choco install -y terraform
	choco install -y docker-for-windows

	#--- Assorted Dev Tools and Dependencies
	choco install -y androidstudio
	choco install -y arduino
	choco install -y beyondcompare
	choco install -y console-devel
	choco install -y electron
	choco install -y fiddler
	choco install -y hxd
	choco install -y meld
	choco install -y ngrok
	choco install -y notepadplusplus
	choco install -y nvm
	choco install -y openjdk8
	choco install -y openjdk11
	choco install -y pip
	choco install -y python3
	choco install -y StrawberryPerl
	choco install -y sublimetext3
	choco install -y windbg
	# choco install -y winmerge

	#--- Advanced Network Tools ---
	choco install -y wireshark

	#--- PowerShell Tools ---
	choco install -y checksum
	choco install -y ConEmu
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
	choco install -y findutils
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

	#--- Chocolatey and Boxstarter Package Dev Tools
	choco install -y Chocolatey-AutoUpdater
	choco install -y ChocolateyPackageUpdater
	try { choco install -y ChocolateyDeploymentUtils } catch {}
	choco install -y boxstarter.chocolatey
	choco install -y Boxstarter.TestRunner

	Set-BoxstarterDeployOptions -DeploymentTargetPassword 'testvmlogin' -DeploymentTargetUserName 'Boxstarter' -DeploymentTargetNames 'testVM1' -DeploymentVMProvider HyperV -RestoreCheckpoint clean
	# $cred = Get-Credential Admin
	# Set-BoxstarterDeployOptions -DeploymentTargetCredentials $cred `
	# 	-DeploymentTargetNames 'testVM1', 'testVM2' `
	# 	-DeploymentVMProvider Hyper -DeploymentCloudServiceName ServiceName `
	# 	-RestoreCheckpoint clean `
	# 	-DefaultNugetFeed https://www.myget.org/F/mywackyfeed/api/v2 `
	# 	-DefaultFeedAPIKey 5cbc38d9-1a94-430d-8361-685a9080a6b8

	Enable-MicrosoftUpdate
	Install-WindowsUpdate -acceptEula

	#--- Configure Powershell Profile for Powerline and PSReadline ---
	Install-BoxstarterPackage -PackageName 'https://raw.githubusercontent.com/NerdyGriffin/Multipurpose-Boxstarter-Scripts/main/configure-powershell.ps1'

	#--- Copy over mmy customized Windows Terminal settings file
	if (Test-Path '\\GRIFFINUNRAID\backup\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json') {
		Copy-Item -Path '\\GRIFFINUNRAID\backup\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json' -Destination (Join-Path $env:USERPROFILE 'Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json')
	}

	Enable-UAC
	Enable-MicrosoftUpdate
	Install-WindowsUpdate -acceptEula

	Write-Debug 'nerdygriffin.DevTools completed successfully'
	Write-Debug ' See the log for details (' $Boxstarter.Log ').'
} catch {
	Write-Debug 'Error occurred in nerdygriffin.DevTools' $($_.Exception.Message)
	Write-Debug ' See the log for details (' $Boxstarter.Log ').'
	throw $_.Exception
}