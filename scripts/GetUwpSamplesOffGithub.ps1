Update-SessionEnvironment
if (Test-Path 'C:\Program Files (x86)\GnuPG\bin\gpg.exe') {
	git config --global gpg.program 'C:\Program Files (x86)\GnuPG\bin\gpg.exe'
}
Set-Location C:\Github
mkdir UwpSamples
Set-Location UwpSamples
git clone https://github.com/Microsoft/Windows-universal-samples/