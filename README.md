![License](https://img.shields.io/badge/License-MIT-greeen)
![Version](https://img.shields.io/badge/Version-1.0.0-blue)

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
Script distribution must be done via group policy, Sysmon binaries must be placed in a network share or in the sysvol volume of the domain controller.

### Features
* Install Sysmon if it is not installed.
* Upgrade Sysmon if the version does not match the updated version.
* Updates Sysmon configuration in case of changes
* Automatic control of system architecture (32/64 bit).
* Script activity logging and logrotate function.

### Remote Loggin

### Local Logging

<!-- GETTING STARTED -->
## Getting Started
### Script Settings
Local Logging script:
```PowerShell
# Change the path according to your environment
$SharedSysmonFolder = '\\PATH\Symon'
```

### Testing
Tested on Windows 10 and Windows server 2016 and later.
NB:


## Links 🌐
* Sysmon: https://learn.microsoft.com/it-it/sysinternals/downloads/sysmon

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
