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

try {
	Enable-RemoteDesktop
} catch {
	# Do nothing if Enable-RemoteDesktop fails, because it will fail if RemoteDesktop is already enabled
}

if (Test-Path '\\GRIFFINUNRAID\Boxstarter\BuildPackages') {
	Set-BoxStarterConfig -LocalRepo '\\GRIFFINUNRAID\Boxstarter\BuildPackages'
}

#--- Setting up Windows ---
executeScript 'SystemConfiguration.ps1';
executeScript 'FileExplorerSettings.ps1';
executeScript 'TaskbarSettings.ps1';
executeScript 'RemoveDefaultApps.ps1';
executeScript 'ChocolateyExtensions.ps1';
executeScript 'NvidiaGraphics.ps1';
executeScript 'PasswordManager.ps1';
executeScript 'Browsers.ps1';
executeScript 'CommunicationApps.ps1';
executeScript 'Multimedia.ps1';
executeScript 'CommonDevTools.ps1';
executeScript 'PythonMLTools.ps1';
executeScript 'WSL.ps1';

#--- Chocolatey GUI ---
# choco install -y ChocolateyExplorer
choco install -y ChocolateyGUI

#--- Office Suite ---
choco install -y adobereader
choco install -y libreoffice-fresh
choco install -y xournalplusplus

#--- E-Books ---
choco install -y calibre
choco install -y kindle

#--- LaTeX ---
choco install -y texlive

#--- Scientific ---
choco install -y geogebra
choco install -y gnuplot
choco install -y octave

executeScript 'RemoteFileAccess.ps1';
executeScript 'FileAndStorageUtils.ps1';
executeScript 'UnofficialChocolateyTools.ps1';

#--- Windows Settings ---
Disable-BingSearch
Disable-GameBarTips

Get-Content -Path $Boxstarter.Log | Select-String -Pattern '^Failures$' -Context 0, 2 >> (Join-Path $env:USERPROFILE 'Desktop\boxstarter-failures.log')

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
