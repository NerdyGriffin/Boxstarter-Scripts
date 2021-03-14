try {
	Disable-UAC

	if (Get-Command choco -ErrorAction SilentlyContinue) {
		choco install -y git
		choco install -y Gpg4win
		refreshenv
	}

	#--- Configure Git ---
	git config --global user.name 'Christian Kunis'
	git config --global user.email 'ckunis98@gmail.com'
	if (Get-Command nano -ErrorAction SilentlyContinue) {
		git config --global core.editor nano
	} else {
		git config --global core.editor code
	}
	git config --global core.symlinks true
	git config --global core.autocrlf input
	git config --global core.eol lf
	git config --global color.status auto
	git config --global color.diff auto
	git config --global color.branch auto
	git config --global color.interactive auto
	git config --global color.ui true
	git config --global color.pager true
	git config --global color.showbranch auto
	git config --global alias.co checkout
	git config --global alias.br branch
	git config --global alias.ci commit
	git config --global alias.st status
	git config --global alias.ft fetch
	git config --global alias.ps push
	git config --global alias.ph push
	git config --global alias.pl pull
	if (Test-Path 'C:\Program Files (x86)\GnuPG\bin\gpg.exe') {
		git config --global gpg.program 'C:\Program Files (x86)\GnuPG\bin\gpg.exe'
	}
	git config --global --list

	Get-Content -Path $Boxstarter.Log | Select-String -Pattern 'Failures' -NotMatch 'Select-String -Pattern' -Context 0, 2 >> (Join-Path $env:USERPROFILE 'Desktop\boxstarter-failures.log')

	Enable-UAC

	Write-Host 'nerdygriffin.Configure-Git completed successfully' | Write-Debug
	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
} catch {
	Write-Host 'Error occurred in nerdygriffin.Configure-Git' $($_.Exception.Message) | Write-Debug
	Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
	throw $_.Exception
}