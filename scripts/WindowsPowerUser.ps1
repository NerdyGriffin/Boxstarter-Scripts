#--- Windows 10 Tools ---
# choco install -y everything
# choco install -y mousewithoutborders
choco install -y powertoys
try {
	choco install -y plasso
} catch {
	choco install -y plasso --ignore-checksums
}
choco install -y procexp
choco install -y procmon
choco install -y reshack
choco install -y shutup10
choco install -y sharex
choco install -y winaero-tweaker
# choco install -y xyplorer
