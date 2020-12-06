##################
# Privacy Settings
##################

try {
	# Privacy: Let apps use my advertising ID: Disable
	Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo -Name Enabled -Type DWord -Value 0
	# To Restore:
	#Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo -Name Enabled -Type DWord -Value 1
	# Privacy: SmartScreen Filter for Store Apps: Disable
	Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost -Name EnableWebContentEvaluation -Type DWord -Value 0
	# To Restore:
	#Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost -Name EnableWebContentEvaluation -Type DWord -Value 1

	# WiFi Sense: HotSpot Sharing: Disable
	Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting -Name value -Type DWord -Value 0
	# WiFi Sense: Shared HotSpot Auto-Connect: Disable
	Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots -Name value -Type DWord -Value 0

	# Activity Tracking: Disable
	# @('EnableActivityFeed','PublishUserActivities','UploadUserActivities') |% { Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name $_ -Type DWord -Value 0 }

	# Start Menu: Disable Bing Search Results
	Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name BingSearchEnabled -Type DWord -Value 0
	# To Restore (Enabled):
	# Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name BingSearchEnabled -Type DWord -Value 1

	# Start Menu: Disale Cortana (Commented out by default - this is personal preference)
	If (!(Test-Path 'HKCU:\SOFTWARE\Microsoft\Personalization\Settings')) {
		New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Personalization\Settings' -Force | Out-Null
	}
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Personalization\Settings' -Name 'AcceptedPrivacyPolicy' -Type DWord -Value 0
	If (!(Test-Path 'HKCU:\SOFTWARE\Microsoft\InputPersonalization')) {
		New-Item -Path 'HKCU:\SOFTWARE\Microsoft\InputPersonalization' -Force | Out-Null
	}
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\InputPersonalization' -Name 'RestrictImplicitTextCollection' -Type DWord -Value 1
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\InputPersonalization' -Name 'RestrictImplicitInkCollection' -Type DWord -Value 1
	If (!(Test-Path 'HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore')) {
		New-Item -Path 'HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore' -Force | Out-Null
	}
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore' -Name 'HarvestContacts' -Type DWord -Value 0
	If (!(Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search')) {
		New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Force | Out-Null
	}
	Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'AllowCortana' -Type DWord -Value 0

	# Disable Telemetry (requires a reboot to take effect)
	Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection -Name AllowTelemetry -Type DWord -Value 0
	Get-Service DiagTrack, Dmwappushservice | Stop-Service | Set-Service -StartupType Disabled

	Write-Debug 'nerdygriffin.Privacy completed successfully'
	Write-Debug ' See the log for details (' $Boxstarter.Log ').'
} catch {
	Write-Debug 'Error occurred in nerdygriffin.Privacy' $($_.Exception.Message)
	Write-Debug ' See the log for details (' $Boxstarter.Log ').'
	throw $_.Exception
}