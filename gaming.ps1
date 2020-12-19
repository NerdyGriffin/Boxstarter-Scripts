Function New-SymLink {
	param(
		# Specifies the path of the location of the new link. You must include the name of the new link in Path .
		[Parameter(Mandatory = $true,
			Position = 0,
			ParameterSetName = 'ParameterSetName',
			ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true,
			HelpMessage = 'Specifies the path of the location of the new link. You must include the name of the new link in Path .')]
		[Alias('PSPath')]
		[ValidateNotNullOrEmpty()]
		[string]
		$Path,

		# Specifies the path of the location that you would like the link to point to.
		[Parameter(Mandatory = $true,
			Position = 1,
			HelpMessage = 'Specifies the path of the location that you would like the link to point to.')]
		[Alias('Target')]
		[ValidateNotNullOrEmpty()]
		[string]
		$Value
	)

	if ((Test-Path $Path) -And (Get-Item $Path | Where-Object Attributes -Match ReparsePoint)) {
		Write-Host  $Path 'is already a reparse point.' | Write-Warning
		Return $false
	} elseif (Test-Path "$Path\*") {
		# $MoveResult = (Move-Item -Path $Path\* -Destination $Destination -Force -PassThru -Verbose)
		$MoveResult = (robocopy $Path $Destination /ZB /FFT)
		if (-Not($MoveResult)) {
			Write-Host  'Something went wrong while trying to move the contents of' $Path 'to' $Value | Write-Warning
			Return $MoveResult
		}
		Remove-Item -Path $Path\* -Recurse -Force -ErrorAction Inquire
	}
	if (Test-Path $Path) {
		Remove-Item $Path -Recurse -Force
	}
	if (-Not(Test-Path $Value)) {
		New-Item -Path $Value -ItemType Directory
	}
	$Result = New-Item -Path $Path -ItemType SymbolicLink -Value $Value -Force -Verbose
	if ($Result) {
		Return $true
	} else {
		Write-Host 'The following error occured while trying to make symlink: ' $Result | Write-Warning
		Return $false
	}
}

try {
	Disable-UAC

	if (-Not(Get-Command New-SymLink)) {
		Write-Error "The 'New-SymLink' helper function was not found."
		throw
	}

	if (Test-Path 'D:\') {
		# SymbolicLinks in AppData
		$SymbolicLinkNames = @('Citra')
		if ($env:USERDOMAIN | Select-String 'LAPTOP') { $SymbolicLinkNames += @('.minecraft') }
		foreach ($FolderName in $SymbolicLinkNames) {
			New-SymLink -Path (Join-Path $env:APPDATA $FolderName) -Value (Join-Path 'D:\' $FolderName)
		}

		# SymbolicLinks in ProgramFiles
		$SymbolicLinkNames = @(
			# 'Cemu Emulator',
			'Dolphin'
			# 'Steam'
		)
		# if ($env:USERDOMAIN | Select-String 'DESKTOP') {
		# 	$SymbolicLinkNames += @(
		# 		'Epic Games',
		# 		'GOG Galaxy',
		# 		'Origin',
		# 		'Rockstar Games',
		# 		'Ubisoft',
		# 		'Unity Hub',
		# 		'Unity'
		# 	)
		# }
		foreach ($ProgramFiles in @( $env:ProgramFiles, ${env:ProgramFiles(x86)} )) {
			foreach ($FolderName in $SymbolicLinkNames) {
				New-SymLink -Path (Join-Path $ProgramFiles $FolderName) -Value (Join-Path 'D:\' $FolderName)
			}
		}
	}

	#--- Logitech Gaming Software ---
	choco install -y logitechgaming

	#--- Nvidia Graphics ---
	choco install -y geforce-experience

	#--- Hardware Monitoring ---
	choco install -y cpu-z
	choco install -y gpu-z
	choco install -y hwinfo
	choco install -y hwmonitor
	choco install -y msiafterburner

	#--- Benchmarks ---
	choco install -y furmark
	choco install -y heaven-benchmark
	choco install -y valley-benchmark
	choco install -y superposition-benchmark

	#--- Game Launchers ---
	choco install -y cemu
	choco install -y dolphin
	choco install -y minecraft-launcher
	choco install -y steam
	choco install -y steam-cleaner
	choco install -y steamlibrarymanager.portable

	#--- Mods & Cheats
	choco install -y cheatengine
	choco install -y vortex
	choco install -y wemod

	if ($env:USERDOMAIN | Select-String 'DESKTOP') {
		#--- Corsair ---
		choco install -y icue

		#--- Game Launchers for desktop only ---
		choco install -y epicgameslauncher
		choco install -y goggalaxy
		choco install -y origin
		choco install -y twitch
		choco install -y uplay

		#--- Game Engines ---
		# choco install -y unity
		# choco install -y unity-hub
	}

	Enable-UAC
	Enable-MicrosoftUpdate
	Install-WindowsUpdate -acceptEula

	Write-Host 'nerdygriffin.Gaming completed successfully' | Write-Debug
	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
} catch {
	Write-Host 'Error occurred in nerdygriffin.Gaming' $($_.Exception.Message) | Write-Debug
	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
	throw $_.Exception
}