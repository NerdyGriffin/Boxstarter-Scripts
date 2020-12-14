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

# try {
Disable-UAC

$ServerRootPath = '\\GRIFFINUNRAID\' # TODO: Make an interactive script that can ask for user to provide whatever server path they want
$ServerMediaShare = (Join-Path $ServerRootPath 'media')
$ServerDownloadsShare = (Join-Path $ServerRootPath 'personal\Downloads')

if ($env:Username -contains 'Public') {
	Write-Host  'Somehow the current username is "Public"...', '  That should not be possible, so the libraries will not be moved.' | Write-Warning
} else {
	if (($env:USERDOMAIN | Select-String 'DESKTOP') -And (Test-Path $ServerMediaShare)) {
		Write-Host 'Moving Library Directories to server shares...'

		Move-LibraryDirectory 'My Music' (Join-Path $ServerMediaShare 'Music') -ErrorAction SilentlyContinue
		# New-SymLink -Path (Join-Path $env:UserProfile 'Music') -Value (Join-Path $ServerMediaShare 'Music') -ErrorAction SilentlyContinue

		Move-LibraryDirectory 'My Pictures' (Join-Path $ServerMediaShare 'Pictures') -ErrorAction SilentlyContinue
		# New-SymLink -Path (Join-Path $env:UserProfile 'Pictures') -Value (Join-Path $ServerMediaShare 'Pictures') -ErrorAction SilentlyContinue

		Move-LibraryDirectory 'My Video' (Join-Path $ServerMediaShare 'Videos') -ErrorAction SilentlyContinue
		# New-SymLink -Path (Join-Path $env:UserProfile 'Videos') -Value (Join-Path $ServerMediaShare 'Videos') -ErrorAction SilentlyContinue
	} elseif (Test-Path 'D:\') {
		Write-Host 'Moving Library Directories to D:\ ...'

		Move-LibraryDirectory 'My Music' (Join-Path (Join-Path 'D:\Users' $env:Username) 'Music')
		# New-SymLink -Path (Join-Path $env:UserProfile 'Music') -Value (Join-Path (Join-Path 'D:\Users' $env:Username) 'Music') -ErrorAction SilentlyContinue

		Move-LibraryDirectory 'My Pictures' (Join-Path (Join-Path 'D:\Users' $env:Username) 'Pictures')
		# New-SymLink -Path (Join-Path $env:UserProfile 'Pictures') -Value (Join-Path (Join-Path 'D:\Users' $env:Username) 'Pictures') -ErrorAction SilentlyContinue

		Move-LibraryDirectory 'My Video' (Join-Path (Join-Path 'D:\Users' $env:Username) 'Videos')
		# New-SymLink -Path (Join-Path $env:UserProfile 'Videos') -Value (Join-Path (Join-Path 'D:\Users' $env:Username) 'Videos') -ErrorAction SilentlyContinue
	}

	if (($env:USERDOMAIN | Select-String 'DESKTOP') -And (Test-Path $ServerDownloadsShare)) {
		Move-LibraryDirectory 'Downloads' $ServerDownloadsShare
		# New-SymLink -Path (Join-Path $env:UserProfile 'Downloads') -Value $ServerDownloadsShare -ErrorAction SilentlyContinue
	} elseif (Test-Path 'D:\') {
		Move-LibraryDirectory 'Personal' (Join-Path 'D:\Users' $env:Username 'Documents')
		# New-SymLink -Path (Join-Path $env:UserProfile 'Documents') -Value (Join-Path (Join-Path 'D:\Users' $env:Username) 'Documents') -ErrorAction SilentlyContinue

		Move-LibraryDirectory 'Downloads' (Join-Path 'D:\Users' $env:Username 'Downloads')
		# New-SymLink -Path (Join-Path $env:UserProfile 'Downloads') -Value (Join-Path (Join-Path 'D:\Users' $env:Username) 'Downloads') -ErrorAction SilentlyContinue
	}
}

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula

# 	Write-Host 'nerdygriffin.Move-Libraries completed successfully' | Write-Debug
# 	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
# } catch {
# 	Write-Host 'Error occurred in nerdygriffin.Move-Libraries' $($_.Exception.Message) | Write-Debug
# 	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
# 	throw $_.Exception
# }