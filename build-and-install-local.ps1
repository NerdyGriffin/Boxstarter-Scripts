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

. { Invoke-WebRequest -useb https://boxstarter.org/bootstrapper.ps1 } | Invoke-Expression; Get-Boxstarter -Force

if (Test-Path '\\GRIFFINUNRAID\Boxstarter') {
	Set-BoxStarterConfig -LocalRepo '\\GRIFFINUNRAID\Boxstarter\BuildPackages'
}

# Create an ArrayList to store the PackageInfo objects
[PackageInfo[]]$BoxstarterPackageArray = [System.Collections.ArrayList]::new()

# Add a PackageInfo object for each of the packages that we want to build and install
[void]$BoxstarterPackageArray.Add([PackageInfo]::new('nerdygriffin.MoveLibraries', '.\move-library-directories.ps1'))
[void]$BoxstarterPackageArray.Add([PackageInfo]::new('nerdygriffin.DefaultInstall', '.\nerdygriffin.ps1'))
[void]$BoxstarterPackageArray.Add([PackageInfo]::new('nerdygriffin.DevInstall', '.\windows-dev-tools.ps1'))
[void]$BoxstarterPackageArray.Add([PackageInfo]::new('nerdygriffin.GameInstall', '.\gaming.ps1'))
[void]$BoxstarterPackageArray.Add([PackageInfo]::new('nerdygriffin.ConfigureUI', '.\configure-ui.ps1'))
[void]$BoxstarterPackageArray.Add([PackageInfo]::new('nerdygriffin.Privacy', '.\privacy.ps1'))
[void]$BoxstarterPackageArray.Add([PackageInfo]::new('nerdygriffin.RemoveWindowsApps', '.\removeWindowsApps.ps1'))

# For each package in the list, attempt to build the package
foreach ($Package in $BoxstarterPackageArray) {
	#--- Create or Update the builds of the packages in the local repo ---
	if (Test-Path (Join-Path $Boxstarter.LocalRepo $Package.PackageName)) {
		Get-Content $Package.SourcePath | Set-Content (Join-Path $Boxstarter.LocalRepo $Package.PackageName '\tools\ChocolateyInstall.ps1') ` -Force
	} else {
		New-PackageFromScript -Source $Package.Source -PackageName $Package.PackageName
	}
	Invoke-BoxStarterBuild $Package.PackageName
	Start-Sleep -Seconds 1
}

# New-BoxstarterPackage nerdygriffin.MoveLibraries -ErrorAction SilentlyContinue
# Get-Content .\move-library-directories.ps1 | Set-Content (Join-Path $Boxstarter.LocalRepo 'nerdygriffin.MoveLibraries\Tools\ChocolateyInstall.ps1') ` -Force
# Invoke-BoxStarterBuild nerdygriffin.MoveLibraries
# Start-Sleep -Seconds 1

# New-BoxstarterPackage nerdygriffin.DefaultInstall -ErrorAction SilentlyContinue
# Get-Content .\nerdygriffin.ps1 | Set-Content (Join-Path $Boxstarter.LocalRepo 'nerdygriffin.DefaultInstall\Tools\ChocolateyInstall.ps1') ` -Force
# Invoke-BoxStarterBuild nerdygriffin.DefaultInstall
# Start-Sleep -Seconds 1

# New-BoxstarterPackage nerdygriffin.GameInstall -ErrorAction SilentlyContinue
# Get-Content .\gaming.ps1 | Set-Content (Join-Path $Boxstarter.LocalRepo 'nerdygriffin.GameInstall\Tools\ChocolateyInstall.ps1') ` -Force
# Invoke-BoxStarterBuild nerdygriffin.GameInstall
# Start-Sleep -Seconds 1

# New-BoxstarterPackage nerdygriffin.DevInstall -ErrorAction SilentlyContinue
# Get-Content .\windows-dev-tools.ps1 | Set-Content (Join-Path $Boxstarter.LocalRepo 'nerdygriffin.DevInstall\Tools\ChocolateyInstall.ps1') ` -Force
# Invoke-BoxStarterBuild nerdygriffin.DevInstall
# Start-Sleep -Seconds 1

# New-BoxstarterPackage nerdygriffin.ConfigureUI -ErrorAction SilentlyContinue
# Get-Content .\configure-ui.ps1 | Set-Content (Join-Path $Boxstarter.LocalRepo 'nerdygriffin.ConfigureUI\Tools\ChocolateyInstall.ps1') ` -Force
# Invoke-BoxStarterBuild nerdygriffin.ConfigureUI
# Start-Sleep -Seconds 1

# New-BoxstarterPackage nerdygriffin.Privacy -ErrorAction SilentlyContinue
# Get-Content .\privacy.ps1 | Set-Content (Join-Path $Boxstarter.LocalRepo 'nerdygriffin.Privacy\Tools\ChocolateyInstall.ps1') ` -Force
# Invoke-BoxStarterBuild nerdygriffin.Privacy
# Start-Sleep -Seconds 1

# New-BoxstarterPackage nerdygriffin.RemoveWindowsApps -ErrorAction SilentlyContinue
# Get-Content .\removeWindowsApps.ps1 | Set-Content (Join-Path $Boxstarter.LocalRepo 'nerdygriffin.RemoveWindowsApps\Tools\ChocolateyInstall.ps1') ` -Force
# Invoke-BoxStarterBuild nerdygriffin.RemoveWindowsApps
# Start-Sleep -Seconds 1
#--- --- --- --- --- --- --- ---

#--- Install each of the packages using the builds in the local repo ---
# $creds = Get-Credential (Join-Path $env:USERDOMAIN $env:USERNAME)
foreach ($Package in $BoxstarterPackageArray) {
	try {
		\\GRIFFINUNRAID\Boxstarter\BoxStarter $Package.PackageName
	} catch {
		Install-BoxstarterPackage $Package.PackageName
		# Install-BoxstarterPackage -ComputerName $env:USERDOMAIN -PackageName $Package.PackageName -Credential $creds
	}
	Write-Host 'Pausing for 1 second before installing the next package...' -ForegroundColor Cyan
	Start-Sleep -Seconds 1
}

Write-Debug 'The script completed successfully' -ForegroundColor Green
Write-Debug 'You may view the log file at' $Boxstarter.Log
Write-Debug 'You may view the log file at' $Boxstarter.Log
