try {
	Disable-UAC

	if ((Get-ComputerName | Select-String 'DESKTOP') -And (Test-Path '\\GRIFFINUNRAID\media\')) {
		Move-LibraryDirectory 'My Music' '\\GRIFFINUNRAID\media\Music' -ErrorAction SilentlyContinue
		New-SymLink -Path (Join-Path $env:UserProfile 'Music') -Value '\\GRIFFINUNRAID\media\Music' -ErrorAction SilentlyContinue

		Move-LibraryDirectory 'My Pictures' '\\GRIFFINUNRAID\media\Pictures' -ErrorAction SilentlyContinue
		New-SymLink -Path (Join-Path $env:UserProfile 'Pictures') -Value '\\GRIFFINUNRAID\media\Pictures' -ErrorAction SilentlyContinue

		Move-LibraryDirectory 'My Video' '\\GRIFFINUNRAID\media\Videos' -ErrorAction SilentlyContinue
		New-SymLink -Path (Join-Path $env:UserProfile 'Videos') -Value '\\GRIFFINUNRAID\media\Videos' -ErrorAction SilentlyContinue
	} elseif (Test-Path 'D:\') {
		Move-LibraryDirectory 'My Music' (Join-Path (Join-Path 'D:\Users' $env:Username) 'Music')
		New-SymLink -Path (Join-Path $env:UserProfile 'Music') -Value (Join-Path (Join-Path 'D:\Users' $env:Username) 'Music') -ErrorAction SilentlyContinue

		Move-LibraryDirectory 'My Pictures' (Join-Path (Join-Path 'D:\Users' $env:Username) 'Pictures')
		New-SymLink -Path (Join-Path $env:UserProfile 'Pictures') -Value (Join-Path (Join-Path 'D:\Users' $env:Username) 'Pictures') -ErrorAction SilentlyContinue

		Move-LibraryDirectory 'My Video' (Join-Path (Join-Path 'D:\Users' $env:Username) 'Videos')
		New-SymLink -Path (Join-Path $env:UserProfile 'Videos') -Value (Join-Path (Join-Path 'D:\Users' $env:Username) 'Videos') -ErrorAction SilentlyContinue
	}

	if ((Get-ComputerName | Select-String 'DESKTOP') -And (Test-Path '\\GRIFFINUNRAID\personal\')) {
		Move-LibraryDirectory 'Downloads' '\\GRIFFINUNRAID\personal\Downloads'
		New-SymLink -Path (Join-Path $env:UserProfile 'Downloads') -Value '\\GRIFFINUNRAID\personal\Downloads' -ErrorAction SilentlyContinue
	} elseif (Test-Path 'D:\') {
		Move-LibraryDirectory 'Personal' (Join-Path 'D:\Users' $env:Username 'Documents')
		New-SymLink -Path (Join-Path $env:UserProfile 'Documents') -Value (Join-Path (Join-Path 'D:\Users' $env:Username) 'Documents') -ErrorAction SilentlyContinue

		Move-LibraryDirectory 'Downloads' (Join-Path 'D:\Users' $env:Username 'Downloads')
		New-SymLink -Path (Join-Path $env:UserProfile 'Downloads') -Value (Join-Path (Join-Path 'D:\Users' $env:Username) 'Downloads') -ErrorAction SilentlyContinue
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