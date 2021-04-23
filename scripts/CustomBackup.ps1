#--- Setting up custom file sync script if possible ---
choco install -y freefilesync
RefreshEnv;
Start-Sleep -Seconds 1;

$SambaProgramFiles = '\\GRIFFINUNRAID\programfiles'
$FreeFileSyncExe = (Join-Path $env:ProgramFiles '\FreeFileSync\FreeFileSync.exe')
# $RealTimeSyncExe = (Join-Path $env:ProgramFiles '\FreeFileSync\RealTimeSync.exe')

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

	# $BackupCommand = """$RealTimeSyncExe"" ""$BackupFFSRealLocalPath"""

	If ((Test-Path $BackupFFSRealRemotePath) -And (Test-Path $BackupFFSBatchRemotePath)) {
		Copy-Item -Path $BackupFFSRealRemotePath -Destination $BackupFFSRealLocalPath -Force
		Copy-Item -Path $BackupFFSBatchRemotePath -Destination $BackupFFSBatchLocalPath -Force

		$STAction = New-ScheduledTaskAction -Execute "$FreeFileSyncExe" -Argument "$BackupFFSBatchLocalPath"
		$STTrigger = @(
			$(New-ScheduledTaskTrigger -Daily -At 3am),
			$(New-ScheduledTaskTrigger -Daily -At 3pm)
		)
		$STPrin = New-ScheduledTaskPrincipal -UserId 'NT AUTHORITY\SYSTEM' -RunLevel Highest
		$STSetings = New-ScheduledTaskSettingsSet -DisallowStartOnRemoteAppSession -ExecutionTimeLimit (New-TimeSpan -Hours 8) -IdleDuration (New-TimeSpan -Minutes 10) -IdleWaitTimeout (New-TimeSpan -Hours 8) -MultipleInstances IgnoreNew -Priority 5 -RestartOnIdle -RunOnlyIfIdle -RunOnlyIfNetworkAvailable

		if (Get-ScheduledTask -TaskName 'FreeFileSyncBackup' -ErrorAction SilentlyContinue) {
			Set-ScheduledTask -TaskName 'FreeFileSyncBackup' -Action $STAction -Principal $STPrin -Settings $STSetings -Trigger $STTrigger
		} else {
			Register-ScheduledTask -TaskName 'FreeFileSyncBackup' -Action $STAction -Principal $STPrin -Settings $STSetings -Trigger $STTrigger
		}
		# Export-ScheduledTask -TaskName 'FreeFileSyncBackup' #! DEBUG: This line is for debug testing

		if (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name RealTimeSyncBackup) {
			Write-Host "Removing deprecated registry entry for the 'RealTimeSyncBackup' script"
			Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name RealTimeSyncBackup
		}
	}
	Clear-Variable STAction, STPrin, STSetings, STTrigger


	$WallpaperFFSReal = 'MirrorCuratedSlideshowWallpaper.ffs_real'
	$WallpaperFFSBatch = 'MirrorCuratedSlideshowWallpaper.ffs_batch'

	$WallpaperFFSRealLocalPath = (Join-Path $env:ProgramData $WallpaperFFSReal)
	$WallpaperFFSBatchLocalPath = (Join-Path $env:ProgramData $WallpaperFFSBatch)
	$WallpaperFFSRealRemotePath = (Join-Path $SambaProgramFiles $WallpaperFFSReal)
	$WallpaperFFSBatchRemotePath = (Join-Path $SambaProgramFiles $WallpaperFFSBatch)

	# $WallpaperCommand = """$RealTimeSyncExe"" ""$WallpaperFFSRealLocalPath"""

	If ((Test-Path $WallpaperFFSRealRemotePath) -And (Test-Path $WallpaperFFSBatchRemotePath)) {
		Copy-Item -Path $WallpaperFFSRealRemotePath -Destination $WallpaperFFSRealLocalPath -Force
		Copy-Item -Path $WallpaperFFSBatchRemotePath -Destination $WallpaperFFSBatchLocalPath -Force

		$STAction = New-ScheduledTaskAction -Execute "$FreeFileSyncExe" -Argument "$WallpaperFFSBatchLocalPath"
		$STTrigger = @(
			$(New-ScheduledTaskTrigger -Daily -At 12am),
			$(New-ScheduledTaskTrigger -Daily -At 6am),
			$(New-ScheduledTaskTrigger -Daily -At 12pm),
			$(New-ScheduledTaskTrigger -Daily -At 6pm)
		)
		$STSetings = New-ScheduledTaskSettingsSet -DisallowStartOnRemoteAppSession -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -ExecutionTimeLimit (New-TimeSpan -Hours 1) -IdleDuration (New-TimeSpan -Minutes 1) -IdleWaitTimeout (New-TimeSpan -Hours 4) -MultipleInstances IgnoreNew -Priority 5 -RestartOnIdle -RunOnlyIfNetworkAvailable

		if (Get-ScheduledTask -TaskName 'FreeFileSyncWallpaper' -ErrorAction SilentlyContinue) {
			Set-ScheduledTask -TaskName 'FreeFileSyncWallpaper' -Action $STAction -Settings $STSetings -Trigger $STTrigger
		} else {
			Register-ScheduledTask -TaskName 'FreeFileSyncWallpaper' -Action $STAction -Settings $STSetings -Trigger $STTrigger
		}
		# Export-ScheduledTask -TaskName 'FreeFileSyncWallpaper' #! DEBUG: This line is for debug testing

		if (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name RealTimeSyncWallpaper) {
			Write-Host "Removing deprecated registry entry for the 'RealTimeSyncWallpaper' script"
			Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name RealTimeSyncWallpaper
		}
	}
}
