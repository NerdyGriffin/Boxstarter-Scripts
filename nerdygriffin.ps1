# try {
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
choco install -y chocolatey-visualstudio.extension
choco install -y chocolatey-vscode.extension

#--- Nvidia Graphics ---
choco install -y geforce-experience

#--- Chocolatey GUI ---
# choco install -y ChocolateyExplorer
choco install -y ChocolateyGUI

#--- Web Browsers ---
choco install -y brave
choco install -y chromium
choco install -y firefox # This package tends to fail when installed via Boxstarter, but works fine when you run the same common manually
choco install -y googlechrome --ignore-checksums # This package currently gives a checksum error

#--- Password Manager ---
choco install -y bitwarden
choco install -y keepass

#--- VPN ---
# choco install -y nordvpn # Installer is possibly broken

#--- Communication ---
choco install -y discord
choco install -y jitsi-meet-electron
choco install -y signal;
choco install -y slack
choco install -y telegram
choco install -y zoom

#--- Multimedia ---
choco install -y audacity
choco install -y audacity-lame
choco install -y blender
choco install -y foobar2000
choco install -y freeencoderpack
choco install -y fsviewer
choco install -y gimp
choco install -y k-litecodecpackfull
choco install -y lame
choco install -y obs-studio
choco install -y phantombot
choco install -y streamlabs-obs
choco install -y vlc
choco install -y winamp

#--- Office Suite ---
choco install -y adobereader
choco install -y libreoffice-fresh
choco install -y xournalplusplus

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
# choco install -y everything
# choco install -y mousewithoutborders
choco install -y powertoys
try {
	choco install -y plasso
} catch {
	choco install -y plasso --ignore-checksums
}
choco install -y procexp
choco install -y procmon
choco install -y reshack
choco install -y shutup10
choco install -y sharex
choco install -y winaero-tweaker
choco install -y xyplorer

#--- Network File System & Cloud Storage ---
choco install -y ext2fsd
choco install -y ext2ifs
choco install -y filezilla
choco install -y fuse-nfs
choco install -y google-backup-and-sync
# choco install -y megasync
choco install -y nextcloud-client
choco install -y winscp

#--- File & Storage Utilities ---
choco install -y 7zip
choco install -y etcher
choco install -y filebot
choco install -y Folder_Size
choco install -y freefilesync
choco install -y partitionwizard
choco install -y rufus
choco install -y tuxboot

#--- Unofficial Chocolatey Tools ---
choco install -y choco-package-list-backup
choco install -y choco-upgrade-all-at

#--- Windows Settings ---
Disable-BingSearch
Disable-GameBarTips

Get-Content -Path $Boxstarter.Log | Select-String -Pattern '^Failures$' -Context 0, 2 >> (Join-Path $env:USERPROFILE 'Desktop\boxstarter-failures.log')

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula

# 	Write-Host 'nerdygriffin.DefaultInstall completed successfully' | Write-Debug
# 	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
# } catch {
# 	Write-Host 'Error occurred in nerdygriffin.DefaultInstall' $($_.Exception.Message) | Write-Debug
# 	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
# 	throw $_.Exception
# }