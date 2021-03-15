#requires -version 3
#Requires -RunAsAdministrator

# try {
class PackageInfo {
	[ValidateNotNullOrEmpty()][string]$PackageName # The name of the package
	[ValidateNotNullOrEmpty()][string]$SourcePath # The path to the source code

	# Class Constructor
	PackageInfo(
		[string]$name,
		[string]$path
	) {
		$this.PackageName = $name
		$this.SourcePath = $path
	}
}

if (-Not(Get-Command New-BoxstarterPackage -ErrorAction SilentlyContinue)) {
	if (Get-Command choco -ErrorAction SilentlyContinue) {
		choco upgrade -y Boxstarter
	} else {
		Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1')); Get-Boxstarter -Force
	}
}
refreshenv

if ((Test-Path '\\GRIFFINUNRAID\Boxstarter') -And (-Not($Boxstarter.LocalRepo -eq '\\GRIFFINUNRAID\Boxstarter'))) {
	Set-BoxStarterConfig -LocalRepo '\\GRIFFINUNRAID\Boxstarter\BuildPackages'
}

# Create an ArrayList to store the PackageInfo objects
[PackageInfo[]]$BoxstarterPackageArray = @(
	[PackageInfo]::new('nerdygriffin.Move-Libraries', (Join-Path $PSScriptRoot 'move-library-directories.ps1')),
	[PackageInfo]::new('nerdygriffin.DefaultInstall', (Join-Path $PSScriptRoot 'nerdygriffin.ps1')),
	[PackageInfo]::new('nerdygriffin.DevTools', (Join-Path $PSScriptRoot 'windows-dev-tools.ps1')),
	[PackageInfo]::new('nerdygriffin.Configure-Git', (Join-Path $PSScriptRoot 'configure-git.ps1')),
	[PackageInfo]::new('nerdygriffin.Configure-PowerShell', (Join-Path $PSScriptRoot 'configure-powershell.ps1')),
	[PackageInfo]::new('nerdygriffin.WSL', (Join-Path $PSScriptRoot 'wsl.ps1'))
	[PackageInfo]::new('nerdygriffin.Gaming', (Join-Path $PSScriptRoot 'gaming.ps1')),
	[PackageInfo]::new('nerdygriffin.Configure-UI', (Join-Path $PSScriptRoot 'configure-ui.ps1')),
	[PackageInfo]::new('nerdygriffin.Privacy', (Join-Path $PSScriptRoot 'privacy.ps1')),
	[PackageInfo]::new('nerdygriffin.RemoveWindowsApps', (Join-Path $PSScriptRoot 'removeWindowsApps.ps1'))
)

$ConfirmBuild = Read-Host 'Would you like to rebuild the packages in the local repo? [y/n]'
if ($ConfirmBuild -eq 'y') {
	# For each package in the list, attempt to build the package
	foreach ($Package in $BoxstarterPackageArray) {
		Write-Host ''
		#--- Create or Update the builds of the packages in the local repo ---
		if (Test-Path (Join-Path $Boxstarter.LocalRepo ($Package.PackageName))) {
			Remove-Item -Path (Join-Path $Boxstarter.LocalRepo ($Package.PackageName)) -Recurse -Force
		}
		New-BoxstarterPackage -Name ($Package.PackageName) -path (Join-Path $PSScriptRoot 'tools')
		Get-Content $Package.SourcePath | Set-Content (Join-Path (Join-Path $Boxstarter.LocalRepo ($Package.PackageName)) '\tools\ChocolateyInstall.ps1') ` -Force
		Invoke-BoxStarterBuild ($Package.PackageName)
		Start-Sleep -Seconds 2
	}
	# Do the same for the deploy script (kept out of the array because we don't want it to install itself)
	$Package = [PackageInfo]::new('nerdygriffin.Deploy-Local-Boxstarter', (Join-Path $PSScriptRoot 'Deploy-Local-Boxstarter.ps1'))
	Write-Host ''
	#--- Create or Update the builds of the packages in the local repo ---
	if (Test-Path (Join-Path $Boxstarter.LocalRepo ($Package.PackageName))) {
		Remove-Item -Path (Join-Path $Boxstarter.LocalRepo ($Package.PackageName)) -Recurse -Force
	}
	New-BoxstarterPackage -Name ($Package.PackageName) -path (Join-Path $PSScriptRoot 'tools')
	Get-Content $Package.SourcePath | Set-Content (Join-Path (Join-Path $Boxstarter.LocalRepo ($Package.PackageName)) '\tools\ChocolateyInstall.ps1') ` -Force
	Invoke-BoxStarterBuild ($Package.PackageName)
	Start-Sleep -Seconds 2
}

$ConfirmInstall = Read-Host 'Would you like to install the packages from the local repo? [y/n]'
if ($ConfirmInstall -eq 'y') {
	#--- Install each of the packages using the builds in the local repo ---
	# $creds = Get-Credential (Join-Path $env:USERDOMAIN $env:USERNAME)
	foreach ($Package in $BoxstarterPackageArray) {
		try {
			\\GRIFFINUNRAID\Boxstarter\BoxStarter.bat ($Package.PackageName)
		} catch {
			try {
				Boxstarter.bat ($Package.PackageName)
			} catch {
				Install-BoxstarterPackage ($Package.PackageName)
				# Install-BoxstarterPackage -ComputerName $env:USERDOMAIN -PackageName ($Package.PackageName) -Credential $creds
			}
		}
		Write-Host 'Pausing for 1 second before installing the next package...' -ForegroundColor Cyan
		Start-Sleep -Seconds 1;
	}
}

# 	Write-Host 'nerdygriffin.Deploy-Local-Boxstarter completed successfully' | Write-Debug
# 	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
# } catch {
# 	Write-Host 'Error occurred in nerdygriffin.Deploy-Local-Boxstarter' $($_.Exception.Message) | Write-Debug
# 	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
# 	throw $_.Exception
# }
