![License](https://img.shields.io/github/license/KolimaH4x/Sysmon-Automation)
![Release](https://img.shields.io/github/release/KolimaH4x/Sysmon-Automation.svg)
![Downloads](https://img.shields.io/github/downloads/KolimaH4x/Sysmon-Automation/total.svg)
![Stars](https://img.shields.io/github/stars/KolimaH4x/Sysmon-Automation?color=yellow)

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/KolimaH4x/Sysmon-Automation">
    <img src="media/logo.png" alt="Logo" width="110" height="110">
  </a>

  <h3 align="center">Sysmon Automation</h3>

  <p align="center">
    A PowerShell script which helps you in Sysmon Management!
    <br/>
    <br/>
    <a href="https://github.com/KolimaH4x/Sysmon-Automation/issues">Report Bug</a>
    ·
    <a href="https://github.com/KolimaH4x/Sysmon-Automation/issues">Request Feature</a>
  </p>
</div>

<!-- ABOUT THE PROJECT -->
# About the project
![Sysmon](https://github.com/KolimaH4x/Sysmon-Automation/blob/main/media/sysmon.jpg)

Automate management and maintenance of the Sysmon tool on your Windows systems with PowerShell. \
This script helps sysadmins and cyber secuirty analysts deploy and maintain the Sysmon monitoring tool from Sysinternals. \
Script distribution must be done via group policy, The script automatically download the Sysmon binaries directly from the official Sysinternals web site and the configuration file from the SwiftOnSecurity template.

### Features
* Automatic download of Sysmon executables and configuration file.
* Install Sysmon if it is not installed.
* Upgrade Sysmon if the installed version does not match the latest version.
* Updates Sysmon configuration.
* Automatic control of system architecture (32/64 bit).
* Script activity logging.

### Monitor script activity with SIEM
It is possible to monitor the script's activities centrally through monitoring systems such as SIEM.\
The script automatically creates a registry called "Sysmon Automation", the logs will be recorded within the Application section of the Event Viewer.

### Testing

Tested on Windows 10 and Windows Server 2016 and later. \
Problems may occur in the following cases:
* Outdated versions such as Windows Server 2012/2012 R2 (installation fail).
* Outdated versions such as Windows Server 2008/2008 R2 and earlier (system crash).
* If the OS architecture is 64-bit and the 32-bit version (Sysmon.exe) is already installed.

<!-- GETTING STARTED -->
## Getting Started
### Script Settings
Modify sysmon-automation.ps1 so that $SysmonConfigURL points to a URL or path reachable by all hosts (e.g. Sysvol/Netlogon folder) containing the configuration file. By default, the script downloads the SwiftOnSecurity template.
```PowerShell
# Change the configuration file source as needed
$SysmonConfigURL = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml"
```

### GPO Settings

1. Open the *Group Policy Management Console* (`gpmc.msc`), create a new GPO, and link it to an Organizational Unit with computers you want to assign the task to;
2. Go to User *Configuration* -> *Preferences* -> *Control Panel Setting*s -> *Scheduled Tasks*;
3. Create a new scheduled task: *New* -> *Scheduled task (At least Windows 7)*;
4. You will see a form similar to the standard Windows Scheduler task configuration window. Configure the settings of your task;
5. On the General tab, set *Action* = `Create`, enter the task name. Change the user to **NT AUTHORITY\System**. Set it to Run whether user is logged on or not, then set **Run with highest privileges**.
6. Navigate to the Triggers tab. Specify the date and time when you want to run the task. Select *New* -> *Begin the task On a schedule* -> *Daily*, and specify the time to start the task;
7. On the Actions tab, specify a command or a script you want to run using the Task Scheduler. Configure the following task options:\
Action: Start a program\
Program/Script: `powershell.exe`\
Add Arguments: `-ExecutionPolicy Bypass -File \\yourdomain.internal\Netlogon\Sysmon\sysmon-automation.ps1` (change the path according to your infrastructure)
8.  Navigate to the Settings tab. Check Run task as soon as possible after a scheduled start is missed. Then click OK to save the scheduled task.
9. Open the Task Scheduler (`taskschd.msc`) and make sure that a new task has appeared in the Task Scheduler Library. Make sure that it is run according to the schedule.


<!-- LINKS -->
## Links 🌐
* Sysmon: https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon

* Sysmon Configuration: https://github.com/SwiftOnSecurity/sysmon-config

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.
