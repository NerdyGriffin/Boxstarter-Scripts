try {
	Disable-UAC

	# manual way...
	# dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
	# dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
	# Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
	# wsl --set-default-version 2
	# Store link: <https://www.microsoft.com/en-us/p/ubuntu/9nblggh4msv6>

	choco install boxstarter.hyperv
	choco install -y Microsoft-Windows-Subsystem-Linux --source="'windowsfeatures'"

	#--- Ubuntu ---
	# TODO: Move this to choco install once --root is included in that package
	#Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile ~/Ubuntu.appx -UseBasicParsing
	#Add-AppxPackage -Path ~/Ubuntu.appx
	# run the distro once and have it install locally with root user, unset password

	RefreshEnv
	try {
		Ubuntu2004 install --root
		Ubuntu2004 run apt update
		Ubuntu2004 run apt upgrade -y

	} catch {
		Ubuntu1804 install --root
		Ubuntu1804 run apt update
		Ubuntu1804 run apt upgrade -y
	}

	choco install wsl2
	choco install wslgit
	choco install wsl-ubuntu-2004
	choco install wsl-ubuntu-1804

	# Install tools in WSL instance
	Write-Host 'Installing tools inside the WSL distro...'
	try {
		# Ubuntu2004 run apt install ansible -y
		Ubuntu2004 run apt install nodejs -y
		Ubuntu2004 run apt install git-core
	} catch {
		# Ubuntu1804 run apt install ansible -y
		Ubuntu1804 run apt install nodejs -y
		Ubuntu1804 run apt install git-core
	}

	Enable-WindowsOptionalFeature -Online -FeatureName containers -All
	RefreshEnv
	choco install -y docker-for-windows
	choco install -y vscode-docker

	Enable-UAC
	Enable-MicrosoftUpdate
	Install-WindowsUpdate -acceptEula

	Write-Host 'nerdygriffin.WSL completed successfully' | Write-Debug
	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
} catch {
	Write-Host 'Error occurred in nerdygriffin.WSL' $($_.Exception.Message) | Write-Debug
	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
	throw $_.Exception
}