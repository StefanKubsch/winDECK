@ECHO OFF
SET ScriptDir=%~dp0
SET PSScriptPath=%ScriptDir%winDECK_Module_CreateUSBStick.ps1
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%PSScriptPath%""' -Verb RunAs}";