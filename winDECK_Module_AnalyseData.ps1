# winDECK - Windows Digital Evidence Collection Kit
#
# winDECK_Module_CollectData.ps1
#
# Analyse Data Module
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
. "$localScriptRoot\Resources\Libs\ADM.ps1"
#endregion

#region Initialize environment
ShowSplashScreen ($ADMSplashScreen)
Header_InitializeEnvironment
CheckForPSVersion ($ADMMinPSVersion)
CheckForAdminRights
CheckForOSVersion(10)
CheckForExistingResultsFolders
#endregion

#region Security tasks
Header_Security
#CheckSHA256Hashes
#CheckReadOnly
#endregion

#region Analyse Data
Write-Host ""
Write-Host -BackgroundColor Red "Starting Analyse Data GUI..."
Write-Host ""
ADM_Main
#endregion