Function MergeMove-Directory {
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

Function Create-SymLink {
	param(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Path,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Value
	)

	if (MergeMove-Directory -Path $Path -Destination $Value) {
		Return (New-Item -Path $Path -ItemType SymbolicLink -Value $Value -Force -Verbose -ErrorAction Stop)
	}
}

Function Create-Junction {
	param(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Path,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Value
	)

	if (MergeMove-Directory -Path $Path -Destination $Value) {
		Return (New-Item -Path $Path -ItemType Junction -Value $Value -Force -Verbose -ErrorAction Stop)
	}
}
