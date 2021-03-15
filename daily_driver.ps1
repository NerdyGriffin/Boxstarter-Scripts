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
	Invoke-Expression ((New-Object net.webclient).DownloadString("$helperUri/$script"))
}

#--- Setting up Windows ---
executeScript 'FileExplorerSettings.ps1';
# executeScript 'TaskbarSettings.ps1';
executeScript 'RemoveDefaultApps.ps1';

#--- Graphics Driver Support
executeScript 'NvidiaGraphics.ps1';

#--- Setting up Chocolatey
executeScript 'ChocolateyExtensions.ps1'; RefreshEnv; Start-Sleep 0.5;
executeScript 'ChocolateyGUI.ps1'; RefreshEnv; Start-Sleep 0.5;

#--- Setting up programs for typical every-day use
executeScript 'PasswordManager.ps1'; RefreshEnv; Start-Sleep 0.5;
executeScript 'Browsers.ps1'; RefreshEnv; Start-Sleep 0.5;
executeScript 'Multimedia.ps1'; RefreshEnv; Start-Sleep 0.5;
executeScript 'CommunicationApps.ps1'; RefreshEnv; Start-Sleep 0.5;
executeScript 'OfficeTools.ps1'; RefreshEnv; Start-Sleep 0.5;
executeScript 'CloudStorage.ps1'; RefreshEnv; Start-Sleep 0.5;
executeScript 'Scientific.ps1'; RefreshEnv; Start-Sleep 0.5;

#--- Windows Settings ---
Disable-BingSearch
Disable-GameBarTips

Get-Content -Path $Boxstarter.Log | Select-String -Pattern '^Failures$' -Context 0, 2 >> (Join-Path $env:USERPROFILE 'Desktop\boxstarter-failures.log')

#--- reenabling critial items ---
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
