Function New-SymbolicLink {
	param(
		# Specifies the path of the location of the new link. You must include the name of the new link in Path .
		[Parameter(Mandatory = $true,
			Position = 0,
			ParameterSetName = 'ParameterSetName',
			ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true,
			HelpMessage = 'Specifies the path of the location of the new link. You must include the name of the new link in Path .')]
		[Alias('PSPath')]
		[ValidateNotNullOrEmpty()]
		[string]
		$Path,

		# Specifies the path of the location that you would like the link to point to.
		[Parameter(Mandatory = $true,
			Position = 1,
			HelpMessage = 'Specifies the path of the location that you would like the link to point to.')]
		[Alias('Target')]
		[ValidateNotNullOrEmpty()]
		[string]
		$Value
	)

	if ((Test-Path $Path) -And (Get-Item $Path | Where-Object Attributes -Match ReparsePoint)) {
		Write-Host  $Path 'is already a reparse point.' | Write-Warning
		Return $false
	}
	if (Test-Path "$Path\*") {
		# $MoveResult = (Move-Item -Path $Path\* -Destination $Value -Force -PassThru -Verbose)
		$MoveResult = (robocopy $Path $Value /ZB /FFT)
		if (-Not($MoveResult)) {
			Write-Host  'Something went wrong while trying to move the contents of' $Path 'to' $Value | Write-Warning
			Return $MoveResult
		}
		Remove-Item -Path $Path\* -Recurse -Force -ErrorAction Inquire
	}
	if (Test-Path $Path) {
		Remove-Item $Path -Recurse -Force
	}
	if (-Not(Test-Path $Value)) {
		New-Item -Path $Value -ItemType Directory
	}
	$Result = New-Item -Path $Path -ItemType SymbolicLink -Value $Value -Force -Verbose
	if ($Result) {
		Write-Host  'Successfully created SymLink at' $Path 'pointing to' $Value | Write-Verbose
		Return $true
	} else {
		Write-Host 'The following error occured while trying to make symlink: ' $Result | Write-Warning
		Return $false
	}
}

Disable-UAC

if (-Not(Get-Command New-SymbolicLink)) {
	Write-Error "The 'New-SymbolicLink' helper function was not found."
	throw
}

if (Test-Path 'D:\') {
	# SymbolicLinks in AppData
	$SymbolicLinkNames = @('Citra')
	if ($env:USERDOMAIN | Select-String 'LAPTOP') { $SymbolicLinkNames += @('.minecraft') }
	foreach ($FolderName in $SymbolicLinkNames) {
		New-SymbolicLink -Path (Join-Path $env:APPDATA $FolderName) -Value (Join-Path 'D:\' $FolderName)
	}
}

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
executeScript 'TaskbarSettings.ps1';
executeScript 'RemoveDefaultApps.ps1';
executeScript 'NvidiaGraphics.ps1';
executeScript 'LogitechGaming.ps1';
executeScript 'HardwareMonitoring.ps1';
executeScript 'BenchmarkUtils.ps1';
if ($env:USERDOMAIN | Select-String 'DESKTOP') {
	executeScript 'CorsairICue.ps1';
	executeScript 'GameLaunchers.ps1';
} else {
	executeScript 'MinimalGameLaunchers.ps1';
}
executeScript 'GameModdingTools.ps1';

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
