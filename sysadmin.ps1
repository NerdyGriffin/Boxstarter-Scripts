$Boxstarter.StopOnPackageFailure = $false

# Prompt user whether to install SSH Server
if (-not$InstallSSHServer) {
	$InstallSSHServer = Read-Host -Prompt 'Would you like to install and configure OpenSSH Server? (This is not recommended on laptops/mobile devices) [y/n] (default: no)'
}
# Set a default if not passed
if (-not$InstallSSHServer) { $InstallSSHServer = 'n' }

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

if (-not($env:USERDOMAIN | Select-String 'LAPTOP')) {
	# Do nothing if Enable-RemoteDesktop fails, because it will fail if RemoteDesktop is already enabled
	try { Enable-RemoteDesktop } catch {}
}

#--- Setting up Windows ---
executeScript 'SystemConfiguration.ps1';
executeScript 'DisableSleepIfVM.ps1';
executeScript 'FileExplorerSettings.ps1';
executeScript 'RemoveDefaultApps.ps1';
executeScript 'CommonDevTools.ps1';
executeScript 'WindowsPowerUser.ps1';

#--- Setting up Chocolatey
executeScript 'ChocolateyExtensions.ps1';
executeScript 'ChocolateyGUI.ps1';

#--- Administrative Tools ---
executeScript 'HardwareMonitoring.ps1';
executeScript 'FileAndStorageUtils.ps1';
executeScript 'SQLServerManagementStudio.ps1'
executeScript 'NetworkTools.ps1';
executeScript 'RemoteAndLocalFileSystem.ps1';

#--- SSH Server ---
if ($InstallSSHServer | Select-String 'y') {
	executeScript 'OpenSSHServer.ps1';
}

executeScript 'UnofficialChocolateyTools.ps1';

Get-Content -Path $Boxstarter.Log | Select-String -Pattern '^Failures$' -Context 0, 2 >> (Join-Path $env:USERPROFILE 'Desktop\boxstarter-failures.log')

#--- reenabling critial items ---
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula

$SimpleLog = (Join-Path $env:USERPROFILE 'Desktop\last-installed.log')
if (-not(Test-Path $SimpleLog)) {
	New-Item -Path $SimpleLog -ItemType File
}
Add-Content -Path $SimpleLog -Value 'sysadmin'
