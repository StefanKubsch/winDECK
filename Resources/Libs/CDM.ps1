# winDECK - Windows Digital Evidence Collection Kit
#
# winDECK_Functions.ps1
#
# Collect Data Module Library
#
# v1.0
#
# 01.09.2017
#
# (C) Stefan Kubsch
#
# https://github.com/StefanKubsch/winDECK
#

Set-StrictMode -Version "Latest"
    
#region Declare and fill global constants and variables

$CDMMinPSVersion               = 5 # Minimum PowerShell version for Collect Data Module
$CDMResultsFolder              = $localScriptRoot+"\winDECK_Results_"+$Hostname
$CDMOutputDrive                = $localScriptRoot.Remove(1,$localScriptRoot.Length-1)
$CDMSplashScreen               = @("****************************************************************",
                                   "* winDECK - Windows Digital Evidence Collection Kit v1.0       *",
                                   "*                                                              *",
                                   "* Collect Data Module                                          *",
                                   "*                                                              *",
                                   "* (C) 2016,2017 Stefan Kubsch                                  *",
                                   "*                                                              *",
                                   "****************************************************************")
                              
#endregion

#region Functions

Function CDM_CheckDomainJoin
{
	Write-Host "Checking if computer is domain-joined..." -NoNewline
	#If ((Get-WmiObject Win32_Computersystem).PartOfDomain)
	If ((Get-CimInstance -ClassName Win32_Computersystem).PartOfDomain)
	{
		Out-File -Encoding $Encoding Flag_DomainJoin.txt
		SecureFile Flag_DomainJoin.txt
	}
	Write-Host "Done."
}

Function CDM_GatheringModifiedFiles
{
    Write-Host "Gathering modified files (during last 14 days)..." -NoNewline
    $Partitions = Get-Partition | Where-Object DriveLetter
	ForEach ($Partition in $Partitions)
	{
		$DriveLetter = $Partition.DriveLetter+":\"
		$FileName = "Filesystem_ModifiedFiles_" + $Partition.Driveletter + ".csv"
		Get-ChildItem -Recurse -Path $DriveLetter -ErrorAction SilentlyContinue | Where-Object LastWriteTime -gt (Get-Date).AddDays(-14) | Export-Csv -Encoding $Encoding $FileName
		SecureFile $FileName
	}
	Write-Host "Done."
}

Function CDM_GatherPrefetchFiles
{
    Write-Host "Gathering Windows Prefetch Data..." -NoNewline
    Get-ChildItem $Env:WINDIR\Prefetch | Select-Object Name,Fullname,Lastwritetime | Export-Csv -Encoding $Encoding Filesystem_PrefetchData.csv
	SecureFile Filesystem_PrefetchData.csv
    Write-Host "Done."
}

Function CDM_GatherIPConfig
{
    Write-Host "Gathering IP config..." -NoNewline
    Get-NetIPAddress | Export-Csv -Encoding $Encoding Network_IPConfig.csv
	SecureFile Network_IPConfig.csv
    Write-Host "Done."
}

Function CDM_GatherTCPConnections
{
    Write-Host "Gathering TCP connections..." -NoNewline
    Get-NetTCPConnection -State Established | Export-Csv -Encoding $Encoding Network_TCPConnections.csv
	SecureFile Network_TCPConnections.csv
    Write-Host "Done."
}

Function CDM_GatherNetRoute
{
    Write-Host "Gathering net routes..." -NoNewline
    Get-NetRoute | Export-Csv -Encoding $Encoding Network_NetRoute.csv
	SecureFile Network_NetRoute.csv
    Write-Host "Done."
}

Function CDM_GatherDNSClientCache
{ 
    Write-Host "Gathering DNS Client Cache..." -NoNewline
    Get-DnsClientCache | Export-Csv -Encoding $Encoding Network_DNSClientCache.csv
	SecureFile Network_DNSClientCache.csv
    Write-Host "Done."
}

Function CDM_GatherARPCache
{ 
    Write-Host "Gathering ARP Cache..." -NoNewline
    Get-NetNeighbor | Export-Csv -Encoding $Encoding Network_ARPCache.csv
	SecureFile Network_ARPCache.csv
	Write-Host "Done."
}

Function CDM_GatherHostsFile
{
    Write-Host "Gathering hosts file..." -NoNewline
    Copy-Item $Env:WINDIR\System32\drivers\etc\hosts $CDMResultsFolder\Network_Hosts.txt
	SecureFile Network_Hosts.txt
	Write-Host "Done."
}

Function CDM_GatherBasicOSInfo
{
    Write-Host "Gathering basic OS information..." -NoNewline
    Get-CimInstance Win32_OperatingSystem | Select-Object Caption,InstallDate,ServicePackMajorVersion,OSArchitecture,BootDevice, BuildNumber,CSName | Out-File -Encoding $Encoding OS_BasicInfo.txt
	SecureFile OS_BasicInfo.txt
    Write-Host "Done."
}

Function CDM_GatherStartupProcesses
{
    Write-Host "Gathering Startup processes..." -NoNewline
    Get-CimInstance Win32_Service -Filter "startmode = 'auto'" | Export-Csv -Encoding $Encoding Process_StartUp.csv
	SecureFile Process_StartUp.csv
    Write-Host "Done."
}

Function CDM_GatherRunningProcesses
{
    Write-Host "Gathering running processes..." -NoNewline
    Get-Process | Export-Csv -Encoding $Encoding Process_RunningProcesses.csv
	SecureFile Process_RunningProcesses.csv
    Write-Host "Done."
}

Function CDM_GatherServices
{
    Write-Host "Gathering all Services..." -NoNewline
    Get-Service | Export-Csv -Encoding $Encoding Services_AllServices.csv
	SecureFile Services_AllServices.csv
    Write-Host "Done."
}

Function CDM_GatherScheduledTasks
{
    Write-Host "Gathering scheduled tasks..." -NoNewline
    Get-ScheduledTask | Export-Csv -Encoding $Encoding Tasks_ScheduledTasks.csv
	SecureFile Tasks_ScheduledTasks.csv
    Write-Host "Done."
}

Function CDM_GatherFirewallStatus
{
    Write-Host "Gathering Firewall status..." -NoNewline
	
	$FWDomainPro = $False
	$FWPrivatePro = $False
	$FWPublicPro = $False

	Switch ($OSLanguage)
	{
		1031 
		{ 
			$Status = "Status"
			$StatusEnabled = "Ein"
		}
		1033 
		{ 
			$Status = "State"
			$StatusEnabled = "On" 
		}	
	}

	$FirewallStatus = netsh AdvFirewall Show DomainProfile | Select-String $Status
	If ($FirewallStatus -match $StatusEnabled)
	{
		$FWDomainPro = $True
	}

	$FirewallStatus = netsh AdvFirewall Show PrivateProfile | Select-String $Status
	If ($FirewallStatus -match $StatusEnabled)
	{
		$FWPrivatePro = $True
	}

	$FirewallStatus = netsh AdvFirewall Show PublicProfile | Select-String $Status
	If ($FirewallStatus -match $StatusEnabled)
	{
		$FWPublicPro = $True
	}

	"$FWDomainPro" + $OFS + "$FWPrivatePro" + $OFS + "$FWPublicPro" | Out-File -Encoding $Encoding Security_FirewallStatus.txt
	SecureFile Security_FirewallStatus.txt
	Write-Host "Done."
}

Function CDM_GatherAntiVirusSolution
{
    Write-Host "Gathering installed Antivirus solution..." -NoNewline
    Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct | Select-Object DisplayName,ProductState | Format-List | Out-File -Encoding $Encoding Security_AntiVirusSolution.txt
	SecureFile Security_AntiVirusSolution.txt
    Write-Host "Done."
}

Function CDM_GatherMSAntimalwareStatus
{
    Write-Host "Gathering Microsoft Antimalware status..." -NoNewline
    If (Get-MpComputerStatus) 
	{
		Get-MpComputerStatus | Out-File -Encoding $Encoding Security_MSAntimalwareStatus.txt
		SecureFile Security_MSAntimalwareStatus.txt
		Write-Host "Done."
	} Else
	{
		Write-Host "No Microsoft Antimalware solution found. Skipped."
	}
}

Function CDM_GatherMSAntimalwareThreatHistory
{
    Write-Host "Gathering Microsoft Antimalware threat history..." -NoNewline
    If (Get-MpThreat)
	{
		Get-MpThreat | Export-Csv -Encoding $Encoding Security_MSAntimalwareThreatHistory.csv
		SecureFile Security_MSAntimalwareThreatHistory.csv
		Write-Host "Done."
	} Else
	{
		Write-Host "No threat history found. Skipped."
	}
}

Function CDM_GatherLocalAdministrators
{
	Write-Host "Gathering members of local Administrators group..." -NoNewline
	Switch ($OSLanguage)
	{
		1031 
		{ 
			$AdminGroupName = "Administratoren" 
		}
		1033 
		{ 
			$AdminGroupName = "Administrators" 
		}
	}
	$ADSIComputer = [ADSI]("WinNT://$Hostname,computer")
	$ADSIGroup = $ADSIComputer.psbase.children.find($AdminGroupName,'Group') 
	$ADSIGroup.PSBase.Invoke("Members") | ForEach { $_.GetType.Invoke().InvokeMember("Name",'GetProperty',$null,$_,$null)} | Out-File -Encoding $Encoding Security_LocalAdministrators.txt
	SecureFile Security_LocalAdministrators.txt
	Write-Host "Done."
}

Function CDM_GatherSIDS
{
	Write-Host "Gathering Security Identifier (SIDs)..." -NoNewline
	$SID = @() 
	$Profiles = Get-ChildItem -Path Registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
	ForEach ($Key in $Profiles)
	{
		$Data = Get-Itemproperty -Path Registry::$Key
		$Record = New-Object PSObject -Property @{ 
			Name = ($Data.PSChildName)
			Path = ($Data.ProfileImagePath)
		}
        $SID += $Record 
	}
	$SID | Export-Csv -Encoding $Encoding Security_SecurityIdentifier.csv
	SecureFile Security_SecurityIdentifier.csv
	Write-Host "Done."
}

Function CDM_GatherLogons
{
	Write-Host "Gathering logon informations..." -NoNewline
	$UserProperty = @{n="User";e={(New-Object System.Security.Principal.SecurityIdentifier $_.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount])}}
	$TypeProperty = @{n="Action";e={if($_.EventID -eq 7001) {"Logon"} else {"Logoff"}}}
	$TimeProperty = @{n="Time";e={$_.TimeGenerated}}
	Get-EventLog System -Source Microsoft-Windows-Winlogon | Select-Object $UserProperty,$TypeProperty,$TimeProperty | Export-Csv -Encoding $Encoding Security_LogonInformation.csv
	SecureFile Security_LogonInformation.csv
	Write-Host "Done."
}

Function CDM_GatherUEFISecureBootStatus
{
    Write-Host "Gathering UEFI Secure Boot status..." -NoNewline
    Try
    {
        $SecureBootUEFIConfirm = Confirm-SecureBootUEFI 
    } Catch
    {
        Write-Host "UEFI Secure Boot not supported on this computer. Skipped."
        Return
    }
    $SecureBootUEFIConfirm = Confirm-SecureBootUEFI
    $SecureBootUEFISetupMode = Get-SecureBootUEFI -Name SetupMode
    $SecureBootUEFISecureBoot = Get-SecureBootUEFI -Name SecureBoot
    "$SecureBootUEFIConfirm" + $OFS + $SecureBootUEFISetupMode.Bytes + $OFS + $SecureBootUEFISecureBoot.Bytes | Out-File -Encoding $Encoding Security_UEFISecureBootStatus.txt
	SecureFile Security_UEFISecureBootStatus.txt
	Write-Host "Done."
}

Function CDM_GatherUACStatus
{
    Write-Host "Gathering UAC status..." -NoNewline
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
	(Get-ItemProperty -Path $RegPath -Name "ConsentPromptBehaviorAdmin").ConsentPromptBehaviorAdmin | Out-File -Encoding $Encoding Security_UACStatus.txt
	(Get-ItemProperty -Path $RegPath -Name "PromptOnSecureDesktop").PromptOnSecureDesktop | Out-File -Encoding $Encoding Security_UACStatus.txt -Append
	SecureFile Security_UACStatus.txt
	Write-Host "Done."
}

Function CDM_GatherCredentialGuardStatus
{
    Write-Host "Gathering Credential Guard status..." -NoNewline
    $DevGuard = Get-CimInstance –ClassName Win32_DeviceGuard –Namespace root\Microsoft\Windows\DeviceGuard
    If ($DevGuard.SecurityServicesConfigured -contains 1)
    {
		$CredGuardConfig = "Credential Guard is configured." 
    } Else
    {
        $CredGuardConfig = "Credential Guard is not configured."
    }
    If ($DevGuard.SecurityServicesRunning -contains 1)
    {
        $CredGuardRunning = "Credential Guard is running."
    } Else
    {
        $CredGuardRunning = "Credential Guard is not running."
    }
    "$CredGuardConfig" + $OFS + "$CredGuardRunning" | Out-File -Encoding $Encoding Security_CredentialGuardStatus.txt
	SecureFile Security_CredentialGuardStatus.txt
	Write-Host "Done."
}

Function CDM_GetBitlockerStatus
{
    Write-Host "Gathering Bitlocker status..." -NoNewline
    Get-BitLockerVolume | Export-Csv -Encoding $Encoding Security_BitlockerStatus.csv
	SecureFile Security_BitlockerStatus.csv
	Write-Host "Done."
}

Function CDM_ExportEventLogs
{      
    Write-Host "Exporting Eventlogs..." -NoNewline
	$Eventlogs = Get-ChildItem C:\WINDOWS\System32\winevt\Logs -Recurse
	ForEach ($Log in $Eventlogs)
    {
		$Temp = $Log.Name.Split(".")
		$LogName = $Temp[0] -Replace "%4","/"
		If ($Log.Length -gt 68kb)
		{
			$Cmd = "$($Env:WINDIR)\system32\wevtutil.exe epl '$LogName' '$CDMResultsFolder\Eventlog_$Log' /r:$Hostname /ow:True 2>&1"
		    $CmdResult = Invoke-Expression -Command $cmd
			SecureFile Eventlog_$Log
		}
    }
	Write-Host "Done."
}

Function CDM_GatherGPOResultingSet
{
    Write-Host "Gathering resulting Group Policy set..." -NoNewline
    If (Test-Path $CDMResultsFolder\Flag_DomainJoin.txt -PathType Leaf)
    {
        Write-Host "Computer is joined to a domain..." -NoNewline
        Get-GPResultantSetOfPolicy -ReportType html -Path $CDMResultsFolder\GPO_ResultingSet.html | Out-Null
		SecureFile GPO_ResultingSet.html
        Write-Host "Done."
    } Else
    {
        Write-Host "Computer is not joined to a domain. Skipped."
    }
}

Function CDM_GatherInstalledApplications
{
    Write-Host "Gathering installed applications..." -NoNewline
    Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Export-Csv -Encoding $Encoding Software_InstalledApplications.csv
	SecureFile Software_InstalledApplications.csv
    If ($OSFlag64bit)
    {
        Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Export-Csv -Encoding $Encoding Software_InstalledApplicationsWOW6432Node.csv
		SecureFile Software_InstalledApplicationsWOW6432Node.csv
    }
    Write-Host "Done."
}

Function CDM_GatherInstalledUpdates
{
    Write-Host "Gathering installed Updates..." -NoNewline
    $Session = New-Object -ComObject "Microsoft.Update.Session"
    $Searcher = $Session.CreateUpdateSearcher()
    $HistoryCount = $Searcher.GetTotalHistoryCount()
    $Searcher.QueryHistory(0, $HistoryCount) | Select-Object Title,Description,Date | Export-Csv -Encoding $Encoding Updates_InstalledUpdates.csv
	SecureFile Updates_InstalledUpdates.csv
    Write-Host "Done."
}

Function CDM_GatheringConnectedDevices
{
    Write-Host "Gathering connected PnP devices..." -NoNewline
    Get-PnpDevice -PresentOnly | Export-Csv -Encoding $Encoding Hardware_ConnectedPnpDevices.csv
	SecureFile Hardware_ConnectedPnpDevices.csv
    Write-Host "Done."
}

Function CDM_GatheringUSBFlashDriveHistory
{
    Write-Host "Gathering USB flash drive history..." -NoNewline
    Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR\*\* | Select-Object FriendlyName | Out-File -Encoding $Encoding Hardware_USBFlashDriveHistory.txt
	SecureFile Hardware_USBFlashDriveHistory.txt
    Write-Host "Done."
}

Function CDM_GatherIEHistory
{
	Write-Host "Gathering Internet Explorer history..." -NoNewline        
	$URLS = @()
	$Shell = New-Object -ComObject Shell.Application            
	$History = $Shell.NameSpace(34) #Special folder - IE history            
    $History.Items() | ForEach {            
		If ($_.IsFolder) 
		{            
			$SiteFolder = $_.GetFolder            
			$SiteFolder.Items() | ForEach {            
				$Site = $_            
				If ($Site.IsFolder)
				{            
					$PageFolder = $Site.GetFolder            
					$PageFolder.Items() | ForEach {            
						$Visit = New-Object -TypeName PSObject -Property @{            
							Site = $($Site.Name)            
							URL = $($PageFolder.GetDetailsOf($_,0))            
							Date = $($PageFolder.GetDetailsOf($_,2))            
						}   
						$URLS += $Visit 
					}            
				}            
			}            
		}            
	}
	$URLS | Export-Csv -Encoding $Encoding Browser_IEHistory.csv
	SecureFile Browser_IEHistory.csv
	Write-Host "Done."            
}

Function CDM_GatherChromeHistory
{
	Write-Host "Gathering Chrome history..." -NoNewline
	$History = $Env:USERPROFILE+"\AppData\Local\Google\Chrome\User Data\Default\History"
	If (Test-Path $History)
	{
		Copy-Item $History $CDMResultsFolder\Browser_ChromeHistory.sqlite
		SecureFile Browser_ChromeHistory.sqlite
		Write-Host "Done."
	} Else
	{
		Write-Host "No history file found. Skipped."
	}
}

Function CDM_GatherFirefoxHistory
{
	Write-Host "Gathering Firefox history..." -NoNewline
	$FFProfilePath = $Env:USERPROFILE+"\AppData\Roaming\Mozilla\Firefox\Profiles"
	If (Test-Path $FFProfilePath)
	{
		$DefaultProfile = Get-ChildItem -Name $FFProfilePath
		$History = $FFProfilePath+"\"+$DefaultProfile+"\places.sqlite"
		Copy-Item $History $CDMResultsFolder\Browser_FirefoxHistory.sqlite
		SecureFile Browser_FirefoxHistory.sqlite
		Write-Host "Done."
	} Else
	{
		Write-Host "No history file found. Skipped."
	}
}

#endregion