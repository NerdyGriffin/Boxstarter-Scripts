#--- Uninstall unnecessary applications that come with Windows out of the box ---
Write-Host 'Uninstall some applications that come with Windows out of the box' -ForegroundColor 'Yellow'

#Referenced to build script
# https://docs.microsoft.com/en-us/windows/application-management/remove-provisioned-apps-during-update
# https://github.com/jayharris/dotfiles-windows/blob/master/windows.ps1#L157
# https://gist.github.com/jessfraz/7c319b046daa101a4aaef937a20ff41f
# https://gist.github.com/alirobe/7f3b34ad89a159e6daa1
# https://github.com/W4RH4WK/Debloat-Windows-10/blob/master/scripts/remove-default-apps.ps1

function removeApp {
	Param ([string]$appName)
	Write-Output "Trying to remove $appName"
	Get-AppxPackage $appName -AllUsers | Remove-AppxPackage
	Get-AppxProvisionedPackage -Online | Where-Object DisplayName -Like $appName | Remove-AppxProvisionedPackage -Online
}

$applicationList = @(
	# "Microsoft.3DBuilder"
	'Microsoft.BingFinance'
	'Microsoft.BingNews'
	'Microsoft.BingSports'
	# "Microsoft.BingWeather"
	# 'Microsoft.CommsPhone'
	# "Microsoft.Getstarted"
	# 'Microsoft.WindowsMaps'
	'*MarchofEmpires*'
	# "Microsoft.GetHelp"
	# "Microsoft.Messaging"
	# "*Minecraft*"
	# "Microsoft.MicrosoftOfficeHub"
	# "Microsoft.OneConnect"
	# 'Microsoft.WindowsPhone'
	# 'Microsoft.WindowsSoundRecorder'
	# '*Solitaire*'
	# "Microsoft.MicrosoftStickyNotes"
	# 'Microsoft.Office.Sway'
	# "Microsoft.XboxApp"
	# "Microsoft.XboxIdentityProvider"
	'Microsoft.ZuneMusic'
	'Microsoft.ZuneVideo'
	# 'Microsoft.NetworkSpeedTest'
	# 'Microsoft.FreshPaint'
	# "Microsoft.Print3D"
	# "*Autodesk*"
	'*BubbleWitch*'
	'king.com*'
	'G5*'
	'*Dell*'
	'*Facebook*'
	'*Keeper*'
	# '*Netflix*'
	'*Twitter*'
	# "*Plex*"
	# "*.Duolingo-LearnLanguagesforFree"
	'*.EclipseManager'
	'ActiproSoftwareLLC.562882FEEB491' # Code Writer
	'*.AdobePhotoshopExpress'
);

foreach ($app in $applicationList) {
	removeApp $app
}

# McAfee Security
Get-AppxPackage *McAfee* | Remove-AppxPackage

# Uninstall McAfee Security App
$mcafee = Get-ChildItem 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' | ForEach-Object { Get-ItemProperty $_.PSPath } | Where-Object { $_ -match 'McAfee Security' } | Select-Object UninstallString
if ($mcafee) {
	$mcafee = $mcafee.UninstallString -Replace 'C:\Program Files\McAfee\MSC\mcuihost.exe', ''
	Write-Output 'Uninstalling McAfee...'
	Start-Process 'C:\Program Files\McAfee\MSC\mcuihost.exe' -arg "$mcafee" -Wait
}