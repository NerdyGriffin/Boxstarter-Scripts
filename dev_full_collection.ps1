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

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

#--- Powershell Module Repository
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

#--- Setting up Windows ---
executeScript 'SystemConfiguration.ps1';
executeScript 'DisableSleepIfVM.ps1';
executeScript 'FileExplorerSettings.ps1';
executeScript 'RemoveDefaultApps.ps1';
executeScript 'CommonDevTools.ps1';

#--- Windows Dev Essentials
executeScript 'DotNetTools.ps1';
# choco install -y dotpeek # Installer appears to be broken on my machine
# choco install -y linqpad

executeScript 'ConfigureGit.ps1';
choco install -y lepton

#--- Configure Powershell Profile for Powerline and PSReadline ---
executeScript 'ConfigurePowerShell.ps1';

#--- Assorted PowerShellTools ---
executeScript 'PowerShellTools.ps1';
executeScript 'GNU.ps1';

#--- Tools ---
#--- Installing VS and VS Code with Git
# See this for install args: https://chocolatey.org/packages/VisualStudio2017Community
# https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-community
# https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio#list-of-workload-ids-and-component-ids
# visualstudio2017community
# visualstudio2017professional
# visualstudio2017enterprise

choco install -y visualstudio2017community --package-parameters="'--add Microsoft.VisualStudio.Component.Git'"
Update-SessionEnvironment #refreshing env due to Git install

#--- Web Dev Tools ---
code --install-extension msjsdiag.debugger-for-chrome
code --install-extension msjsdiag.debugger-for-edge

#--- Web Dev Tools ---
choco install -y nodejs-lts # Node.js LTS, Recommended for most users
# choco install -y nodejs # Node.js Current, Latest features
choco install -y visualstudio2017buildtools
choco install -y visualstudio2017-workload-vctools
# choco install -y python2 # Node.js requires Python 2 to build native modules

RefreshEnv;
Start-Sleep -Seconds 1;

#--- Gordon 360 Api Workload ---
choco install -y nuget.commandline
choco install -y visualstudio2017-workload-netweb

RefreshEnv;
Start-Sleep -Seconds 1;

#--- UWP Workload and installing Windows Template Studio ---
choco install -y visualstudio2017-workload-azure
choco install -y visualstudio2017-workload-universal
choco install -y visualstudio2017-workload-manageddesktop
choco install -y visualstudio2017-workload-nativedesktop

RefreshEnv;
Start-Sleep -Seconds 1;

#--- Column UI Workload ---
choco install -y visualstudio2019community --package-parameters="'--add Microsoft.VisualStudio.Component.Git'"
choco install -y visualstudio2019-workload-nativedesktop
choco install -y visualstudio2019-workload-vctools

RefreshEnv;
Start-Sleep -Seconds 1;

#--- Assorted Dev Tools and Dependencies ---
executeScript 'MiscDevTools.ps1';
# executeScript 'Matlab.ps1';
executeScript 'OpenJDK.ps1';

#--- Machine Learning Tools ---
executeScript 'GetMLIDEAndTooling.ps1';
executeScript 'PythonMLTools.ps1';

# executeScript 'HyperV.ps1';
# executeScript 'WSL.ps1';

# try {
# 	Write-Host 'Installing tools inside the WSL distro...'
# 	Ubuntu1804 run apt install neofetch -y
# 	Ubuntu1804 run apt install nodejs -y
# 	Ubuntu1804 run apt install git-core -y
# 	Ubuntu1804 run apt install git-extras -y
# 	Ubuntu1804 run apt install python2.7 python-pip -y
# 	Ubuntu1804 run apt install python-numpy python-scipy -y
# 	Ubuntu1804 run pip install pandas
# } catch {
# 	# Skip for now
# }

# checkout recent projects
executeScript 'GetFavoriteProjects.ps1'

# executeScript 'GetUwpSamplesOffGithub.ps1';
# executeScript 'WindowsTemplateStudio.ps1';

Get-Content -Path $Boxstarter.Log | Select-String -Pattern '^Failures$' -Context 0, 2 >> (Join-Path $env:USERPROFILE 'Desktop\boxstarter-failures.log')

#--- reenabling critial items ---
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula

$SimpleLog = (Join-Path $env:USERPROFILE 'Desktop\last-installed.log')
if (-not(Test-Path $SimpleLog)) {
	New-Item -Path $SimpleLog -ItemType File
}
Add-Content -Path $SimpleLog -Value 'dev_full_collection'
