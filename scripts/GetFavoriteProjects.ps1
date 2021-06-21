Update-SessionEnvironment
git config --global gpg.program $(Resolve-Path (Get-Command gpg | Select-Object -Expand Source) | Select-Object -Expand Path)
Set-Location C:\Github
# Feel free to customize this with your own preferred projects
git clone https://github.com/NerdyGriffin/Boxstarter-Scripts
git clone https://github.com/PowerShell/PowerShell
git clone https://github.com/chocolatey-community/chocolatey-coreteampackages.git
git clone https://github.com/gordon-cs/gordon-360-api
git clone https://github.com/gordon-cs/gordon-360-ui
git clone https://github.com/microsoft/winappdriver
git clone https://github.com/microsoft/windows-dev-box-setup-scripts
git clone https://github.com/microsoft/wsl
