$Boxstarter.StopOnPackageFailure = $false

class LibraryInfo {
	[Alias('Name')]
	[ValidateNotNullOrEmpty()]
	[string]
	$LibraryName # The name of the library (must match the expected syntax of Move-LibraryDirectory)

	[Alias('PSPath')]
	[ValidateNotNullOrEmpty()]
	[string]
	$OriginalPath # The original (default) path to the library

	[Alias('Destination')]
	[ValidateNotNullOrEmpty()]
	[string]
	$DestinationPath # The destination path where you would like the library to be moved

	# Class Constructor
	LibraryInfo(
		[string]$name,
		[string]$path
	) {
		$this.LibraryName = $name
		$this.OriginalPath = $path
		$this.DestinationPath = $path
	}
}

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

# try {
Disable-UAC

$ServerRootPath = '\\GRIFFINUNRAID\'
$ServerMediaShare = (Join-Path $ServerRootPath 'media')
$ServerDownloadsShare = (Join-Path $ServerRootPath 'personal\Downloads')
$MapNetworkDriveScript = '\\GRIFFINUNRAID\scripts\MapNetworkDrives.ps1'

if ($env:Username -contains 'Public') {
	Write-Host  'Somehow the current username is "Public"...', '  That should not be possible, so the libraries will not be moved.' | Write-Warning
} else {
	if (Test-Path $MapNetworkDriveScript) {
		Invoke-Expression $MapNetworkDriveScript
	}

	$LibraryHashTable = @{
		'Music'     = [LibraryInfo]::new('My Music', (Join-Path $env:UserProfile 'Music'));
		'Pictures'  = [LibraryInfo]::new('My Pictures', (Join-Path $env:UserProfile 'Pictures'));
		'Videos'    = [LibraryInfo]::new('My Video', (Join-Path $env:UserProfile 'Videos'));
		'Downloads' = [LibraryInfo]::new('Downloads', (Join-Path $env:UserProfile 'Downloads'));
		'Documents' = [LibraryInfo]::new('Personal', (Join-Path $env:UserProfile 'Documents'))
	}

	$IsDesktop = ($env:USERDOMAIN | Select-String 'DESKTOP')

	if (($IsDesktop) -And (Test-Path $ServerMediaShare)) {
		Write-Host 'Moving Library Directories to server shares...'

		$LibraryHashTable['Music'].DestinationPath = (Join-Path $ServerMediaShare 'Music')
		$LibraryHashTable['Pictures'].DestinationPath = (Join-Path $ServerMediaShare 'Pictures')
		$LibraryHashTable['Videos'].DestinationPath = (Join-Path $ServerMediaShare 'Videos')
	} elseif (Test-Path 'D:\') {
		Write-Host 'Moving Library Directories to D:\ ...'

		$LibraryHashTable['Music'].DestinationPath = (Join-Path 'D:\' (Split-Path -Path ($LibraryHashTable['Music'].OriginalPath) -NoQualifier))
		$LibraryHashTable['Pictures'].DestinationPath = (Join-Path 'D:\' (Split-Path -Path ($LibraryHashTable['Pictures'].OriginalPath) -NoQualifier))
		$LibraryHashTable['Videos'].DestinationPath = (Join-Path 'D:\' (Split-Path -Path ($LibraryHashTable['Videos'].OriginalPath) -NoQualifier))
	}

	$MappedDownloadsPath = 'X:\Downloads'
	if (($IsDesktop) -And (Test-Path $MappedDownloadsPath)) {
		$LibraryHashTable['Downloads'].DestinationPath = $MappedDownloadsPath
	} elseif (($IsDesktop) -And (Test-Path $ServerDownloadsShare)) {
		$LibraryHashTable['Downloads'].DestinationPath = $ServerDownloadsShare
	} elseif (Test-Path 'D:\') {
		$PSBootDrive = Get-PSDrive C
		# Only move the documents folder if the boot drive of this computer is smaller than the given threshold
		if (($PSBootDrive.Used + $PSBootDrive.Free) -lt (0.5TB)) {
			$LibraryHashTable['Documents'].DestinationPath = (Join-Path 'D:\' (Split-Path -Path ($LibraryHashTable['Documents'].OriginalPath) -NoQualifier))
		}

		$LibraryHashTable['Downloads'].DestinationPath = (Join-Path 'D:\' (Split-Path -Path ($LibraryHashTable['Downloads'].OriginalPath) -NoQualifier))
	}

	$LibraryHashTable.Values | ForEach-Object {
		if ($_.OriginalPath -ne $_.DestinationPath) {
			$Name = $_.LibraryName
			$Source = $_.OriginalPath
			$Destination = $_.DestinationPath
			Write-Host "Moving library ""$Name"" from ""$Source"" to ""$Destination""" | Write-Verbose
			Move-LibraryDirectory ($_.LibraryName) ($_.DestinationPath)
			New-SymbolicLink -Path ($_.OriginalPath) -Value ($_.DestinationPath) -ErrorAction SilentlyContinue
		}
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

# 	Write-Host 'nerdygriffin.Move-Libraries completed successfully' | Write-Debug
# 	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
# } catch {
# 	Write-Host 'Error occurred in nerdygriffin.Move-Libraries' $($_.Exception.Message) | Write-Debug
# 	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
# 	throw $_.Exception
# }