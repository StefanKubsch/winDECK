# winDECK - Windows Digital Evidence Collection Kit
#
# winDECK_Functions.ps1
#
# Create USB stick Module Library
#
# v0.8 Beta
#
# 21.08.2017
#
# (C) Stefan Kubsch
#

Set-StrictMode -Version "Latest"
    
#region Declare and fill global constants and variables

$CUSMinPSVersion               = 5 # Minimum PowerShell version for Create USB stick Module
$CUSSplashScreen               = @("****************************************************************",
                                   "* winDECK - Windows Digital Evidence Collection Kit v0.8 Beta  *",
                                   "*                                                              *",
                                   "* Create USB Stick Module                                      *",
                                   "*                                                              *",
                                   "* (C) 2016,2017 Stefan Kubsch                                  *",
                                   "*                                                              *",
                                   "****************************************************************")
$global:ProgressPreference     = ’SilentlyContinue’ # Suppress progress bar
$global:AvailableSticks        = @()
$global:NeededStickSize        = 1

#endregion