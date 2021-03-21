#--- Windows 10 Tools ---
choco install -y autoruns
# choco install -y everything
# choco install -y mousewithoutborders
choco install -y powertoys
choco install -y plasso --ignore-checksums # The checksums are never correct on this package, that is to be expected
choco install -y reshack
choco install -y shutup10
choco install -y sharex
# choco install -y winaero-tweaker
# choco install -y xyplorer

# Add a custom registry entry for running Sharex at startup
$SharexCommand = """$env:ProgramFiles\Sharex\sharex.exe"""
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name Sharex -Value $SharexCommand

# # Modify the OneDrive startup entry to delay, so that it starts after Sharex (to prevent OneDrive from hooking the print hotkey)
# $CurrentOneDriveCommand = Get-ItemPropertyValue -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name OneDrive;
# $NewOneDriveCommand = "$CurrentOneDriveCommand";
# Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name OneDrive -Value $NewOneDriveCommand;
