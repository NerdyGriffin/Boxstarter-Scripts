If ($Boxstarter.StopOnPackageFailure) { $Boxstarter.StopOnPackageFailure = $false }

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

function drawLine { Write-Host '------------------------------' }

function executeScript {
	Param ([string]$script)
	drawLine 30
	Write-Host "executing $helperUri/$script ..."
	Invoke-Expression ((New-Object net.webclient).DownloadString("$helperUri/$script")) -ErrorAction Continue
	drawLine 30
	RefreshEnv;
	Start-Sleep -Seconds 1;
}

#--- Setting up Windows ---
executeScript 'SystemConfiguration.ps1';
executeScript 'DisableSleepIfVM.ps1';
executeScript 'FileExplorerSettings.ps1';
# executeScript 'TaskbarSettings.ps1';
executeScript 'RemoveDefaultApps.ps1';
executeScript 'WindowsPersonalization.ps1';
executeScript 'WindowsPowerUser.ps1';
executeScript 'CommonDevTools.ps1';
executeScript 'ConfigurePowerShell.ps1';
executeScript 'ConfigureGit.ps1';
executeScript 'PowerShellTools.ps1';
executeScript 'GNU.ps1';
executeScript 'CustomBackup.ps1';

#--- Graphics Driver Support
executeScript 'NvidiaGraphics.ps1';

#--- Setting up Chocolatey
executeScript 'ChocolateyExtensions.ps1';
executeScript 'ChocolateyGUI.ps1';

#--- Setting up programs for typical every-day use
executeScript 'PasswordManager.ps1';
executeScript 'NordVPN.ps1';
executeScript 'Browsers.ps1';
executeScript 'Multimedia.ps1';
executeScript 'CommunicationApps.ps1';
executeScript 'OfficeTools.ps1';
executeScript 'CloudStorage.ps1';
executeScript 'Scientific.ps1';

#--- Windows Settings ---
Disable-BingSearch
# Disable-GameBarTips

Get-Content -Path $Boxstarter.Log | Select-String -Pattern '^Failures$' -Context 0, 2 >> (Join-Path $env:USERPROFILE 'Desktop\boxstarter-failures.log')

#--- reenabling critial items ---
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula

$MackieDriverSetupExe = '\\GRIFFINUNRAID\personal\Downloads\Mackie_USB_Driver_v4_67_0\Mackie_USB_Driver_Setup.exe'
If (Test-Path $MackieDriverSetupExe) {
	Write-Verbose 'Attempt installing driver for Mackie mixer board'
	Invoke-Expression $MackieDriverSetupExe
}

$SimpleLog = (Join-Path $env:USERPROFILE 'Desktop\last-installed.log')
If (-not(Test-Path $SimpleLog)) {
	New-Item -Path $SimpleLog -ItemType File
}
Add-Content -Path $SimpleLog -Value 'daily_driver'
