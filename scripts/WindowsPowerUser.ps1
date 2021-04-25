#--- Windows 10 Tools ---
choco install -y autoruns
# choco install -y everything
# choco install -y mousewithoutborders
choco install -y powertoys
choco install -y plasso --ignore-checksums # The checksums are never correct on this package, that is to be expected
choco install -y reshack
choco install -y shutup10
choco install -y sharex
choco install -y sdio
# choco install -y winaero-tweaker
# choco install -y xyplorer

# Add a custom registry entry for running PowerToys at startup
$PowerToysCommand = """$env:ProgramFiles\PowerToys\PowerToys.exe"""
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name PowerToys -Value $PowerToysCommand

# Add a custom registry entry for running Sharex at startup
$SharexCommand = """$env:ProgramFiles\Sharex\sharex.exe"""
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name Sharex -Value $SharexCommand
# We want Sharex to always startup BEFORE OneDrive (to prevent OneDrive from hooking the print hotkey)
# This Sharex entry is added to 'HKLM:\...\Run' whereas the OneDrive startup entry is in 'HKCU:\...\Run' by default,
# Therefore we know that Sharex will always be started before OneDrive (because Windows always parses entries in 'HKLM:' first)
