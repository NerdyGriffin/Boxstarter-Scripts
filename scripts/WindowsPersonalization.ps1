choco install -y windynamicdesktop

# Disable syncing themes to allow for wallpaper slideshows with more than 20 images
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync' -Name DisablePersonalizationSettingsSync -Type DWord -Value 2
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync' -Name DisablePersonalizationSettingSyncUserOverride -Type DWord -Value 1

# Let apps run in the background
If (-not(Test-Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications')) {
	New-Item -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' -Force | Out-Null
}
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' -Name 'GlobalUserDisabled ' -Type DWord -Value 0
