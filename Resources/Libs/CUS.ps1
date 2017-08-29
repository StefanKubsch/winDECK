# winDECK - Windows Digital Evidence Collection Kit
#
# winDECK_Functions.ps1
#
# Create USB stick Module Library
#
# v1.0
#
# 29.08.2017
#
# (C) Stefan Kubsch
#
# https://github.com/StefanKubsch/winDECK
#

Set-StrictMode -Version "Latest"
    
#region Declare and fill global constants and variables

$CUSMinPSVersion               = 5 # Minimum PowerShell version for Create USB stick Module
$CUSSplashScreen               = @("****************************************************************",
                                   "* winDECK - Windows Digital Evidence Collection Kit v1.0       *",
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