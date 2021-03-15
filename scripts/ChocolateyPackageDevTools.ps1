#--- Chocolatey and Boxstarter Package Dev Tools
choco install -y Chocolatey-AutoUpdater
choco install -y ChocolateyPackageUpdater
try { choco install -y ChocolateyDeploymentUtils } catch {}
choco install -y boxstarter.chocolatey
choco install -y Boxstarter.TestRunner
if (Test-Path '\\GRIFFINUNRAID\Boxstarter\BuildPackages') {
	Set-BoxStarterConfig -LocalRepo '\\GRIFFINUNRAID\Boxstarter\BuildPackages'
}
