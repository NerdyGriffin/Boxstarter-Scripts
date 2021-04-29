choco install -y windynamicdesktop

# Disable syncing themes to allow for wallpaper slideshows with more than 20 images
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync' -Name DisablePersonalizationSettingsSync -Type DWord -Value 2
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync' -Name DisablePersonalizationSettingSyncUserOverride -Type DWord -Value 1
