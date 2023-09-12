<# PS ScriptInfo

.VERSION: 1.0

.AUTHOR: KolimaH4x

.DESCRIPTION
   This PowerShell script will install Sysmon if it is not installed, upgrade it if the version does not match the updated version or update the Sysmon configuration in case of changes.
.FUNCTIONALITY
   Automate Sysmon Management
.NOTES
   1. The script requires a shared folder or in the sysvol volume of the domain controller in which the updated Sysmon binaries will be placed. Make sure sysmon.exe and sysmon64.exe are placed directly into the folder.
   2. The configuration file must be placed in the same folder
   3. The script must be executed with the highest privileges (e.g. NT Authority\System)
#>

# ----------- VARIABLES ----------- #

# Change the path according to your environment
$shared_sysmon_folder = '\\PATH\Symon'
# Below is a local path that this script can log and track sysmon
$local_sysmon_folder = 'C:\Windows\Sysmon'
$max_log_file_size = 10 # This is in KB



##############################################
#                                            #
#  DO NOT CHANGE VARIABLES BELOW THIS POINT  #
#                                            #
##############################################

# Create local path if it does not exist
if (!(Test-Path -Path $local_sysmon_folder)){
    New-Item -ItemType Directory -Force -Path $local_sysmon_folder
}

# ----------- LOG FUNCTION ----------- #

$log_file = $local_sysmon_folder + "\" + "Sysmon_Manager.log"
$log_file_backup = $local_sysmon_folder + "\" + "Sysmon_Manager.old"

function Write-Log {
    [CmdletBinding()]
    param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Message,
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('Information','Warning','Error')]
    [string]$Severity = 'Information')
    [pscustomobject]@{
    Time = (Get-Date -Format "dd/MM/yyyy HH:mm:ss")
    Message = $Message
    Severity = $Severity
    } | Out-File -FilePath $log_file -Append
   } 

# Create log file if it does not exist and Logrotate
if (!(Test-Path -Path $log_file)){
    New-Item -ItemType File -Path $local_sysmon_folder -Name Sysmon_Manager.log
    Write-Log -Message "Script startup." -Severity Information
   } else {
    Write-Log -Message "Script startup." -Severity Information
    Write-Log "Prior log file found" -Severity Information
    $log_size = (Get-Item $log_file).length/1KB
    # If log size is greater than or equal to $max_log_file_size, rotate the file
    if($log_size -ge $max_log_file_size){
        Write-Log "Rotating log file" -Severity Information
        if (Test-Path -Path $log_file_backup){
            Remove-Item -Path $log_file_backup -Force
            Rename-Item -Path $log_file $log_file_backup
        } else {
            Rename-Item -Path $log_file $log_file_backup
           }   
        }
    }

# ----------- SCRIPT ----------- #

if (!(Test-Path -Path $shared_sysmon_folder)) {
    Write-Log "Shared Sysmon folder does not exist or is not reachable." -Severity Error
    exit
}

# Check Sysmon configuration file hash
$sysmon_configuration = $shared_sysmon_folder + "\" + "sysmonconfig-export.xml"
$sysmon_configuration_file_hash = (Get-FileHash -algorithm SHA256 -Path ($sysmon_configuration)).Hash

# Get OS architecture (32-bit / 64-bit)
$architecture = (Get-CimInstance Win32_operatingsystem).OSArchitecture

# Check if Sysmon is installed
if ($architecture -eq '64 bit') {
    $service = get-service -name Sysmon64 -ErrorAction SilentlyContinue
    $exe = $shared_sysmon_folder + "\" + "Sysmon64.exe"
} else {
    $service = get-service -name Sysmon -ErrorAction SilentlyContinue
    $exe = $shared_sysmon_folder + "\" + "Sysmon.exe"
}

# New Sysmon versions
$sysmon_current_version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($exe).FileVersion

function Install-Sysmon {
    # The command below installs Sysmon
    & $exe "-accepteula" "-i" $sysmon_configuration
}

function Remove-Sysmon {
    # The command below uninstalls Sysmon
    & $exe "-accepteula" "-u"
}

function Update-SysmonConfig {
    # The command below updates Sysmon's configuration
    & $exe "-accepteula" "-c" $sysmon_configuration
}

# Install Sysmon if it is not installed
if ($null -eq $service) {
    Install-Sysmon
    Write-Log "Installing Sysmon." -Severity Information
} else {
    Write-Log "Sysmon is installed." -Severity Information
    # If Sysmon is installed, get the installed version
    $sysmon_path = (Get-cimInstance -ClassName win32_service -Filter 'Name like "%Sysmon%"').PathName
    $sysmon_installed_version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($sysmon_path).FileVersion
}

# If Sysmon is installed, check if the version needs upgraded
if ($Sysmon_installed_version -ne $sysmon_current_version) {
    Remove-Sysmon
    Install-Sysmon
    Write-Log "Sysmon version does not match - Reinstalling." -Severity Warning
} else {
    Write-Log "Sysmon version matches shared repository version." -Severity Information
    # Check if Sysmon's configuration needs updated
    # Not necessary if Sysmon reinstalled due to version mismatch
    $installed_sysmon_configuration_file_hash = (& $exe "-c" | Select-String '(?!SHA256=)([a-fA-F0-9]{64})$').Matches.Value
    if ($installed_sysmon_configuration_file_hash -ne $sysmon_configuration_file_hash){
        Update-SysmonConfig
        Write-Log "Sysmon configuration out of sync - Updating." -Severity Warning
    } else {
        Write-Log "Sysmon configuration matches current configuration." -Severity Information
    }
}
