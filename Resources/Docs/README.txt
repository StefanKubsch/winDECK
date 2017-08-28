winDECK - Windows Digital Evidence Collection Kit

(C) 2016,2017 Stefan Kubsch                            

¯\_(ツ)_/¯                                         


Quick Introduction
==================

winDECK is a set of tools made for data collection and analysis in case of a digital evidence.

Status is still pre-release (currently Beta) and under development.

The toolset contains different modules for easy use :

- Create USB stick Module
- Collect Data Module
- Analyse Data Module

Each module can be individually run.

System Requirement
==================

- Minimum Microsoft Windows 10
- Minimum PowerShell 5.0 (newer versions supported)

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
	
Security Features
=================

- Generates SHA256 checksums after data collection and proofs them when running Analyse Data Module
- Write-Protection of every generated file
