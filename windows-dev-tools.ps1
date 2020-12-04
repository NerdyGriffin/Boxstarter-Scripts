try {
	Disable-UAC

	#--- Windows Subsystems/Features ---
	choco install Microsoft-Hyper-V-All -source windowsFeatures
	choco install Microsoft-Windows-Subsystem-Linux -source windowsfeatures

	choco install -y dotnetcoresdk
	choco install -y dotnet
	choco install -y dotnet-sdk
	choco install -y dotnetcore
	choco install -y dotnetcore-sdk
	choco install -y dotpeek
	choco install -y linqpad
	choco install -y chocolatey-vscode.extension
	choco install -y vscode
	choco install -y chocolatey-vscode
	choco install -y git --package-parameters="'/WindowsTerminal'"
	refreshenv

	choco upgrade -y powershell
	choco install -y au

	choco upgrade -y powershell-core
	choco install -y azure-cli
	choco install -y microsoft-windows-terminal
	choco install -y poshgit
	choco install -y oh-my-posh
	choco install -y posh-github
	Install-Module -Force Az

	#--- Install/Update PowerShellGet and PackageManagement
	Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
	# Install-PackageProvider Nuget -Force -Verbose
	# Install-Module -Name PowerShellGet -Scope AllUsers -AllowClobber -SkipPublisherCheck -Force -AcceptLicense -Verbose
	# Install-Module -Name PackageManagement -Scope AllUsers -AllowClobber -SkipPublisherCheck -Force -AcceptLicense -Verbose
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	Install-Module -Name PackageManagement -Force -MinimumVersion 1.4.6 -Scope CurrentUser -AllowClobber
	# Update-Module -AcceptLicense -Verbose
	Get-Module

	Enable-UAC
	Enable-MicrosoftUpdate
	Install-WindowsUpdate -acceptEula

	#--- Install & Configure the Powerline Modules
	try {
		Write-Host 'Installing Posh-Git and Oh-My-Posh - [Dependencies for Powerline]'
		if (-Not(Get-Module -ListAvailable -Name posh-git)) {
			Install-Module posh-git -Scope AllUsers -AllowClobber -SkipPublisherCheck -Force -AcceptLicense -Verbose
		} else { Write-Host "Module 'posh-git' already installed" }
		if (-Not(Get-Module -ListAvailable -Name oh-my-posh)) {
			Install-Module oh-my-posh -Scope AllUsers -AllowClobber -SkipPublisherCheck -Force -AcceptLicense -Verbose
		} else { Write-Host "Module 'oh-my-posh' already installed" }

		Write-Host 'Appending Configuration for Powerline to PowerShell Profile...'
		$PowerlineProfile = @(
			'# Dependencies for powerline',
			'Import-Module posh-git',
			'Import-Module oh-my-posh',
			'Set-Theme Paradox'
		)
		Write-Host >> $PROFILE # This will create the file if it does not already exist, otherwise it will leave the existing file unchanged
		foreach ($ProfileString in $PowerlineProfile) {
			if (-Not(Select-String -Pattern $ProfileString -Path $PROFILE)) {
				Add-Content -Path $PROFILE -Value $ProfileString
			}
		}
		if (Get-Command refreshenv -ErrorAction SilentlyContinue) { refreshenv }
	} catch {
		Write-Warning 'Powerline failed to install'
		# Move on if Powerline install fails due to error
	}
	Get-Module

	#--- Install & Configure the PSReadline Module
	try {
		Write-Host 'Installing PSReadLine -- [Bash-like CLI features and Optional Dependency for Powerline]'
		if (-Not(Get-Module -ListAvailable -Name PSReadLine)) {
			Install-Module -Name PSReadLine -Scope AllUsers -AllowClobber -SkipPublisherCheck -Force -AcceptLicense -Verbose
		} else { Write-Host "Module 'PSReadLine' already installed" }

		Write-Host 'Appending Configuration for PSReadLine to PowerShell Profile...'
		$PSReadlineProfile = @(
			'# Customize PSReadline to make PowerShell behave more like Bash',
			'Import-Module PSReadLine',
			'Set-PSReadLineOption -EditMode Emacs -HistoryNoDuplicates -HistorySearchCursorMovesToEnd',
			'Set-PSReadLineOption -BellStyle Audible -DingTone 512',
			'# Creates an alias for ls like I use in Bash',
			'Set-Alias -Name v -Value Get-ChildItem'
		)
		Write-Host >> $PROFILE # This will create the file if it does not already exist, otherwise it will leave the existing file unchanged
		foreach ($ProfileString in $PSReadlineProfile) {
			if (-Not(Select-String -Pattern $ProfileString -Path $PROFILE)) {
				Add-Content -Path $PROFILE -Value $ProfileString
			}
		}
		if (Get-Command refreshenv -ErrorAction SilentlyContinue) { refreshenv }
	} catch {
		Write-Warning 'PSReadline failed to install'
		# Move on if PSReadline install fails due to errors
	}
	Get-Module

	#--- Install the Pipeworks Module
	try {
		Write-Host 'Installing Pipeworks -- [CLI Tools for PowerShell]'
		Write-Host 'Description: PowerShell Pipeworks is a framework for writing Sites and Software Services in Windows PowerShell modules.'
		if (-Not(Get-Module -ListAvailable -Name Pipeworks)) {
			Install-Module -Name Pipeworks -Scope AllUsers -AllowClobber -SkipPublisherCheck -Force -AcceptLicense -Verbose
		} else { Write-Host "Module 'Pipeworks' already installed" }
		if (Get-Command refreshenv -ErrorAction SilentlyContinue) { refreshenv }
	} catch {
		Write-Warning 'Pipeworks failed to install'
		# Move on if Pipeworks install fails due to errors
	}
	Get-Module

	#--- Gitkraken ---
	# if (Test-Path 'D:\') {
	# 	if (-Not(Test-Path 'D:\.gitkraken')) {
	# 		New-Item -Path 'D:\.gitkraken' -Type Directory -Verbose
	# 	}
	# 	New-Item -Path (Join-Path $env:APPDATA '.gitkraken') -ItemType SymbolicLink -Value 'D:\.gitkraken' -Force -Verbose -ErrorAction Stop
	# }
	choco install -y gitkraken

	#--- Other Git Tools ---
	choco install -y Gpg4win
	# choco install -y diffmerge
	# choco install -y gitextensions
	choco install -y lepton

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


	# choco install -y azure-cosmosdb-emulator
	# choco install -y azurestorageemulator
	# choco install -y azure-functions-core-tools-3

	choco install -y chocolatey-visualstudio.extension
	# choco install -y visualstudio2019enterprise
	# choco install -y visualstudio2019-workload-azure
	choco install -y visualstudio2017community
	choco install -y gitdiffmargin
	# choco install -y terraform
	choco install -y docker-for-windows

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

	#--- Import Self-Made Module for Easy Link Creation

	#--- Configure Git ---
	Install-BoxstarterPackage -PackageName 'https://gist.githubusercontent.com/NerdyGriffin/3fe7cc0de51fddb4bb499919d597ca50/raw/nerdygriffin.ps1'
	#--- The following was moved to the helper script above to avoid redundant lines of code
	# git config --global user.name 'Christian Kunis'
	# git config --global user.email 'ckunis98@gmail.com'
	# git config --global core.symlinks true
	# git config --global core.autocrlf input
	# git config --global core.eol lf
	# git config --global color.status auto
	# git config --global color.diff auto
	# git config --global color.branch auto
	# git config --global color.interactive auto
	# git config --global color.ui true
	# git config --global color.pager true
	# git config --global color.showbranch auto
	# git config --global alias.co checkout
	# git config --global alias.br branch
	# git config --global alias.ci commit
	# git config --global alias.st status
	# git config --global alias.ft fetch
	# git config --global alias.ph push
	# git config --global alias.pl pull
	# if (Test-Path 'C:\Program Files (x86)\GnuPG\bin\gpg.exe') {
	# 	git config --global gpg.program 'C:\Program Files (x86)\GnuPG\bin\gpg.exe'
	# }
	# git config --global --list

	# checkout recent projects
	if (-Not(Test-Path 'C:\GitHub')) { New-Item -Path 'C:\GitHub' -Type Directory }
	if (-Not(Test-Path (Join-Path $env:USERPROFILE 'GitHub'))) { New-Item -Path (Join-Path $env:USERPROFILE 'GitHub') -Type SymbolicLink -Target 'C:\GitHub' }

	Enable-UAC
	Enable-MicrosoftUpdate
	Install-WindowsUpdate -acceptEula

	Write-Debug 'The script completed successfully'
	Write-ChocolateySuccess 'nerdygriffin.DevTools'
} catch {
	Write-ChocolateyFailure 'nerdygriffin.DevTools' $($_.Exception.Message)
	throw
}