<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/KolimaH4x/Sysmon-Automation">
    <img src="media/logo.png" alt="Logo" width="110" height="110">
  </a>

  <h3 align="center">Sysmon Automation</h3>

  <p align="center">
    A PowerShell script which helps you in Sysmon Management!
    <br />
    <a href="https://github.com/KolimaH4x/Sysmon-Automation/README.md"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/KolimaH4x/Sysmon-Automation/issues">Report Bug</a>
    ·
    <a href="https://github.com/KolimaH4x/Sysmon-Automation/issues">Request Feature</a>
  </p>
</div>


![Sysmon](https://github.com/KolimaH4x/Sysmon-Automation/blob/main/media/sysmon.jpg)

![License](https://img.shields.io/badge/License-MIT-greeen)
![Version](https://img.shields.io/badge/Version-1.0.0-blue)

# Sysmon Automation
Automate management and maintenance of the Sysmon tool on your Windows systems with PowerShell. \
This script helps sysadmins and cyber secuirty analysts deploy and maintain the Sysmon monitoring tool from Sysinternals. \
Script distribution must be done via group policy, Sysmon binaries must be placed in a network share or in the sysvol volume of the domain controller.

### Features
* Install Sysmon if it is not installed.
* Upgrade Sysmon if the version does not match the updated version.
* Updates Sysmon configuration in case of changes
* Automatic control of system architecture (32/64 bit).
* Script activity logging and logrotate function.

## Links 🌐
* Sysmon: https://learn.microsoft.com/it-it/sysinternals/downloads/sysmon

* Sysmon Configuration: https://github.com/SwiftOnSecurity/sysmon-config
