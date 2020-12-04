# Multipurpose-Boxstarter-Scripts

This is a collection of customized Boxstarter scripts and packages that I use to quickly deploy all of my programs and settings on a new or existing Windows 10 installation.

Starter code came from <https://gist.github.com/NerdyGriffin/3fe7cc0de51fddb4bb499919d597ca50>

Based on code from <https://gist.github.com/petevb/67f78762537e742015da018a33558119>

1. If you're using a Chromium browser, enable click-once via (e.g. for Edge) [`edge://flags/#edge-click-once`](edge://flags/#edge-click-once).

## Install the stuff below (i.e. my `boxstarter.txt`)

> **WARNING**: Clicking these links will install apps on your machine; _Please_ review the scripts before you do that!

1. [Move Library Directories](https://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/NerdyGriffin/Multipurpose-Boxstarter-Scripts/main/move-library-directories.ps1)

   - View script: <https://raw.githubusercontent.com/NerdyGriffin/Multipurpose-Boxstarter-Scripts/main/move-library-directories.ps1>

2. **Install** [NerdyGriffin's default programs](https://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/NerdyGriffin/Multipurpose-Boxstarter-Scripts/main/nerdygriffin.ps1).

   - View script: <https://raw.githubusercontent.com/NerdyGriffin/Multipurpose-Boxstarter-Scripts/main/nerdygriffin.ps1>

3. Install [Windows Gaming Software](https://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/NerdyGriffin/Multipurpose-Boxstarter-Scripts/main/gaming.ps1)

   - View script: <https://raw.githubusercontent.com/NerdyGriffin/Multipurpose-Boxstarter-Scripts/main/gaming.ps1>

4. Install [Windows Dev Tools](https://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/NerdyGriffin/Multipurpose-Boxstarter-Scripts/main/windows-dev-tools.ps1)

   - View script: <https://raw.githubusercontent.com/NerdyGriffin/Multipurpose-Boxstarter-Scripts/main/windows-dev-tools.ps1>

5. Install [WSL](https://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/NerdyGriffin/Multipurpose-Boxstarter-Scripts/main/wsl.ps1)

   - View script: <https://raw.githubusercontent.com/NerdyGriffin/Multipurpose-Boxstarter-Scripts/main/wsl.ps1>

6. [Configure Windows UI](https://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/NerdyGriffin/Multipurpose-Boxstarter-Scripts/main/configure-ui.ps1)

   - View script: <https://raw.githubusercontent.com/NerdyGriffin/Multipurpose-Boxstarter-Scripts/main/configure-ui.ps1>

7. [Configure Windows privacy options](https://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/NerdyGriffin/Multipurpose-Boxstarter-Scripts/main/privacy.ps1)

   - View script: <https://raw.githubusercontent.com/NerdyGriffin/Multipurpose-Boxstarter-Scripts/main/privacy.ps1>

8. [Remove default Windows Store apps](https://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/NerdyGriffin/Multipurpose-Boxstarter-Scripts/main/removeWindowsApps.ps1)

   - View script: <https://raw.githubusercontent.com/NerdyGriffin/Multipurpose-Boxstarter-Scripts/main/removeWindowsApps.ps1>

## notes/sources

- <https://boxstarter.org/WebLauncher>
- <https://github.com/microsoft/windows-dev-box-setup-scripts>
- <https://gist.github.com/NickCraver/7ebf9efbfd0c3eab72e9>
- <https://gist.github.com/jessfraz/7c319b046daa101a4aaef937a20ff41f>
- <https://gist.github.com/petevb/67f78762537e742015da018a33558119>
- You might want to install the MS dev box package
  <http://boxstarter.org/package/url?https://raw.githubusercontent.com/Microsoft/windows-dev-box-setup-scripts/master/dev_web.ps1>

> Notes:
> If you are using WSL there's a followup step we recommend after running the setup script. When the script finishes you will only have a root user with a blank password. You should manually create a non-root user via `$ sudo adduser [USERNAME] sudo` with a non-blank password. Use this user going forward. For more info on WSL please refer to the documentation.

### example script

- <https://gist.github.com/mwrock/7382880/raw/f6525387b4b524b8eccef6ed4d5ec219c82c0ac7/gistfile1.txt>
