choco install -y google-backup-and-sync
# choco install -y megasync

$NextcloudPlaceholder = Join-Path (Get-LibraryNames).Desktop 'nextcloud-placeholder'
if (Test-Path $NextcloudPlaceholder) {
	Remove-Item -Path $NextcloudPlaceholder
} else {
	New-Item -Path $NextcloudPlaceholder -ItemType File -Value 'This is just a marker for the script. You may delete this file'
	choco install -y nextcloud-client
}
