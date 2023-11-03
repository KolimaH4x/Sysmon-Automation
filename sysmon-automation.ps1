<# PS ScriptInfo

.VERSION: 1.0.0

.AUTHOR: KolimaH4x

.DESCRIPTION
   This PowerShell script will install Sysmon if it is not installed, upgrade it if the version does not match the updated version
   or update the Sysmon configuration in case of changes. The script automatically download the Sysmon binaries directly from the official 
   Sysinternals URL and the configuration file from the SwiftOnSecurity template.
.FUNCTIONALITY
   Automate Sysmon Management
.NOTES
   1. The script must be executed with the highest privileges (e.g. NT Authority\System)
#>

# ----------- SYSMON CONFIGURATION FILE ----------- #

# Change the configuration file source as needed
$SysmonConfigURL = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml"

##############################################
#                                            #
#  DO NOT CHANGE VARIABLES BELOW THIS POINT  #
#                                            #
##############################################

# ----------- APPLICATION LOG ----------- #

# Create new Application log source if it does not exist

$Source = [System.Diagnostics.EventLog]::SourceExists("Sysmon Automation")
if ($Source -ne $true) {
    New-EventLog -LogName "Application" -Source "Sysmon Automation"
}

# ----------- SCRIPT ----------- #

Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50001 -EntryType Information -Message "Script startup."

# Create Sysmon Temp directory for downloads

$TempDir = [System.Environment]::GetEnvironmentVariable('TEMP','Machine')
$SysmonTempDir = "$TempDir\Sysmon"
if (!(Test-Path $SysmonTempDir)) {
    New-Item -ItemType Directory -Force -Path $SysmonTempDir
}

# Sysmon temp directory check

if (!(Test-Path -Path $SysmonTempDir)) {
    Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50020 -EntryType Error -Message "Temp Sysmon folder does not exist."
    exit
}

# Download and extracion Sysmon binaries and configuration file

# PowerShell uses TLS 1.0 when connecting to websites by default but the site you are making a request to requires TLS 1.1 or TLS 1.2 or SSLv3
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"

try {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" -OutFile "$SysmonTempDir\Sysmon.zip"
}
catch {
    Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50021 -EntryType Error -Message "https://download.sysinternals.com is unreachable."
    exit
}

try {
    Add-Type -Assembly System.IO.Compression.FileSystem
    $SysmonZipFile = [IO.Compression.ZipFile]::OpenRead("$SysmonTempDir\Sysmon.zip")
    $SysmonZipFile.Entries | Where-Object {($_.Name -eq "Sysmon.exe" -or $_.Name -eq "Sysmon64.exe")} | ForEach-Object {[System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$SysmonTempDir\$($_.Name)", $true)}
    $SysmonZipFile.Dispose()
    Remove-Item "$SysmonTempDir\Sysmon.zip" -Recurse -Force -ErrorAction SilentlyContinue
}
catch {
    Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50022 -EntryType Error -Message "Error encountered in Sysmon archive extraction."
    exit
}

try {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $SysmonConfigURL -OutFile "$SysmonTempDir\sysmonconfig-export.xml"
}
catch {
    Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50026 -EntryType Error -Message "https://raw.githubusercontent.com/SwiftOnSecurity is unreachable."
}

# Sysmon Services list
$SysmonServices = @("Sysmon","Sysmon64")

# Check Sysmon configuration file hash
$SysmonConfiguration = "$SysmonTempDir\sysmonconfig-export.xml"
$SysmonConfigFileHash = (Get-FileHash -algorithm SHA256 -Path ($SysmonConfiguration)).Hash

# Get OS Architecture (32-bit / 64-bit)
$Architecture = (Get-CimInstance Win32_operatingsystem).OSArchitecture

Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50002 -EntryType Information -Message "Host OS architecture: $Architecture."

# Check if Sysmon is installed
if ($Architecture -eq '64 bit' -or $Architecture -eq '64-bit') {
    $Service = get-Service -name Sysmon64 -ErrorAction SilentlyContinue
    $Exe = "$SysmonTempDir\Sysmon64.exe"
} else {
    $Service = get-Service -name Sysmon -ErrorAction SilentlyContinue
    $Exe = "$SysmonTempDir\Sysmon.exe"
}

# New Sysmon versions
$SysmonCurrentVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($Exe).FileVersion

Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50003 -EntryType Information -Message "Current Sysmon version: $SysmonCurrentVersion"

function Install-Sysmon {
    Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50004 -EntryType Information -Message "Installing Sysmon version: $SysmonCurrentVersion"
    # The command below installs Sysmon
    & $Exe "-accepteula" "-i" $SysmonConfiguration
    # Sysmon installation check
    $SysmonSrv = Get-Service | Where-Object {$_.DisplayName -in $SysmonServices} | Select-Object DisplayName, Status
    if ($null -ne $SysmonSrv) {
        $SysmonSrvName = $SysmonSrv.DisplayName
        $SysmonSrvStatus = $SysmonSrv.Status
        if ($SysmonSrv.Status -eq "Running") {
            Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50005 -EntryType Information -Message "Sysmon version $SysmonCurrentVersion installed. Current $SysmonSrvName service status: $SysmonSrvStatus"
        } else {
            Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50023 -EntryType Error -Message "Current $SysmonSrvName service status: $SysmonSrvStatus."
            exit
        }
    } else {
        Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50024 -EntryType Error -Message "Sysmon service not found."
        exit
    }
}

function Remove-Sysmon {
    Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50006 -EntryType Information -Message "Uninstalling Sysmon."
    # The command below uninstalls Sysmon
    & $Exe "-accepteula" "-u"
    # Sysmon uninstallation check
    $SysmonSrv = Get-Service | Where-Object {$_.DisplayName -in $SysmonServices} | Select-Object DisplayName, Status
    if ($null -eq $SysmonSrv) {
        Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50007 -EntryType Information -Message "Sysmon uninstalled correctly."
    } else {
        Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50025 -EntryType Error -Message "Sysmon uninstallation failed. A reboot may be required."
        exit
    }
}

function Update-SysmonConfig {
    Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50008 -EntryType Information -Message "New sysmon configuration found, updating."
    # The command below updates Sysmon's configuration
    & $Exe "-accepteula" "-c" $SysmonConfiguration
}

# Install Sysmon if it is not installed
if ($null -eq $Service) {
    Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50009 -EntryType Information -Message "Sysmon not found on host, installing."
    Install-Sysmon
} else {
    # If Sysmon is installed, get the installed version
    $SysmonPath = (Get-cimInstance -ClassName win32_Service -Filter 'Name like "%Sysmon%"').PathName
    $SysmonInstalledVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($SysmonPath).FileVersion
    Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50010 -EntryType Information -Message "Sysmon version $SysmonInstalledVersion installed on host."
    # If Sysmon is installed, check if the version needs upgraded
    if ($SysmonInstalledVersion -ne $SysmonCurrentVersion) {
        Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50040 -EntryType Warning -Message "Sysmon version installed is not up to date, reinstalling."
        Remove-Sysmon
        Install-Sysmon
    } else {
        Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50011 -EntryType Information -Message "Sysmon is updated to the latest version."
        # Check if Sysmon's configuration needs updated
        # Not necessary if Sysmon reinstalled due to version mismatch
        $InstalledSysmonConfigFileHash = (& $Exe "-c" | Select-String '(?!SHA256=)([a-fA-F0-9]{64})$').Matches.Value
        if ($InstalledSysmonConfigFileHash -ne $SysmonConfigFileHash){
            Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50041 -EntryType Warning -Message "Sysmon configuration is not up to date."
            Update-SysmonConfig
        } else {
            Write-EventLog -LogName "Application" -Source "Sysmon Automation" -EventId 50012 -EntryType Information -Message "Sysmon configuration is updated to the latest version."
        }
    }
}

Remove-Item $SysmonTempDir -Recurse -Force -ErrorAction SilentlyContinue
