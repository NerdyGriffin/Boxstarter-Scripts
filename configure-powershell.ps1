try {
	Disable-UAC

	$MapNetworkDriveScript = '\\GRIFFINUNRAID\scripts\MapNetworkDrives.ps1'

	choco upgrade -y powershell
	choco upgrade -y powershell-core
	refreshenv

	#--- Prepend a Custom Printed Message to the PowerShell Profile
	try {
		$ScriptBlock = {
			Write-Host 'Prepending Custom Message to PowerShell Profile...'
			$ProfileString = 'Write-Output "Loading Custom PowerShell Profile..."'
			Write-Host >> $PROFILE # This will create the file if it does not already exist, otherwise it will leave the existing file unchanged
			if (-Not(Select-String -Pattern $ProfileString -Path $PROFILE )) {
				Write-Output 'Attempting to add the following line to $PROFILE :' | Write-Debug
				Write-Output $ProfileString | Write-Debug
				Set-Content -Path $PROFILE -Value ($ProfileString, (Get-Content $PROFILE))
			}
		}
		# Add the lines to the $PROFILE for PowerShell
		powershell.exe -Command $ScriptBlock
		# Do the same for PowerShell Core
		pwsh.exe -Command $ScriptBlock
	} catch {
		Write-Host  'Something went wrong while trying to prepend the custom message to $PROFILE' | Write-Warning
		Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
	}
	refreshenv


	#--- Install & Configure the Powerline Modules
	choco install -y poshgit
	choco install -y oh-my-posh
	choco install -y posh-github
	refreshenv
	try {
		Write-Host 'Installing Posh-Git and Oh-My-Posh - [Dependencies for Powerline]'
		if (-Not(Get-Module -ListAvailable -Name posh-git)) {
			Install-Module posh-git -Scope AllUsers -AllowClobber -SkipPublisherCheck -Force -Verbose
		} else { Write-Host "Module 'posh-git' already installed" }
		if (-Not(Get-Module -ListAvailable -Name oh-my-posh)) {
			Install-Module oh-my-posh -Scope AllUsers -AllowClobber -SkipPublisherCheck -Force -Verbose
		} else { Write-Host "Module 'oh-my-posh' already installed" }
		refreshenv
		try {
			$ScriptBlock = {
				Write-Host 'Appending Configuration for Powerline to PowerShell Profile...'
				$PowerlineProfile = @(
					'# Dependencies for powerline',
					'Import-Module posh-git',
					'Import-Module oh-my-posh',
					'Set-Theme Paradox'
				)
				Write-Host >> $PROFILE # This will create the file if it does not already exist, otherwise it will leave the existing file unchanged
				if (-Not(Select-String -Pattern $PowerlineProfile[0] -Path $PROFILE )) {
					Write-Output 'Attempting to add the following lines to $PROFILE :' | Write-Debug
					Write-Output $PowerlineProfile | Write-Debug
					Add-Content -Path $PROFILE -Value $PowerlineProfile
				}
			}
			# Add the lines to the $PROFILE for PowerShell
			powershell.exe -Command $ScriptBlock
			# Do the same for PowerShell Core
			pwsh.exe -Command $ScriptBlock
		} catch {
			Write-Host  'Something went wrong while trying to configure $PROFILE for Powerline.' | Write-Warning
			Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
		}
		refreshenv
	} catch {
		Write-Host  'Powerline failed to install' | Write-Warning
		Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
		# Move on if Powerline install fails due to error
	}


	#--- Install & Configure the PSReadline Module
	try {
		Write-Host 'Installing PSReadLine -- [Bash-like CLI features and Optional Dependency for Powerline]'
		if (-Not(Get-Module -ListAvailable -Name PSReadLine)) {
			Install-Module -Name PSReadLine -Scope AllUsers -AllowClobber -SkipPublisherCheck -Force -Verbose
		} else { Write-Host "Module 'PSReadLine' already installed" }
		refreshenv
		try {
			$ScriptBlock = {
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
				if (-Not(Select-String -Pattern $PSReadlineProfile[0] -Path $PROFILE)) {
					Write-Output 'Attempting to add the following lines to $PROFILE :' | Write-Debug
					Write-Output $PSReadlineProfile | Write-Debug
					Add-Content -Path $PROFILE -Value $PSReadlineProfile
				}
			}
			# Add the lines to the $PROFILE for PowerShell
			powershell.exe -Command $ScriptBlock
			# Do the same for PowerShell Core
			pwsh.exe -Command $ScriptBlock
		} catch {
			Write-Host  'Something went wrong while trying to configure $PROFILE for PSReadline.' | Write-Warning
			Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
		}
		refreshenv
	} catch {
		Write-Host  'PSReadline failed to install' | Write-Warning
		Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
		# Move on if PSReadline install fails due to errors
	}


	#--- Install the Pipeworks Module
	try {
		Write-Host 'Installing Pipeworks -- [CLI Tools for PowerShell]'
		Write-Host 'Description: PowerShell Pipeworks is a framework for writing Sites and Software Services in Windows PowerShell modules.'
		if (-Not(Get-Module -ListAvailable -Name Pipeworks)) {
			Install-Module -Name Pipeworks -Scope AllUsers -AllowClobber -SkipPublisherCheck -Force -Verbose
		} else { Write-Host "Module 'Pipeworks' already installed" }
		refreshenv
	} catch {
		Write-Host  'Pipeworks failed to install' | Write-Warning
		Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
		# Move on if Pipeworks install fails due to errors
	}


	#--- Install the CredentialManager Module
	try {
		Write-Host 'Installing CredentialManager'
		Write-Host 'Description: Provides access to credentials in the Windows Credential Manager.'
		if (-Not(Get-Module -ListAvailable -Name CredentialManager)) {
			Install-Module -Name CredentialManager
		} else { Write-Host "Module 'CredentialManager' already installed" }
		refreshenv
	} catch {
		Write-Host  'CredentialManager failed to install' | Write-Warning
		Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
		# Move on if CredentialManager install fails due to errors
	}


	#--- Import Chocolatey Modules
	try {
		$ScriptBlock = {
			Write-Host 'Appending Configuration for Chocolatey to PowerShell Profile...'
			$ChocolateyProfile = @(
				'# Chocolatey profile',
				'$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"',
				'if (Test-Path($ChocolateyProfile)) {'
				'	Import-Module "$ChocolateyProfile"'
				'}'
			)
			Write-Host >> $PROFILE # This will create the file if it does not already exist, otherwise it will leave the existing file unchanged
			if (-Not(Select-String -Pattern $ChocolateyProfile[0] -Path $PROFILE)) {
				Write-Output 'Attempting to add the following lines to $PROFILE :' | Write-Debug
				Write-Output $ChocolateyProfile | Write-Debug
				Add-Content -Path $PROFILE -Value $ChocolateyProfile
			}
		}
		# Add the lines to the $PROFILE for PowerShell
		powershell.exe -Command $ScriptBlock
		# Do the same for PowerShell Core
		pwsh.exe -Command $ScriptBlock
	} catch {
		Write-Host  'Something went wrong while trying to configure $PROFILE for Chocolatey.' | Write-Warning
		Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
	}


	# #--- Import Boxstarter Modules
	# try {
	# 	$ScriptBlock = {
	# 		Write-Host 'Appending Configuration for Boxstarter to PowerShell Profile...'
	# 		$BoxstarterProfile = @(
	# 			'# Boxstarter modules',
	# 			'# Import the Chocolatey module first so that $Boxstarter properties',
	# 			'# are initialized correctly and then import everything else.',
	# 			'if (Test-Path("\\GRIFFINUNRAID\Boxstarter")) {',
	# 			'	$BoxstarterInstall = "\\GRIFFINUNRAID\Boxstarter"',
	# 			'} elseif (Test-Path("D:\Boxstarter")) {',
	# 			'	$BoxstarterInstall = "D:\Boxstarter"',
	# 			'}',
	# 			'Import-Module $BoxstarterInstall\Boxstarter.Chocolatey\Boxstarter.Chocolatey.psd1 -DisableNameChecking -ErrorAction SilentlyContinue',
	# 			'Resolve-Path $BoxstarterInstall\Boxstarter.*\*.psd1 |',
	# 			'	% { Import-Module $_.ProviderPath -DisableNameChecking -ErrorAction SilentlyContinue }',
	# 			'Import-Module $BoxstarterInstall\Boxstarter.Common\Boxstarter.Common.psd1 -Function Test-Admin'
	# 		)
	# 		Write-Host >> $PROFILE # This will create the file if it does not already exist, otherwise it will leave the existing file unchanged
	# 		if (-Not(Select-String -Pattern $BoxstarterProfile[0] -Path $PROFILE)) {
	# 			Write-Output 'Attempting to add the following lines to $PROFILE :' | Write-Debug
	# 			Write-Output $BoxstarterProfile | Write-Debug
	# 			Add-Content -Path $PROFILE -Value $BoxstarterProfile
	# 		}
	# 	}
	# 	# Add the lines to the $PROFILE for PowerShell
	# 	powershell.exe -Command $ScriptBlock
	# 	# Do the same for PowerShell Core
	# 	pwsh.exe -Command $ScriptBlock
	# } catch {
	# 	Write-Host  'Something went wrong while trying to configure $PROFILE for Boxstarter.' | Write-Warning
	# 	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
	# }


	Enable-UAC
	Enable-MicrosoftUpdate
	Install-WindowsUpdate -acceptEula

	if (Test-Path $MapNetworkDriveScript) {
		Write-Host 'You must manually run the' $MapNetworkDriveScript 'script again as your non-admin user in order for the mapped drives to be visible in the File Explorer'
	}

	Write-Host 'nerdygriffin.Configure-PowerShell completed successfully' | Write-Debug
	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
} catch {
	Write-Host 'Error occurred in nerdygriffin.Configure-PowerShell' $($_.Exception.Message) | Write-Debug
	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
	throw $_.Exception
}