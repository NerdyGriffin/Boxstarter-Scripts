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
executeScript 'RemoveDefaultApps.ps1';
executeScript 'GameSymlinks.ps1';
executeScript 'NvidiaGraphics.ps1';
executeScript 'LogitechGaming.ps1'; RefreshEnv; Start-Sleep 0.5;
executeScript 'HardwareMonitoring.ps1'; RefreshEnv; Start-Sleep 0.5;
executeScript 'BenchmarkUtils.ps1'; RefreshEnv; Start-Sleep 0.5;
if ($env:USERDOMAIN | Select-String 'DESKTOP') {
	executeScript 'CorsairICue.ps1'; RefreshEnv; Start-Sleep 0.5;
	executeScript 'GameLaunchers.ps1'; RefreshEnv; Start-Sleep 0.5;
} else {
	executeScript 'MinimalGameLaunchers.ps1'; RefreshEnv; Start-Sleep 0.5;
}
executeScript 'GameModdingTools.ps1'; RefreshEnv; Start-Sleep 0.5;

#--- Service & Registry Tweaks for Origin with Mapped Network Drives

# Disable the "Origin Client Service" to force Origin to execute downloads as Administrator of your User rather than execute under the SYSTEM user account
Get-Service -Name 'Origin Client*' | Set-Service -StartupType Disabled

# Allow the Programs, which run as administrator, to see the Mapped Network Shares
If (!(Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System')) {
	New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Force | Out-Null
}
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLinkedConnections' -Type DWord -Value 1

Get-Content -Path $Boxstarter.Log | Select-String -Pattern '^Failures$' -Context 0, 2 >> (Join-Path $env:USERPROFILE 'Desktop\boxstarter-failures.log')

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
