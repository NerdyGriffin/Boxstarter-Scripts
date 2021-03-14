#--- Browsers ---
choco install -y brave
choco install -y chromium
choco install -y firefox
try {
	choco install -y googlechrome
} catch {
	choco install -y googlechrome --ignore-checksums
}
