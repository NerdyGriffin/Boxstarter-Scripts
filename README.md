# Boxstarter-Scripts

This is a collection of customized Boxstarter scripts and packages that I use to quickly deploy all of my programs and settings on a new or existing Windows 10 installation.

- Starter code came from <https://gist.github.com/NerdyGriffin/3fe7cc0de51fddb4bb499919d597ca50>
- Based on code from <https://gist.github.com/petevb/67f78762537e742015da018a33558119>
- And then the project was later refactored to match the style and structure of <https://github.com/microsoft/windows-dev-box-setup-scripts>

## About this project

The goal of this project is to provide a central place to share ideas for streamlining ~~dev box~~ multipurpose computer setup and provide sample scripts for common dev scenarios. It's likely you will want to take the scripts here and modify them to fit your particular needs. When you make those changes if you think others would benefit please consider submitting a PR. Before you contribute please see the [Contribution Guidelines](CONTRIBUTING.md).

These scripts leverage two popular open source projects.

- Boxstarter [boxstarter.org](http://boxstarter.org)
- Chocolatey [chocolatey.org](http://chocolatey.org)

Boxstarter is a wrapper for Chocolatey and includes features like managing reboots for you. We're using the Boxstarter web launcher to start the installation process:<br/>
https://boxstarter.org/Learn/WebLauncher

## Project structure

The script code is organized in a hierarchy

**Recipes**
A recipe is the script you run. It calls multiple helper scripts. These currently live in the root of the project (dev_app.ps1, dev_webnodejs.ps1, etc.)

**Helper Scripts**: A helper script performs setup routines that may be useful by many recipes. Recipes call helper scripts (you don't run helper scripts directly). The helper scripts live in the **scripts** folder

## You may want to customize the scripts

These scripts should cover a lot of what you need but will not likely match your personal preferences exactly. In this case please fork the project and change the scripts however you desire. We really appreciate PR's back to this project if you have recommended changes.

_Note: The one-click links use the following format. When working out of a different Fork or Branch you'll want to update the links as follows:_

`http://boxstarter.org/package/url?https://raw.githubusercontent.com/GITHUB_DOMAIN/windows-dev-box-setup-scripts/YOUR_BRANCH/RECIPE_NAME.ps1 `

For more info on testing your changes take a look at the [contribution guidelines](CONTRIBUTING.md).

## If you're using a Chromium browser, enable click-once via (e.g. for Edge) [`edge://flags/#edge-click-once`](edge://flags/#edge-click-once)

## How to run the scripts

Before you begin, please read the [Legal](#Legal) section.

To run a recipe script, click a link in the table below from your target machine. This will download the Boxstarter one-click application, and prompt you for Boxstarter to run with Administrator privileges (which it needs to do its job). Clicking yes in this dialog will cause the recipe to begin. You can then leave the job unattended and come back when it's finished.

| Click link to run                                                                                                                                                              | Description                                                                                     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------- |
| <a href='http://boxstarter.org/package/url?https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/daily_driver.ps1'>NerdyGriffin's Daily Driver Setup</a>      | Daily Driver (General Purpose Programs, Web Browser, Office Suite, Multimedia, etc.)            |
| <a href='http://boxstarter.org/package/url?https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/gaming.ps1'>NerdyGriffin's Gaming Setup</a>                  | Gaming                                                                                          |
| <a href='http://boxstarter.org/package/url?https://raw.githubusercontent.com/Microsoft/windows-dev-box-setup-scripts/master/dev_app.ps1'>Full Desktop App</a>                  | Windows Desktop App Development (Visual Studio, Windows SDK, C++, UWP, .NET (WPF and Winforms)) |
| <a href='http://boxstarter.org/package/url?https://raw.githubusercontent.com/Microsoft/windows-dev-box-setup-scripts/master/dev_app_desktop_uwp.ps1'>UWP Desktop App</a>       | Windows Desktop App Development (Visual Studio, Windows SDK, UWP)                               |
| <a href='http://boxstarter.org/package/url?https://raw.githubusercontent.com/Microsoft/windows-dev-box-setup-scripts/master/dev_app_desktop_.NET.ps1'>.NET Desktop App</a>     | Windows Desktop App Development (Visual Studio, Windows SDK, .NET (WPF and Winforms))           |
| <a href='http://boxstarter.org/package/url?https://raw.githubusercontent.com/Microsoft/windows-dev-box-setup-scripts/master/dev_app_desktop_cplusplus.ps1'>C++ Desktop App</a> | Windows Desktop App Development (Visual Studio, Windows SDK, C++)                               |
| <a href='http://boxstarter.org/package/url?https://raw.githubusercontent.com/Microsoft/windows-dev-box-setup-scripts/master/dev_web.ps1'>Web</a>                               | Web (VS Code, WSL, Multiple Browsers)                                                           |
| <a href='http://boxstarter.org/package/url?https://raw.githubusercontent.com/Microsoft/windows-dev-box-setup-scripts/master/dev_web_nodejs.ps1'>Web NodeJS</a>                 | Web Dev with NodeJS (Web + NodeJS LTS)¹                                                         |
| <a href='http://boxstarter.org/package/url?https://raw.githubusercontent.com/Microsoft/windows-dev-box-setup-scripts/master/dev_web_api.ps1'>Web API - ASP.NET</a>             | Web API Dev with ASP.NET                                                                        |
| <a href='http://boxstarter.org/package/url?https://raw.githubusercontent.com/Microsoft/windows-dev-box-setup-scripts/master/dev_ml_windows.ps1'>Machine Learning Windows</a>   | Machine Learning with only Windows native tools                                                 |
| <a href='http://boxstarter.org/package/url?https://raw.githubusercontent.com/Microsoft/windows-dev-box-setup-scripts/master/dev_ml_wsl.ps1'>Machine Learning Linux</a>         | Machine Learning with Linux tools running on WSL                                                |
| <a href='http://boxstarter.org/package/url?https://raw.githubusercontent.com/Microsoft/windows-dev-box-setup-scripts/master/devops_azure.ps1'>DevOps Azure</a>                 | Client setup for DevOps with Azure                                                              |
| <a href='http://boxstarter.org/package/url?https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/dev_multi_purpose.ps1'>Multi-Purpose Development </a>        | Assorted Development Tools for Desktop App, Web, and More                                       |
| <a href='http://boxstarter.org/package/url?https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/sysadmin.ps1'>Sysadmin</a>                                   | Tools for Amateur System Administration                                                         |
|                                                                                                                                                                                | Xamarin (Visual Studio, Xamarin, Android SDK)                                                   |
|                                                                                                                                                                                | Containers (Docker, Kubernetes, etc...)                                                         |
|                                                                                                                                                                                | Submit a PR with a recommended configuration!                                                   |

- [Move Library Directories](http://boxstarter.org/package/url?https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/move-library-directories.ps1)

  - This first script is very specific to my computer configuration and my home server. I do not reccommend using this script unless you want to customize it for your own devices.

**Notes:**

1. If you are using WSL there's a followup step we recommend after running the setup script. When the script finishes you will only have a root user with a blank password. You should manually create a non-root user via `$ sudo adduser [USERNAME] sudo`
   with a non-blank password. Use this user going forward. For more info on WSL please refer to the [documentation](https://docs.microsoft.com/en-us/windows/wsl/about).
2. If you're a Node.js contributor working on Node.js core, please see the [Node.js Bootstrapping Guide](https://github.com/nodejs/node/tree/master/tools/bootstrap) or [click here to run](http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/nodejs/node/master/tools/bootstrap/windows_boxstarter).

## Known issues

- The Boxstarter ClickOnce installer does not work when using Chrome. This issue is being tracked [here](https://github.com/chocolatey/boxstarter/issues/345). Please use Edge to run the ClickOnce installer.
- Reboot is not always logging you back in to resume the script. This is being tracked [here](https://github.com/chocolatey/boxstarter/issues/318). The workaround is to login manually and the script will continue running.
- There have been reports of Windows 1803 not successfully launching Boxstarter via the web launcher. See this issue for details: https://github.com/chocolatey/boxstarter/issues/301

## Credits and Acknowledgements

- <https://boxstarter.org/WebLauncher>
- <https://github.com/microsoft/windows-dev-box-setup-scripts>
- <https://gist.github.com/NickCraver/7ebf9efbfd0c3eab72e9>
- <https://gist.github.com/jessfraz/7c319b046daa101a4aaef937a20ff41f>
- <https://gist.github.com/petevb/67f78762537e742015da018a33558119>
- <https://github.com/ChrisTitusTech/win10script>
- You might want to install the MS dev box package
  <http://boxstarter.org/package/url?https://raw.githubusercontent.com/Microsoft/windows-dev-box-setup-scripts/master/dev_web.ps1>

### example script

- <https://gist.github.com/mwrock/7382880/raw/f6525387b4b524b8eccef6ed4d5ec219c82c0ac7/gistfile1.txt>

## To Do

- [ ] Refer to <https://github.com/microsoft/windows-dev-box-setup-scripts> for ways to improve this project

## Deprecated

### Install the stuff below (i.e. my `boxstarter.txt`)

> **WARNING**: Clicking these links will install apps on your machine; _Please_ review the scripts before you do that!

1. [Move Library Directories](https://boxstarter.org/package/url?https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/move-library-directories.ps1)

   - This first script is very specific to my computer configuration and my home server. I do not reccommend using this script unless you want to customize it for your own devices.
   - View script: <https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/move-library-directories.ps1>

2. **Install** [NerdyGriffin's default programs](https://boxstarter.org/package/url?https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/nerdygriffin.ps1).

   - View script: <https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/nerdygriffin.ps1>

3. Install [Windows Dev Tools](https://boxstarter.org/package/url?https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/windows-dev-tools.ps1)

   - View script: <https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/windows-dev-tools.ps1>

4. Install [Windows Gaming Software](https://boxstarter.org/package/url?https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/gaming.ps1)

   - View script: <https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/gaming.ps1>

5. Install [Configure PowerShell for NerdyGriffin](https://boxstarter.org/package/url?https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/configure-powershell.ps1)

   - View script: <https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/configure-powershell.ps1>

6. Install [WSL](https://boxstarter.org/package/url?https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/wsl.ps1)

   - View script: <https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/wsl.ps1>

7. [Configure Windows UI](https://boxstarter.org/package/url?https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/configure-ui.ps1)

   - View script: <https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/configure-ui.ps1>

8. [Configure Windows privacy options](https://boxstarter.org/package/url?https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/privacy.ps1)

   - View script: <https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/privacy.ps1>

9. [Remove default Windows Store apps](https://boxstarter.org/package/url?https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/removeWindowsApps.ps1)

   - View script: <https://raw.githubusercontent.com/NerdyGriffin/Boxstarter-Scripts/main/removeWindowsApps.ps1>
