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
		Write-Warning $Path 'is already a reparse point.'
		Return $false
	} elseif (Test-Path "$Path\*") {
		# $MoveResult = (Move-Item -Path $Path\* -Destination $Destination -Force -PassThru -Verbose -ErrorAction Stop)
		$MoveResult = (robocopy $Path $Destination /ZB /FFT)
		if (-Not($MoveResult)) {
			Write-Warning 'Something went wrong while trying to move the contents of' $Path 'to' $Value
			Return $MoveResult
		}
		Remove-Item -Path $Path\* -Recurse -Force -ErrorAction Inquire
	}
	Return (New-Item -Path $Path -ItemType SymbolicLink -Value $Value -Force -Verbose -ErrorAction Stop)
}

try {
	Disable-UAC

	if (-Not(Get-Command New-SymLink)) {
		Write-Error "The 'New-SymLink' helper function was not found."
		throw
	}

	if (Test-Path 'D:\') {
		# SymbolicLinks in AppData
		foreach ($FolderName in @('.minecraft', 'Citra')) {
			New-SymLink -Path (Join-Path $env:APPDATA $FolderName) -Value (Join-Path 'D:\' $FolderName)
		}

		# SymbolicLinks in ProgramFiles
		$SymbolicLinkNames = @(
			'Cemu Emulator',
			'Dolphin',
			'Steam'
		)
		if ($env:USERDOMAIN | Select-String 'DESKTOP') {
			$SymbolicLinkNames += @(
				'Epic Games',
				'GOG Galaxy',
				'Origin',
				'Rockstar Games',
				'Ubisoft',
				'Unity Hub',
				'Unity'
			)
		}
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
	choco install -y vortex

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

	Write-Debug 'nerdygriffin.Gaming completed successfully'
	Write-Debug ' See the log for details (' $Boxstarter.Log ').'
} catch {
	Write-Debug 'Error occurred in nerdygriffin.Gaming' $($_.Exception.Message)
	Write-Debug ' See the log for details (' $Boxstarter.Log ').'
	throw $_.Exception
}