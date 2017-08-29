winDECK - Windows Digital Evidence Collection Kit

(C) 2016,2017 Stefan Kubsch                            

¯\_(ツ)_/¯                                         


Quick Introduction
==================

winDECK is a set of tools made for data collection and analysis in case of a digital evidence.

Status is still under development, but fully functional.

The toolset contains different modules for easy use :

- Create USB stick Module
- Collect Data Module
- Analyse Data Module

Installation
============

Installation is not needed. Just copy all files from the GitHub-Repository to a folder of your choice and you´re ready to go.

How to use
==========

Each module can be individually run.

If you want to use winDECK on a differnet PC than yours, use the "Create USB Stick" module to prepare an USB stick properly. It will be cleared, needed files are copied and write-protected.
Then use the stick in a Windows 10 PC of your choice. Just run the "Collect Data" module and wait.

Final step to analyse the collected data: Copy the result folder from stick to you winDECK folder and run the "Analyse Data" module.

Please use the corresponding CMD-Batchfiles to start the modules. They´ll provide you with an elevated token for administrative rights, so you don´t have to hassle with 
Powershell-Console etc.

The tools are pretty self-explanatory, you´ll be guided and informed over each step taken. Possible errors are - hopefully - recognized and handled.

The "Analyse Data" module features a graphical (Windows Forms) GUI for easy use and a clear visualization of the gathered data.

System Requirements
===================

- Minimum Microsoft Windows 10
- Minimum PowerShell 5.0 (newer versions supported)

Security Features
=================

To ensure collected data is not tampered/changed I implemented these features:

- Generates SHA256 checksums for each file during data collection and proofs them when running "Analyse Data" module
- Write-Protection of every generated file

Once the result-files are written during data collection, every change in them is recognized and will lead to a full stop of the "Analyse Data" module, plus you´ll be informed
which file lead to the stop.

What kind of informations are collected ?
=========================================

- Operating System
	- basic OS information

- Networking
	- IP config
	- TCP connections
	- net route
	- DNS client cache
	- ARP cache
	- Hosts file

- Filesytem
	- modified files (14 days)
	- Windows Prefetch Data

- Processes
	- running processes
	- Startup processes

- Services
	- all Services
	
- Tasks
	- scheduled tasks

- Security
	- members of local Administrators group
	- Security Identifiers (SIDs)
	- Logon informations
	- Firewall status
	- installed Antivirus solution
	- Microsoft Antimalware status 
	- Microsoft Antimalware threat history
	- UEFI Secure Boot status
	- Credential Guard status
	- UAC status
	- Bitlocker status

- Software
	- installed applications

- Updates
	- installed Microsoft Updates

- Eventlogs
	- all existing eventlogs

- Hardware
	- connected PnP devices
	- USB Flash Drive history
	
- Browser
	- Internet Explorer history
	- Google Chrome history
	- Mozilla Firefox history
	

