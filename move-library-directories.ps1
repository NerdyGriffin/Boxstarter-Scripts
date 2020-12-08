try {
	Disable-UAC

	$ServerRootPath = '\\GRIFFINUNRAID\' # TODO: Make an interactive script that can ask for user to provide whatever server path they want
	$ServerMediaShare = (Join-Path $ServerRootPath 'media')
	$ServerDownloadsShare = (Join-Path $ServerRootPath 'personal\Downloads')

	if ($env:Username -contains 'Public') {
		Write-Warning 'Somehow the current username is "Public"...', '  That should not be possible, so the libraries will not be moved.'
	} else {
		if ((Get-ComputerName | Select-String 'DESKTOP') -And (Test-Path $ServerMediaShare)) {
			Move-LibraryDirectory 'My Music' (Join-Path $ServerMediaShare 'Music') -ErrorAction SilentlyContinue
			New-SymLink -Path (Join-Path $env:UserProfile 'Music') -Value (Join-Path $ServerMediaShare 'Music') -ErrorAction SilentlyContinue

			Move-LibraryDirectory 'My Pictures' (Join-Path $ServerMediaShare 'Pictures') -ErrorAction SilentlyContinue
			New-SymLink -Path (Join-Path $env:UserProfile 'Pictures') -Value (Join-Path $ServerMediaShare 'Pictures') -ErrorAction SilentlyContinue

			Move-LibraryDirectory 'My Video' (Join-Path $ServerMediaShare 'Videos') -ErrorAction SilentlyContinue
			New-SymLink -Path (Join-Path $env:UserProfile 'Videos') -Value (Join-Path $ServerMediaShare 'Videos') -ErrorAction SilentlyContinue
		} elseif (Test-Path 'D:\') {
			Move-LibraryDirectory 'My Music' (Join-Path (Join-Path 'D:\Users' $env:Username) 'Music')
			New-SymLink -Path (Join-Path $env:UserProfile 'Music') -Value (Join-Path (Join-Path 'D:\Users' $env:Username) 'Music') -ErrorAction SilentlyContinue

			Move-LibraryDirectory 'My Pictures' (Join-Path (Join-Path 'D:\Users' $env:Username) 'Pictures')
			New-SymLink -Path (Join-Path $env:UserProfile 'Pictures') -Value (Join-Path (Join-Path 'D:\Users' $env:Username) 'Pictures') -ErrorAction SilentlyContinue

			Move-LibraryDirectory 'My Video' (Join-Path (Join-Path 'D:\Users' $env:Username) 'Videos')
			New-SymLink -Path (Join-Path $env:UserProfile 'Videos') -Value (Join-Path (Join-Path 'D:\Users' $env:Username) 'Videos') -ErrorAction SilentlyContinue
		}

		if ((Get-ComputerName | Select-String 'DESKTOP') -And (Test-Path $ServerDownloadsShare)) {
			Move-LibraryDirectory 'Downloads' $ServerDownloadsShare
			New-SymLink -Path (Join-Path $env:UserProfile 'Downloads') -Value $ServerDownloadsShare -ErrorAction SilentlyContinue
		} elseif (Test-Path 'D:\') {
			Move-LibraryDirectory 'Personal' (Join-Path 'D:\Users' $env:Username 'Documents')
			New-SymLink -Path (Join-Path $env:UserProfile 'Documents') -Value (Join-Path (Join-Path 'D:\Users' $env:Username) 'Documents') -ErrorAction SilentlyContinue

			Move-LibraryDirectory 'Downloads' (Join-Path 'D:\Users' $env:Username 'Downloads')
			New-SymLink -Path (Join-Path $env:UserProfile 'Downloads') -Value (Join-Path (Join-Path 'D:\Users' $env:Username) 'Downloads') -ErrorAction SilentlyContinue
		}
	}

	Enable-UAC
	Enable-MicrosoftUpdate
	Install-WindowsUpdate -acceptEula

	Write-Debug 'nerdygriffin.Move-Libraries completed successfully'
	Write-Debug ' See the log for details (' $Boxstarter.Log ').'
} catch {
	Write-Debug 'Error occurred in nerdygriffin.Move-Libraries' $($_.Exception.Message)
	Write-Debug ' See the log for details (' $Boxstarter.Log ').'
	throw $_.Exception
}