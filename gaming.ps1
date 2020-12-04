try {
	Disable-UAC

	# TODO: Replace with the install of the custom module once it has been fully implemented
	#--- vvv Temporary vvv ---
	Function Merge-And-Move-Dir {
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Path,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Destination

		if (Test-Path $Path) {
			if (Get-Item $Path | Where-Object Attributes -Match ReparsePoint) {
				Write-Warning $Path 'Is already a reparse point.'
				Return $false
			}
			if (Test-Path $Destination) {
				Get-ChildItem $Path | ForEach-Object -Process {
					Copy-Item -Path (Join-Path $Path $_) -Destination $Destination -Force -Recurse -Verbose
				}
				Remove-Item -Path $Path -Recurse -Force -Verbose -ErrorAction Stop
				Return $true
			} else {
				Return (Move-Item -Path $Path -Destination $Destination -Force -PassThru -Verbose -ErrorAction Stop)
			}
		} elseif (-Not(Test-Path $Destination)) {
			Return (New-Item -Path $Destination -Type Directory -Force -Verbose -ErrorAction Stop)
		} else {
			Return (Get-Item -Path $Destination)
		}
		Return $false
	}

	Function New-SymLink {
		param(
			[Parameter(Mandatory)]
			[ValidateNotNullOrEmpty()]
			[string]$Path,

			[Parameter(Mandatory)]
			[ValidateNotNullOrEmpty()]
			[string]$Value
		)

		if (Merge-And-Move-Dir -Path $Path -Destination $Value) {
			Return (New-Item -Path $Path -ItemType SymbolicLink -Value $Value -Force -Verbose -ErrorAction Stop)
		}
	}

	Function New-Junction {
		param(
			[Parameter(Mandatory)]
			[ValidateNotNullOrEmpty()]
			[string]$Path,

			[Parameter(Mandatory)]
			[ValidateNotNullOrEmpty()]
			[string]$Value
		)

		if (Merge-And-Move-Dir -Path $Path -Destination $Value) {
			Return (New-Item -Path $Path -ItemType Junction -Value $Value -Force -Verbose -ErrorAction Stop)
		}
	}
	#--- ^^^ Temporary ^^^ ---

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

	Enable-MicrosoftUpdate
	Install-WindowsUpdate -acceptEula

	Write-Debug 'The script completed successfully' -ForegroundColor Green
	Write-ChocolateySuccess 'nerdygriffin.Test'
} catch {
	Write-ChocolateyFailure 'nerdygriffin.Test' $($_.Exception.Message)
	throw
}