try {
	Disable-UAC
	Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar -DisableOpenFileExplorerToQuickAccess -DisableShowRecentFilesInQuickAccess -DisableShowFrequentFoldersInQuickAccess -EnableShowRibbon

	try {
		Enable-RemoteDesktop
	} catch {
		# Do nothing if Enable-RemoteDesktop fails, because it will fail if RemoteDesktop is already enabled
	}

	if (Test-Path '\\GRIFFINUNRAID\Boxstarter') {
		Set-BoxStarterConfig -LocalRepo '\\GRIFFINUNRAID\Boxstarter\BuildPackages'
	}

	#--- Chocolatey extensions ---
	choco install -y chocolatey-core.extension
	choco install -y chocolatey-dotnetfx.extension
	choco install -y chocolatey-fastanswers.extension
	choco install -y chocolatey-font-helpers.extension
	choco install -y chocolatey-misc-helpers.extension

	#--- Fonts ---
	choco install -y cascadiafonts

	#--- Chocolatey GUI ---
	choco install -y ChocolateyExplorer
	choco install -y ChocolateyGUI

	#--- Web Browsers ---
	choco install -y brave
	choco install -y chromium
	choco install -y firefox
	choco install -y googlechrome

	#--- Password Manager ---
	choco install -y bitwarden
	choco install -y keepass

	#--- VPN ---
	choco install -y nordvpn

	#--- Communication ---
	choco install -y discord
	choco install -y jitsi-meet-electron
	choco install -y slack
	choco install -y telegram
	choco install -y zoom

	#--- Multimedia ---
	choco install -y audacity
	choco install -y blender
	choco install -y foobar2000
	choco install -y freeencoderpack
	choco install -y fsviewer
	choco install -y gimp
	choco install -y k-lite-codecpackfull
	choco install -y obs-studio
	choco install -y streamlabs-obs
	choco install -y vlc

	#--- Office Suite ---
	choco install -y adobereader
	choco install -y libreoffice-fresh

	#--- E-Books ---
	choco install -y calibre
	choco install -y kindle

	#--- LaTeX ---
	choco install -y texlive

	#--- Scientific ---
	choco install -y geogebra
	choco install -y gnuplot
	choco install -y octave

	#--- Windows 10 Tools ---
	choco install -y mousewithoutborders
	choco install -y powertoys
	choco install -y plasso
	choco install -y procexp
	choco install -y procmon
	choco install -y shutup10
	choco install -y sharex
	choco install -y winaero-tweaker

	#--- Network File System & Cloud Storage ---
	choco install -y ext2fsd
	choco install -y ext2ifs
	choco install -y filezilla
	choco install -y fuse-nfs
	choco install -y google-backup-and-sync
	choco install -y megasync
	choco install -y nextcloud-client
	choco install -y qbittorrent
	choco install -y winscp

	#--- File & Storage Utilities ---
	choco install -y 7zip
	choco install -y etcher
	choco install -y filebot
	choco install -y Folder_Size
	choco install -y freefilesync
	choco install -y rufus
	choco install -y tuxboot

	#--- Unofficial Chocolatey Tools ---
	choco install -y choco-package-list-backup
	choco install -y choco-upgrade-all-at

	#--- Windows Settings ---
	Disable-BingSearch
	Disable-GameBarTips

	Enable-UAC
	Enable-MicrosoftUpdate
	Install-WindowsUpdate -acceptEula

	Write-Debug 'The script completed successfully' -ForegroundColor Green
	Write-ChocolateySuccess 'nerdygriffin.DefaultInstall'
} catch {
	Write-ChocolateyFailure 'nerdygriffin.DefaultInstall' $($_.Exception.Message)
	throw
}