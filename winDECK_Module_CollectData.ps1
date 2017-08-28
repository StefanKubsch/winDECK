# winDECK - Windows Digital Evidence Collection Kit
#
# winDECK_Module_CollectData.ps1
#
# Collect Data Module
#
# v0.8 Beta
#
# 21.08.2017
#
# (C) Stefan Kubsch
#

Set-StrictMode -Version "Latest"

$localScriptRoot = $PSScriptRoot

#region Include Functions Library
. "$localScriptRoot\Resources\Libs\General.ps1"
. "$localScriptRoot\Resources\Libs\CDM.ps1"
#endregion

#region Initialize environment
ShowSplashScreen ($CDMSplashScreen)
Header_InitializeEnvironment
CheckForPSVersion ($CDMMinPSVersion)
CheckForAdminRights
CheckForOSVersion(10)
CheckFreeSpace ($CDMOutputDrive)
CheckWriteAccess ($localScriptRoot)
CreateResultsFolder ($CDMResultsFolder)
StartLogging ($CDMResultsFolder)
#endregion

#region Data Collection
Write-Host ""
Write-Host -BackgroundColor Red "Running data collection..."
Write-Host ""

#region OS
CDM_CheckDomainJoin
CDM_GatherBasicOSInfo
#endregion

#region Networking
CDM_GatherIPConfig
CDM_GatherTCPConnections
CDM_GatherNetRoute
CDM_GatherDNSClientCache
CDM_GatherARPCache
CDM_GatherHostsFile
#endregion

#region Filesystem
CDM_GatheringModifiedFiles
CDM_GatherPrefetchFiles
#endregion

#region Processes
CDM_GatherStartupProcesses
CDM_GatherRunningProcesses
#endregion

#region Services
CDM_GatherServices
#endregion

#region Tasks
CDM_GatherScheduledTasks
#endregion

#region Security
CDM_GatherSIDS
CDM_GatherLocalAdministrators
CDM_GatherLogons
CDM_GatherFirewallStatus
CDM_GatherAntiVirusSolution
CDM_GatherMSAntimalwareStatus
CDM_GatherMSAntimalwareThreatHistory
CDM_GatherCredentialGuardStatus
CDM_GatherUEFISecureBootStatus
CDM_GatherUACStatus
CDM_GetBitlockerStatus
#endregion

#region Software
CDM_GatherInstalledApplications
#endregion

#region Updates
CDM_GatherInstalledUpdates
#endregion

#region EventLogs
CDM_ExportEventLogs
#endregion

#region GPO
CDM_GatherGPOResultingSet
#endregion

#region Hardware
#CDM_GatheringConnectedDevices
CDM_GatheringUSBFlashDriveHistory
#endregion

#region Browser
CDM_GatherIEHistory
CDM_GatherChromeHistory
CDM_GatherFirefoxHistory
#endregion

#endregion

#region Security tasks
Header_Security
StopLogging
Set-ItemProperty -Path $CDMResultsFolder\$Hostname"_Hashes.txt" -Name IsReadOnly -Value $True
#endregion

#region Exit winDECK
Header_PreparingExit
#endregion