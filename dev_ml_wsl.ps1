# Description: Boxstarter Script
# Author: Microsoft
# Common dev settings for machine learning using Windows and Linux native tools

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

function drawLine([int]$length) {
	# Draw the Beginning of the line
	Write-Host '*' -NoNewline
	# Draw the length of the line
	foreach ($count in 1..($length)) { Write-Host '-' -NoNewline }
	# Draw the end
	Write-Host '*' -NoNewline
}

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
executeScript 'FileExplorerSettings.ps1';
executeScript 'RemoveDefaultApps.ps1';
executeScript 'CommonDevTools.ps1';
executeScript 'HyperV.ps1';
executeScript 'WSL.ps1';

Write-Host 'Installing tools inside the WSL distro...'
Ubuntu1804 run apt install python2.7 python-pip -y
Ubuntu1804 run apt install python-numpy python-scipy -y
Ubuntu1804 run pip install pandas

Write-Host 'Finished installing tools inside the WSL distro'

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
