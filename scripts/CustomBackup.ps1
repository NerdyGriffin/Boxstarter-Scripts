#--- Setting up custom file sync script if possible ---
choco install -y freefilesync
RefreshEnv;
Start-Sleep -Seconds 1;

$SambaProgramFiles = '\\GRIFFINUNRAID\programfiles'
$RealTimeSyncExe = 'C:\Program Files\FreeFileSync\RealTimeSync.exe'

If (Test-Path $SambaProgramFiles) {
	$IsLaptop = ($env:USERDOMAIN | Select-String 'LAPTOP')
	If ($IsLaptop) {
		$BackupFFSReal = 'BackupWindowsLaptop.ffs_real'
		$BackupFFSBatch = 'BackupWindowsLaptop.ffs_batch'
	} else {
		$BackupFFSReal = 'BackupWindowsDesktop.ffs_real'
		$BackupFFSBatch = 'BackupWindowsDesktop.ffs_batch'
	}

	$BackupFFSRealLocalPath = (Join-Path $env:ProgramData $BackupFFSReal)
	$BackupFFSBatchLocalPath = (Join-Path $env:ProgramData $BackupFFSBatch)
	$BackupFFSRealRemotePath = (Join-Path $SambaProgramFiles $BackupFFSReal)
	$BackupFFSBatchRemotePath = (Join-Path $SambaProgramFiles $BackupFFSBatch)

	$BackupCommand = """$RealTimeSyncExe"" ""$BackupFFSRealLocalPath"""

	If ((Test-Path $BackupFFSRealRemotePath) -And (Test-Path $BackupFFSBatchRemotePath)) {
		Copy-Item -Path $BackupFFSRealRemotePath -Destination $BackupFFSRealLocalPath -Force
		Copy-Item -Path $BackupFFSBatchRemotePath -Destination $BackupFFSBatchLocalPath -Force
		Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name RealTimeSyncBackup -Value $BackupCommand -Force
	}

	$WallpaperFFSReal = 'MirrorCuratedSlideshowWallpaper.ffs_real'
	$WallpaperFFSBatch = 'MirrorCuratedSlideshowWallpaper.ffs_batch'

	$WallpaperFFSRealLocalPath = (Join-Path $env:ProgramData $WallpaperFFSReal)
	$WallpaperFFSBatchLocalPath = (Join-Path $env:ProgramData $WallpaperFFSBatch)
	$WallpaperFFSRealRemotePath = (Join-Path $SambaProgramFiles $WallpaperFFSReal)
	$WallpaperFFSBatchRemotePath = (Join-Path $SambaProgramFiles $WallpaperFFSBatch)

	$WallpaperCommand = """$RealTimeSyncExe"" ""$WallpaperFFSRealLocalPath"""

	If ((Test-Path $WallpaperFFSRealRemotePath) -And (Test-Path $WallpaperFFSBatchRemotePath)) {
		Copy-Item -Path $WallpaperFFSRealRemotePath -Destination $WallpaperFFSRealLocalPath -Force
		Copy-Item -Path $WallpaperFFSBatchRemotePath -Destination $WallpaperFFSBatchLocalPath -Force
		Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name RealTimeSyncWallpaper -Value $WallpaperCommand -Force
	}

	# If (Test-Path (Join-Path $SambaProgramFiles 'realtimesync.bat')) {
	# 	Copy-Item -Path (Join-Path $SambaProgramFiles 'realtimesync.bat') -Destination (Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\Startup\realtimesync.bat') -Force
	# }
}
