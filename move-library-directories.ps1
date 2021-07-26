If ($Boxstarter.StopOnPackageFailure) { $Boxstarter.StopOnPackageFailure = $false }

choco upgrade -y boxstarter

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

	if ("$Path" | Select-String -SimpleMatch "$Value") {
		Write-Warning "The link path cannot be the same as the link target! `n  Path: $Path `nTarget: $Value" | Write-Host
		Return $false
	} elseif ((Test-Path $Path -ErrorAction SilentlyContinue) -and (Get-Item $Path -ErrorAction SilentlyContinue | Where-Object Attributes -Match ReparsePoint)) {
		Write-Warning "'$Path' is already a reparse point." | Write-Host
		Return $false
	} else {
		if (Test-Path "$Path\*") {
			# $MoveResult = (Move-Item -Path $Path\* -Destination $Value -Force -PassThru -Verbose)
			$MoveResult = (robocopy "$Path" "$Value" /ZB /FFT)
			if (-not($MoveResult)) {
				Write-Warning "Something went wrong while trying to move the contents of '$Path' to '$Value'" | Write-Host
				Return $MoveResult
			} else {
				Remove-Item -Path $Path\* -Recurse -Force
			}
		}
		if (Test-Path $Path) {
			Remove-Item $Path -Recurse -Force
		}
		if (-not(Test-Path $Value)) {
			New-Item -Path $Value -ItemType Directory
		}
		$Result = New-Item -Path $Path -ItemType SymbolicLink -Value $Value -Force -Verbose
		if ($Result) {
			Write-Host "Successfully created SymLink $Path --> $Value" | Write-Host
			Return $true
		} else {
			Write-Warning "The following error occured while trying to make symlink: $Result" | Write-Host
			Return $false
		}
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

	# TODO: Add a check that (Split-Path -Path "$Path" -Qualifier) is not a mapped network drive

	$DownloadsPath = ((Get-LibraryNames).'{374DE290-123F-4565-9164-39C4925E467B}')

	@( ($env:USERPROFILE), (Split-Path -Path $Path -Parent), ($Path) ) | ForEach-Object {
		$LinkPath = (Join-Path $_ $Name)
		if (Test-Path $LinkPath) {
			Write-Host "Path already exists: $LinkPath"
		} elseif ("$_" | Select-String -SimpleMatch "$DownloadsPath" -NotMatch) {
			Write-Host "Creating new SymLink: '$LinkPath' --> '$Value'"
			New-Item -Path $_ -Name $Name -ItemType SymbolicLink -Value $Value -Verbose -ErrorAction SilentlyContinue
		}
	}
}

Disable-UAC

#--- Enable Powershell Script Execution
Set-ExecutionPolicy Bypass -Scope CurrentUser -Force
refreshenv

$SMBServerName = '\\GRIFFINUNRAID\'
$ServerMediaShare = (Join-Path $SMBServerName 'media')
$ServerDocumentsShare = (Join-Path $SMBServerName 'personal\Documents')
$ServerDownloadsShare = (Join-Path $SMBServerName 'personal\Downloads')
$MapNetworkDriveScript = '\\GRIFFINUNRAID\scripts\MapNetworkDrives.ps1'

if ("$env:Username" -like '*Public*') {
	Write-Warning 'Somehow the current username is "Public"...`n  That should not be possible, so the libraries will not be moved.'
} else {
	if (Test-Path $MapNetworkDriveScript) {
		Invoke-Expression $MapNetworkDriveScript -ErrorAction Continue
	}

	$LibrariesToMove = @('My Music', 'My Pictures', 'My Video')

	$NewDrive = 'D:'
	if (Test-Path "$NewDrive") {
		Write-Host "Moving Library Directories to '$NewDrive' ..."

		$PSBootDrive = Get-PSDrive C
		# Only move the documents folder if the boot drive of this computer is smaller than the given threshold
		if (($PSBootDrive.Used + $PSBootDrive.Free) -lt (0.5TB)) {
			# $LibrariesToMove += 'Documents'
			$LibrariesToMove += 'Downloads'
			$LibrariesToMove += '{374DE290-123F-4565-9164-39C4925E467B}' # This is a name for the downloads library... I have no idea why it does not use an alias
		}

		$LibrariesToMove | ForEach-Object {
			$PrevLibraryPath = ''
			$PrevLibraryPath = (Get-LibraryNames).$_
			if (($PrevLibraryPath) -and (Split-Path -Path "$PrevLibraryPath" -Qualifier | Select-String -NotMatch "$NewDrive")) {
				$NewLibraryPath = (Join-Path "$NewDrive" (Split-Path -Path $PrevLibraryPath -NoQualifier)) # Convert all the existing library paths from 'C:\' to 'D:\'
				# $FolderName = (Split-Path -Path $PrevLibraryPath -Leaf -Resolve)
				# $LinkPath = (Join-Path "$env:USERPROFILE" "$FolderName")
				Write-Host "Moving library ""$_"" from ""$PrevLibraryPath"" to ""$NewLibraryPath""..."
				Move-LibraryDirectory -libraryName $_ -newPath $NewLibraryPath -ErrorAction Continue
				Write-Host "Attempting to create SymLink '$PrevLibraryPath' --> '$NewLibraryPath'..."
				New-SymbolicLink -Path $PrevLibraryPath -Value $NewLibraryPath -ErrorAction Continue
			}
		}
	}

	RefreshEnv;
	Start-Sleep -Seconds 1;

	if (Test-Path $ServerMediaShare) {
		Write-Host 'Making Symbolic Links to media server shares...'
		# @('My Music', 'My Pictures', 'My Video') | ForEach-Object {
		@('My Music', 'My Video') | ForEach-Object {
			$LibraryPath = (Get-LibraryNames).$_
			$LibraryName = (Split-Path -Path $LibraryPath -Leaf -Resolve)
			$LinkName = "Server$LibraryName"
			$LinkTarget = (Join-Path "$ServerMediaShare" "$LibraryName")
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

	if ($DownloadsShareLinkTarget) {
		$DownloadsPath = ((Get-LibraryNames).'{374DE290-123F-4565-9164-39C4925E467B}')
		Write-Host 'Making Symbolic Links to downloads server share...'
		New-LibraryLinks -Path "$DownloadsPath" -Name 'ServerDownloads' -Value "$DownloadsShareLinkTarget"
	}
}

$MapNetworkDriveMessage = "You must manually run the '$MapNetworkDriveScript' script again as your non-admin user in order for the mapped drives to be visible in the File Explorer"

if (Test-Path $MapNetworkDriveScript) {
	Write-Host "$MapNetworkDriveMessage"
}

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula

if (Test-Path $MapNetworkDriveScript) {
	Write-Host "$MapNetworkDriveMessage"
}
