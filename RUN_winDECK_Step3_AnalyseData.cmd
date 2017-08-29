@ECHO OFF
REM Runs script with elevated rights

SET ScriptDir=%~dp0
SET PSScriptPath=%ScriptDir%winDECK_Module_AnalyseData.ps1
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%PSScriptPath%""' -Verb RunAs}";