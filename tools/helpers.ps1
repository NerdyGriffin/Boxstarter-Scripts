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

Function New-Junction {
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
	Return (New-Item -Path $Path -ItemType Junction -Value $Value -Force -Verbose -ErrorAction Stop)
}
