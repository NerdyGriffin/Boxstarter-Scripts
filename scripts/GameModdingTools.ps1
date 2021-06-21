#--- Mods & Cheats
choco install -y cheatengine
choco install -y vortex
choco install -y wemod

# Install python
choco install -y python

# Refresh path
refreshenv

# Update pip
python -m pip install --upgrade pip

# Install BCML (Tool for cemu mods)
try {
	pip install bcml
} catch {
	Write-Host "'pip install bcml' failed. Note: BCML with Python 3.9+ will not work on Windows until 'pythonnet' is updated."
	Write-Host 'As a workaround, I will now attempt to install Python 3.8 for use with BCML.'

	$python38Installer = (Join-Path $env:USERPROFILE 'Downloads\python-3.8.10-amd64.exe')
	if (-Not(Test-Path $python38Installer)) {
		$source = 'https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe'
		Write-Verbose 'Downloading Python 3.8 installer...'
		Invoke-WebRequest -Uri $source -OutFile $python38Installer
	}

	Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem -Name LongPathsEnabled -Value 1

	Write-Verbose 'Running Python 3.8 installer...'
	Invoke-Expression "$python38Installer /quiet InstallAllUsers=0 PrependPath=1"

	refreshenv

	$python38 = (Join-Path $env:LOCALAPPDATA 'Programs\Python\Python38\python.exe')
	if (Test-Path $python38) {
		Write-Verbose 'Installing BCML using Python 3.8'
		Invoke-Expression "$python38 -m pip install --upgrade pip"
		Invoke-Expression "$python38 -m pip install bcml"
	}
}
refreshenv

$BCMLPath = $(Resolve-Path (Get-Command bcml | Select-Object -Expand Source) | Select-Object -Expand Path)
if (Test-Path $BCMLPath) {
	$BCMLShortcutDest = (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\BCML.lnk')
	$WshShell = New-Object -ComObject WScript.Shell
	$Shortcut = $WshShell.CreateShortcut($BCMLShortcutDest)
	$Shortcut.TargetPath = $BCMLPath
	$Shortcut.Save()
}
