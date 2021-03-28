$Boxstarter.StopOnPackageFailure = $false

Disable-UAC

# Get the base URI path from the ScriptToCall value
$bstrappackage = '-bootstrapPackage'
$helperUri = $Boxstarter['ScriptToCall']
$strpos = $helperUri.IndexOf($bstrappackage)
$helperUri = $helperUri.Substring($strpos + $bstrappackage.Length)
$helperUri = $helperUri.TrimStart("'", ' ')
$helperUri = $helperUri.TrimEnd("'", ' ')
$helperUri = $helperUri.Substring(0, $helperUri.LastIndexOf('/'))
$helperUri += '/scripts'
Write-Host "helper script base URI is $helperUri"

function executeScript {
	Param ([string]$script)
	Write-Host "executing $helperUri/$script ..."
	Invoke-Expression ((New-Object net.webclient).DownloadString("$helperUri/$script")) -ErrorAction Continue
	RefreshEnv;
	Start-Sleep -Seconds 1;
}

#--- Setting up Windows ---
executeScript 'SystemConfiguration.ps1';
executeScript 'FileExplorerSettings.ps1';
# executeScript 'TaskbarSettings.ps1';
executeScript 'RemoveDefaultApps.ps1';
executeScript 'CommonDevTools.ps1';
executeScript 'WindowsPowerUser.ps1';

#--- Graphics Driver Support
executeScript 'NvidiaGraphics.ps1';

#--- Setting up Chocolatey
executeScript 'ChocolateyExtensions.ps1';
executeScript 'ChocolateyGUI.ps1';

#--- Setting up programs for typical every-day use
executeScript 'PasswordManager.ps1';
executeScript 'Browsers.ps1';
executeScript 'Multimedia.ps1';
executeScript 'CommunicationApps.ps1';
executeScript 'OfficeTools.ps1';
executeScript 'CloudStorage.ps1';
executeScript 'Scientific.ps1';

#--- Windows Settings ---
Disable-BingSearch
Disable-GameBarTips

#--- Setting up custom file sync script if possible ---
choco install -y freefilesync
RefreshEnv;
Start-Sleep -Seconds 1;

$SambaProgramFiles = '\\GRIFFINUNRAID\programfiles'

$IsLaptop = ($env:USERDOMAIN | Select-String 'LAPTOP')
If ($IsLaptop) {
	$RealTimeScript = 'BackupWindowsLaptop.ffs_real'
	$BackupScript = 'BackupWindowsLaptop.ffs_batch'
} else {
	$RealTimeScript = 'BackupWindowsDesktop.ffs_real'
	$BackupScript = 'BackupWindowsDesktop.ffs_batch'
}

$RealTimeScriptRemotePath = (Join-Path $SambaProgramFiles $RealTimeScript)
$RealTimeScriptLocalPath = (Join-Path $env:ProgramData $RealTimeScript)
$BackupScriptRemotePath = (Join-Path $SambaProgramFiles $BackupScript)
$BackupScriptLocalPath = (Join-Path $env:ProgramData $BackupScript)

If ((Test-Path $RealTimeScriptRemotePath) -And (Test-Path $BackupScriptRemotePath)) {
	Copy-Item -Path $RealTimeScriptRemotePath -Destination $RealTimeScriptLocalPath
	Copy-Item -Path $BackupScriptRemotePath -Destination $BackupScriptLocalPath
}

$WallpaperRealTimeScript = 'MirrorCuratedSlideshowWallpaper.ffs_real'
$WallpaperBatchScript = 'MirrorCuratedSlideshowWallpaper.ffs_batch'

$WallpaperRealTimeScriptRemotePath = (Join-Path $SambaProgramFiles $WallpaperRealTimeScript)
$WallpaperRealTimeScriptLocalPath = (Join-Path $env:ProgramData $WallpaperRealTimeScript)
$WallpaperBatchScriptRemotePath = (Join-Path $SambaProgramFiles $WallpaperBatchScript)
$WallpaperBatchScriptLocalPath = (Join-Path $env:ProgramData $WallpaperBatchScript)

If ((Test-Path $WallpaperRealTimeScriptRemotePath) -And (Test-Path $WallpaperBatchScriptRemotePath)) {
	Copy-Item -Path $WallpaperRealTimeScriptRemotePath -Destination $WallpaperRealTimeScriptLocalPath
	Copy-Item -Path $WallpaperBatchScriptRemotePath -Destination $WallpaperBatchScriptLocalPath
}

If (Test-Path (Join-Path $SambaProgramFiles 'realtimesync.bat')) {
	If (!(Test-Path (Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\Startup\realtimesync.bat'))) {
		Copy-Item -Path (Join-Path $SambaProgramFiles 'realtimesync.bat') -Destination (Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\Startup\realtimesync.bat')
	}
}

Get-Content -Path $Boxstarter.Log | Select-String -Pattern '^Failures$' -Context 0, 2 >> (Join-Path $env:USERPROFILE 'Desktop\boxstarter-failures.log')

#--- reenabling critial items ---
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
