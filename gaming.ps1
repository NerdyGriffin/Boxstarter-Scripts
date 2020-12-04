try {
	Disable-UAC

	if (-Not(Get-Command Create-SymLink)) {
		Write-Error "The 'Create-SymLink' helper function was not found."
	}

	if (Test-Path 'D:\') {
		# SymbolicLinks in AppData
		foreach ($FolderName in @('.minecraft', 'Citra')) {
			Create-SymLink -Path (Join-Path $env:APPDATA $FolderName) -Value (Join-Path 'D:\' $FolderName)
		}

		# SymbolicLinks in ProgramFiles
		$SymbolicLinkNames = @(
			'Cemu Emulator',
			'Dolphin',
			'Steam'
		)
		if (Get-ComputerName | Select-String 'DESKTOP') {
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
				Create-SymLink -Path (Join-Path $ProgramFiles $FolderName) -Value (Join-Path 'D:\' $FolderName)
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

	if (Get-ComputerName | Select-String 'DESKTOP') {
		#--- Corsair ---
		choco install -y icue

		#--- Game Launchers for desktop only ---
		choco install -y epicgameslauncher
		choco install -y goggalaxy
		choco install -y origin
		choco install -y twitch
		choco install -y uplay

		#--- Game Engines ---
		choco install -y unity
		choco install -y unity-hub
	}

	#--- Windows Settings ---
	Disable-BingSearch
	Disable-GameBarTips

	Enable-UAC
	Enable-MicrosoftUpdate
	Install-WindowsUpdate -acceptEula

	Write-Debug 'The script completed successfully' -ForegroundColor Green
	Write-ChocolateySuccess 'nerdygriffin.Gaming'
} catch {
	Write-ChocolateyFailure 'nerdygriffin.Gaming' $($_.Exception.Message)
	throw
}