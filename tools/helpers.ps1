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
	if (-Not(Test-Path $Value)) {
		New-Item -Path $Value -ItemType Directory
	}
	$Result = New-Item -Path $Path -ItemType Junction -Value $Value -Force -Verbose
	if ($Result) {
		Return $true
	} else {
		Write-Host 'The following error occured while trying to make symlink: ' $Result | Write-Warning
		Return $false
	}
}
