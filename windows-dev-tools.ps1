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

#--- Powershell Module Repository
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

#--- Windows Subsystems/Features ---
executeScript 'HyperV.ps1';
executeScript 'WSL.ps1';
choco install Microsoft-Windows-Subsystem-Linux -source windowsfeatures

Start-Sleep -Milliseconds 500; refreshenv; Start-Sleep -Milliseconds 500

#--- Windows Dev Essentials
choco install -y dotnet
choco install -y dotnet-sdk
choco install -y dotnetcore
choco install -y dotnetcore-sdk
choco install -y dotnetcoresdk
# choco install -y dotpeek # Installer appears to be broken on my machine
choco install -y linqpad
choco install -y vscode
choco install -y chocolatey-vscode
choco install -y git --package-parameters="'/GitAndUnixToolsOnPath /WindowsTerminal'"
refreshenv

#--- Gitkraken ---
choco install -y gitkraken

#--- Other Git Tools ---
choco install -y Gpg4win
choco install -y lepton
refreshenv

#--- Configure Git ---
executeScript 'ConfigureGit.ps1';

choco upgrade -y powershell
choco upgrade -y au

choco upgrade -y powershell-core
# choco install -y azure-cli
choco upgrade -y microsoft-windows-terminal; choco upgrade -y microsoft-windows-terminal # Does this twice because the first attempt often fails but leaves the install partially completed, and then it completes successfully the second time.

#--- Workload needed for Column UI Dev
choco install -y visualstudio2019community
choco install -y visualstudio2019-workload-nativedesktop
choco install -y visualstudio2019-workload-vctools

#--- Workload needed for gordon-360-api
choco install -y visualstudio2017community
# choco install -y nuget.commandline
choco install -y visualstudio2017-workload-manageddesktop
choco install -y visualstudio2017-workload-netweb

choco install -y gitdiffmargin

Start-Sleep -Milliseconds 500; refreshenv; Start-Sleep -Milliseconds 500

#--- Assorted Dev Tools and Dependencies
choco install -y androidstudio
choco install -y arduino
choco install -y electron
choco install -y fiddler
choco install -y HexEdit
choco install -y hxd
choco install -y meld
choco install -y ngrok
choco install -y notepadplusplus
choco install -y mcr-r2019a
choco install -y nvm
choco install -y openjdk8
choco install -y openjdk11
choco install -y pip
choco install -y python3
choco install -y sublimetext3

executeScript 'PythonMLTools.ps1';

Start-Sleep -Milliseconds 500; refreshenv; Start-Sleep -Milliseconds 500

#--- Advanced Network Tools ---
# choco install -y advanced-ip-scanner # Possibly broken for FOSS users
# choco install -y ipscan # Possibly broken for FOSS users
choco install -y wireshark

#--- PowerShell Tools ---
choco install -y checksum
# choco install -y ConEmu
choco install -y curl
choco install -y llvm
choco install -y psutils
choco install -y rsync
choco install -y unzip
choco install -y winscreenfetch
choco install -y zip

executeScript 'GNU.ps1';
executeScript 'OpenSSHServer.ps1';

Start-Sleep -Milliseconds 500; refreshenv; Start-Sleep -Milliseconds 500

# #--- Chocolatey and Boxstarter Package Dev Tools
# choco install -y Chocolatey-AutoUpdater
# choco install -y ChocolateyPackageUpdater
# try { choco install -y ChocolateyDeploymentUtils } catch {}
# choco install -y boxstarter.chocolatey
# choco install -y Boxstarter.TestRunner

#--- Fonts ---
choco install -y cascadiafonts

#--- Configure Powershell Profile for Powerline and PSReadline ---
try { Boxstarter.bat nerdygriffin.Configure-PowerShell } catch {
	try {
		Install-BoxstarterPackage -PackageName 'https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/configure-powershell.ps1'
	} catch {}
}

Get-Content -Path $Boxstarter.Log | Select-String -Pattern '^Failures$' -Context 0, 2 >> (Join-Path $env:USERPROFILE 'Desktop\boxstarter-failures.log')

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
