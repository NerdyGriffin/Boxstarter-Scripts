$Boxstarter.StopOnPackageFailure = $false

Function New-SymbolicLink {
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
	}
	if (Test-Path "$Path\*") {
		# $MoveResult = (Move-Item -Path $Path\* -Destination $Value -Force -PassThru -Verbose)
		$MoveResult = (robocopy $Path $Value /ZB /FFT)
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
		Write-Host  'Successfully created SymLink at' $Path 'pointing to' $Value | Write-Verbose
		Return $true
	} else {
		Write-Host 'The following error occured while trying to make symlink: ' $Result | Write-Warning
		Return $false
	}
}

Function New-LibraryLinks {
	param(
		# Specifies the path of the location of the new link. You must exclude the name of the new link in Path .
		[Parameter(Mandatory = $true,
			Position = 0,
			ParameterSetName = 'ParameterSetName',
			ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true,
			HelpMessage = 'Specifies the path of the location of the new link. You must exclude the name of the new link in Path .')]
		[Alias('PSPath')]
		[ValidateNotNullOrEmpty()]
		[string]
		$Path,

		[Parameter(Mandatory = $true,
			Position = 1,
			HelpMessage = 'Specifies the name of the new link.')]
		[Alias('LinkName')]
		[ValidateNotNullOrEmpty()]
		[string]
		$Name,

		# Specifies the path of the location that you would like the link to point to.
		[Parameter(Mandatory = $true,
			Position = 2,
			HelpMessage = 'Specifies the path of the location that you would like the link to point to.')]
		[Alias('Target')]
		[ValidateNotNullOrEmpty()]
		[string]
		$Value
	)

	$PossibleLinkPaths = @(
		(Join-Path $env:USERPROFILE "$Name"),
		(Join-Path (Split-Path -Path "$Path" -Parent) "$Name")
	)

	# TODO: Add a check that (Split-Path -Path "$Path" -Qualifier) is not a mapped network drive

	$DownloadsPath = ((Get-LibraryNames).'{374DE290-123F-4565-9164-39C4925E467B}')
	if (-Not("$Path".ToLower().StartsWith("$DownloadsPath".ToLower()))) {
		$PossibleLinkPaths += (Join-Path "$Path" "$Name")
	}

	$PossibleLinkPaths

	foreach ($LinkPath in $PossibleLinkPaths) {
		if (-Not(Test-Path "$LinkPath")) {
			New-Item -Path "$LinkPath" -ItemType SymbolicLink -Value "$Value" -Verbose -ErrorAction SilentlyContinue
		}
	}
}

Disable-UAC

$ServerRootPath = '\\GRIFFINUNRAID\'
$ServerMediaShare = (Join-Path $ServerRootPath 'media')
$ServerDocumentsShare = (Join-Path $ServerRootPath 'personal\Documents')
$ServerDownloadsShare = (Join-Path $ServerRootPath 'personal\Downloads')
$MapNetworkDriveScript = '\\GRIFFINUNRAID\scripts\MapNetworkDrives.ps1'

if ($env:Username -contains 'Public') {
	Write-Host  'Somehow the current username is "Public"...', '  That should not be possible, so the libraries will not be moved.' | Write-Warning
} else {
	if (Test-Path $MapNetworkDriveScript) {
		Invoke-Expression $MapNetworkDriveScript
	}

	$LibrariesToMove = @('My Music', 'My Pictures', 'My Video')

	if (Test-Path 'D:\') {
		Write-Host 'Moving Library Directories to D:\ ...'

		$PSBootDrive = Get-PSDrive C
		# Only move the documents folder if the boot drive of this computer is smaller than the given threshold
		if (($PSBootDrive.Used + $PSBootDrive.Free) -lt (0.5TB)) {
			$LibrariesToMove += 'Documents'
			$LibrariesToMove += 'Downloads'
			$LibrariesToMove += '{374DE290-123F-4565-9164-39C4925E467B}' # This is a name for the downloads library... I have no idea why it does not use an alias
		}

		$LibrariesToMove | ForEach-Object {
			$Source = ''
			$Source = (Get-LibraryNames).$_
			if ($Source) {
				$Destination = (Join-Path 'D:\' (Split-Path -Path $Source -NoQualifier)) # Convert all the existing library paths from 'C:\' to 'D:\'
				Write-Output "Moving library ""$_"" from ""$Source"" to ""$Destination""" | Write-Verbose
				Move-LibraryDirectory -libraryName $_ -newPath $Destination -ErrorAction SilentlyContinue
				New-SymbolicLink -Path $Source -Value $Destination -ErrorAction SilentlyContinue
			}
		}
	}

	if (Test-Path $ServerMediaShare) {
		Write-Host 'Making Symbolic Links to media server shares...'
		@('My Music', 'My Pictures', 'My Video') | ForEach-Object {
			$LibraryPath = (Get-LibraryNames).$_
			$LibraryName = Split-Path -Path $LibraryPath -Leaf -Resolve
			$LinkName = "Server$LibraryName"
			$LinkTarget = (Join-Path "$ServerMediaShare" "$_")
			New-LibraryLinks -Path "$LibraryPath" -Name "$LinkName" -Value "$LinkTarget"
		}
	}

	if (Test-Path $ServerDocumentsShare) {
		Write-Host 'Making Symbolic Links to documents server share...'
		$DocumentsPath = ((Get-LibraryNames).Personal)
		New-LibraryLinks -Path "$DocumentsPath" -Name 'ServerDocuments' -Value "$ServerDocumentsShare"
	}

	$DownloadsShareLinkTarget = ''
	$MappedDownloadsPath = 'X:\Downloads'
	if (Test-Path $MappedDownloadsPath) {
		$DownloadsShareLinkTarget = $MappedDownloadsPath
	} elseif (Test-Path $ServerDownloadsShare) {
		$DownloadsShareLinkTarget = $ServerDownloadsShare
	}

	$DownloadsPath = ((Get-LibraryNames).'{374DE290-123F-4565-9164-39C4925E467B}')
	if ($DownloadsShareLinkTarget) {
		Write-Host 'Making Symbolic Links to downloads server share...'
		New-LibraryLinks -Path "$DownloadsPath" -Name 'ServerDownloads' -Value "$DownloadsShareLinkTarget"
	}
}

if (Test-Path $MapNetworkDriveScript) {
	Write-Host 'You must manually run the' $MapNetworkDriveScript 'script again as your non-admin user in order for the mapped drives to be visible in the File Explorer'
}

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula

if (Test-Path $MapNetworkDriveScript) {
	Write-Host 'You must manually run the' $MapNetworkDriveScript 'script again as your non-admin user in order for the mapped drives to be visible in the File Explorer'
}
