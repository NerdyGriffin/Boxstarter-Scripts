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
		Move-LibraryDirectory 'Personal' (Join-Path 'D:\Users' $env:Username 'Documents')
		New-SymLink -Path (Join-Path $env:UserProfile 'Documents') -Value (Join-Path 'D:\Users' $env:Username 'Documents') -ErrorAction SilentlyContinue
		# New-SymLink -Path "D:\Documents" -Value (Join-Path 'D:\Users' $env:Username 'Documents') -ErrorAction SilentlyContinue
	}

	if ((Get-ComputerName | Select-String 'DESKTOP') -And (Test-Path '\\GRIFFINUNRAID\media\')) {
		Move-LibraryDirectory 'My Music' '\\GRIFFINUNRAID\media\Music' -ErrorAction SilentlyContinue
		New-SymLink -Path (Join-Path $env:UserProfile 'Music') -Value '\\GRIFFINUNRAID\media\Music' -ErrorAction SilentlyContinue

		Move-LibraryDirectory 'My Pictures' '\\GRIFFINUNRAID\media\Pictures' -ErrorAction SilentlyContinue
		New-SymLink -Path (Join-Path $env:UserProfile 'Music') -Value '\\GRIFFINUNRAID\media\Pictures' -ErrorAction SilentlyContinue

		Move-LibraryDirectory 'My Video' '\\GRIFFINUNRAID\media\Videos' -ErrorAction SilentlyContinue
		New-SymLink -Path (Join-Path $env:UserProfile 'Music') -Value '\\GRIFFINUNRAID\media\Videos' -ErrorAction SilentlyContinue
	} elseif (Test-Path 'D:\') {
		Move-LibraryDirectory 'My Music' (Join-Path 'D:\Users' $env:Username 'Music') -ErrorAction SilentlyContinue
		New-SymLink -Path (Join-Path $env:UserProfile 'Music') -Value (Join-Path 'D:\Users' $env:Username 'Music') -ErrorAction SilentlyContinue

		Move-LibraryDirectory 'My Pictures' (Join-Path 'D:\Users' $env:Username 'Pictures') -ErrorAction SilentlyContinue
		New-SymLink -Path (Join-Path $env:UserProfile 'Pictures') -Value (Join-Path 'D:\Users' $env:Username 'Pictures') -ErrorAction SilentlyContinue

		Move-LibraryDirectory 'My Video' (Join-Path 'D:\Users' $env:Username 'Videos') -ErrorAction SilentlyContinue
		New-SymLink -Path (Join-Path $env:UserProfile 'Videos') -Value (Join-Path 'D:\Users' $env:Username 'Videos') -ErrorAction SilentlyContinue
	}

	if ((Get-ComputerName | Select-String 'DESKTOP') -And (Test-Path '\\GRIFFINUNRAID\personal\')) {
		Move-LibraryDirectory 'Downloads' '\\GRIFFINUNRAID\personal\Downloads' -ErrorAction SilentlyContinue
		New-SymLink -Path (Join-Path $env:UserProfile 'Downloads') -Value '\\GRIFFINUNRAID\personal\Downloads' -ErrorAction SilentlyContinue
	} elseif (Test-Path 'D:\') {
		Move-LibraryDirectory 'Downloads' (Join-Path 'D:\Users' $env:Username 'Downloads') -ErrorAction SilentlyContinue
		New-SymLink -Path (Join-Path $env:UserProfile 'Downloads') -Value (Join-Path 'D:\Users' $env:Username 'Downloads') -ErrorAction SilentlyContinue
	}

	Write-Debug 'The script completed successfully' -ForegroundColor Green
	Write-ChocolateySuccess 'nerdygriffin.Test'
} catch {
	Write-ChocolateyFailure 'nerdygriffin.Test' $($_.Exception.Message)
	throw
}