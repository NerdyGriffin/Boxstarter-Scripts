#https://gist.github.com/jessfraz/7c319b046daa101a4aaef937a20ff41f
#--- Uninstall unecessary applications that come with Windows out of the box ---
try {
	# 3D Builder
	# Get-AppxPackage Microsoft.3DBuilder | Remove-AppxPackage

	# Alarms
	# Get-AppxPackage Microsoft.WindowsAlarms | Remove-AppxPackage

	# Autodesk
	# Get-AppxPackage *Autodesk* | Remove-AppxPackage

	# Bing Weather, News, Sports, and Finance (Money):
	Get-AppxPackage Microsoft.BingFinance | Remove-AppxPackage
	Get-AppxPackage Microsoft.BingNews | Remove-AppxPackage
	Get-AppxPackage Microsoft.BingSports | Remove-AppxPackage
	# Get-AppxPackage Microsoft.BingWeather | Remove-AppxPackage

	# BubbleWitch
	Get-AppxPackage *BubbleWitch* | Remove-AppxPackage

	# Candy Crush
	Get-AppxPackage king.com.CandyCrush* | Remove-AppxPackage

	# Comms Phone
	# Get-AppxPackage Microsoft.CommsPhone | Remove-AppxPackage

	# Dell
	# Get-AppxPackage *Dell* | Remove-AppxPackage

	# Dropbox
	# Get-AppxPackage *Dropbox* | Remove-AppxPackage

	# Facebook
	Get-AppxPackage *Facebook* | Remove-AppxPackage

	# Feedback Hub
	# Get-AppxPackage Microsoft.WindowsFeedbackHub | Remove-AppxPackage

	# Get Started
	# Get-AppxPackage Microsoft.Getstarted | Remove-AppxPackage

	# Keeper
	Get-AppxPackage *Keeper* | Remove-AppxPackage

	# Maps
	# Get-AppxPackage Microsoft.WindowsMaps | Remove-AppxPackage

	# March of Empires
	Get-AppxPackage *MarchofEmpires* | Remove-AppxPackage

	# McAfee Security
	Get-AppxPackage *McAfee* | Remove-AppxPackage

	# Uninstall McAfee Security App
	$mcafee = Get-ChildItem 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' | ForEach-Object { Get-ItemProperty $_.PSPath } | Where-Object { $_ -match 'McAfee Security' } | Select-Object UninstallString
	if ($mcafee) {
		$mcafee = $mcafee.UninstallString -Replace 'C:\Program Files\McAfee\MSC\mcuihost.exe', ''
		Write-Output 'Uninstalling McAfee...'
		Start-Process 'C:\Program Files\McAfee\MSC\mcuihost.exe' -arg "$mcafee" -Wait
	}

	# Messaging
	Get-AppxPackage Microsoft.Messaging | Remove-AppxPackage

	# Minecraft
	# Get-AppxPackage *Minecraft* | Remove-AppxPackage

	# Netflix
	# Get-AppxPackage *Netflix* | Remove-AppxPackage

	# Office Hub
	# Get-AppxPackage Microsoft.MicrosoftOfficeHub | Remove-AppxPackage

	# One Connect
	# Get-AppxPackage Microsoft.OneConnect | Remove-AppxPackage

	# OneNote
	# Get-AppxPackage Microsoft.Office.OneNote | Remove-AppxPackage

	# People
	Get-AppxPackage Microsoft.People | Remove-AppxPackage

	# Phone
	Get-AppxPackage Microsoft.WindowsPhone | Remove-AppxPackage

	# Photos
	# Get-AppxPackage Microsoft.Windows.Photos | Remove-AppxPackage

	# Plex
	# Get-AppxPackage *Plex* | Remove-AppxPackage

	# Skype (Metro version)
	# Get-AppxPackage Microsoft.SkypeApp | Remove-AppxPackage

	# Sound Recorder
	# Get-AppxPackage Microsoft.WindowsSoundRecorder | Remove-AppxPackage

	# Solitaire
	# Get-AppxPackage *Solitaire* | Remove-AppxPackage

	# Sticky Notes
	# Get-AppxPackage Microsoft.MicrosoftStickyNotes | Remove-AppxPackage

	# Sway
	# Get-AppxPackage Microsoft.Office.Sway | Remove-AppxPackage

	# Twitter
	Get-AppxPackage *Twitter* | Remove-AppxPackage

	# Xbox
	# Get-AppxPackage Microsoft.XboxApp | Remove-AppxPackage
	# Get-AppxPackage Microsoft.XboxIdentityProvider | Remove-AppxPackage

	# Zune Music, Movies & TV
	Get-AppxPackage Microsoft.ZuneMusic | Remove-AppxPackage
	Get-AppxPackage Microsoft.ZuneVideo | Remove-AppxPackage

	#--- Windows Settings ---
	# Some from: @NickCraver's gist https://gist.github.com/NickCraver/7ebf9efbfd0c3eab72e9

	Write-Host 'nerdygriffin.RemoveWindowsApps completed successfully' | Write-Debug
	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
} catch {
	Write-Host 'Error occurred in nerdygriffin.RemoveWindowsApps' $($_.Exception.Message) | Write-Debug
	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
	throw $_.Exception
}