# winDECK - Windows Digital Evidence Collection Kit
#
# winDECK_Functions.ps1
#
# Analyse Data Module Library
#
# v0.8 Beta
#
# 21.08.2017
#
# (C) Stefan Kubsch
#

Set-StrictMode -Version "Latest"
    
#region Declare and fill global constants and variables

# Include Assemblies

[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

# Define GUI elements and prefill them with content

$ProgressPreference     = ’SilentlyContinue’ # Suppress progress bar
$winDECKIcon            = New-Object System.Drawing.Icon ("$localScriptRoot\Resources\Gfx\winDECKIcon.ico")
$OkIcon                 = [System.Drawing.Image]::Fromfile("$localScriptRoot\Resources\Gfx\Ok.png")
$FailedIcon             = [System.Drawing.Image]::Fromfile("$localScriptRoot\Resources\Gfx\Failed.png")
$InfoIcon               = [System.Drawing.Image]::Fromfile("$localScriptRoot\Resources\Gfx\Info.png")
$ADMMinPSVersion        = 5 # Minimum PowerShell version for Analyse Data Module
$GeneralX               = 10
$GeneralY               = 40
$SecurityX              = 10
$SecurityY              = 190
$AnalyticsX             = 10
$AnalyticsY             = 340
$MainWindowWidth        = 1152
$MainWindowHeight       = 768
$AboutWindowWidth       = 400
$AboutWindowHeight      = 300
$NoDataWindowWidth      = 320
$NoDataWindowHeight     = 200
$UpdateBLWindowWidth    = 450
$UpdateBLWindowHeight   = 200
$ProgressWindowWidth    = 450
$ProgressWindowHeight   = 200
$ADMSplashScreen        = @("****************************************************************",
                            "* winDECK - Windows Digital Evidence Collection Kit v0.8 Beta  *",
                            "*                                                              *",
                            "* Analyse Data Module                                          *",
                            "*                                                              *",
                            "* (C) 2016,2017 Stefan Kubsch                                  *",
                            "*                                                              *",
                            "****************************************************************")
$AboutTextContent       = @(" ",
						    " ",
							"winDECK - Windows Digital Evidence Collection Kit",
							" ",
							"                                    v0.8 Beta",
	                        " ",
							"         (C)opyright 2016, 2017 by Stefan Kubsch",
							" ",
							" ",
							"                                     ¯\_(シ)_/¯")
$NoDataTextContent      = "No data was found..."

#endregion

#region Functions

Function ADM_UpdateBlacklists
{
	$UpdateBLText.Clear()
	$UpdateBLText.AppendText("Updating Blacklists..." + $OFS + $OFS)
	$UpdateBLWindow.Visible = $True
	
	$BlacklistFiles = Get-Content $localScriptRoot\Resources\LookupTables\Blacklists.txt

	Remove-Item $localScriptRoot\Resources\Blacklists\*.* -Force

	ForEach ($List in $BlacklistFiles)
	{
		$ListName = $List.Split("*")
		$URL = $ListName[0]
		$Description = $ListName[2]
		
		$UpdateBLText.AppendText("Downloading $Description...")
		$UpdateBLText.Update()

		$OutputFile = "$localScriptRoot\Resources\Blacklists"
		Start-BitsTransfer -Source $URL -Destination $OutputFile
	
		$UpdateBLText.AppendText("Done." + $OFS)
	}
		
	$UpdateBLWindow.Controls.Add($UpdateBLCloseButton)
}

Function ADM_GenerateLabel
{
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		$Name,
	    
		[Parameter(Mandatory=$True, Position=2)]
		[int]$RelPosX,

		[Parameter(Mandatory=$True, Position=3)]
		[int]$RelPosY,
		
		[Parameter(Mandatory=$True, Position=4)]
		[string]$Context
	)

	Switch ($Context)
	{
		"General" 
		{ 
			$PosX = $GeneralX + $RelPosX
			$PosY = $GeneralY + $RelPosY
		}
		"Security" 
		{ 
			$PosX = $SecurityX + $RelPosX
			$PosY = $SecurityY + $RelPosY 
		}
	}

	$Name.Font = New-Object System.Drawing.Font("Lucida Console",8)
    $Name.Location = New-Object System.Drawing.Size($PosX,$PosY)
    $Name.AutoSize = $True
    $Name.Anchor = 'Top,Left'
	$MainWindow.Controls.Add($Name)
}

Function ADM_GenerateIcon
{
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		$Name,
	    
		[Parameter(Mandatory=$True, Position=2)]
		[string]$State,

		[Parameter(Mandatory=$True, Position=3)]
		[int]$RelPosX,

		[Parameter(Mandatory=$True, Position=4)]
		[int]$RelPosY,

		[Parameter(Mandatory=$True, Position=5)]
		[string]$Context
	)

    Switch ($Context)
	{
		"General" 
		{	
			$PosX = $GeneralX + $RelPosX
			$PosY = $GeneralY + $RelPosY 
		}
		"Security" 
		{ 
			$PosX = $SecurityX + $RelPosX
			$PosY = $SecurityY + $RelPosY 
		}
	}

	Switch ($State)
	{
		"Ok" 
		{ 
			$Icon = $OkIcon 
		}
		"Failed" 
		{ 
			$Icon = $FailedIcon 
		}
		"Info" 
		{ 
			$Icon = $InfoIcon 
		}
	}

	$Name.Width = 16
	$Name.Height = 16
	$Name.Image = $Icon
	$Name.Location = New-Object Drawing.Point $PosX,$PosY
	$MainWindow.Controls.Add($Name)
}

Function ADM_NoDataWindow
{
	$NoDataWindow = New-Object System.Windows.Forms.Form
    $NoDataWindow.Size = New-Object System.Drawing.Size($NoDataWindowWidth,$NoDataWindowHeight)
	$NoDataWindow.FormBorderStyle = "FixedDialog"
	$NoDataWindow.ControlBox = $False
    $NoDataWindow.Text = "winDECK worked hard but..."
    $NoDataWindow.WindowState ="Normal"
    $NoDataWindow.StartPosition = "CenterScreen"

    $NoDataCloseButton = New-Object System.Windows.Forms.Button
    $NoDataCloseButton.Location = New-Object System.Drawing.Size((($NoDataWindowWidth/2) - 44),($NoDataWindowHeight - 78))
    $NoDataCloseButton.Size = New-Object System.Drawing.Size(75,23)
	$NoDataCloseButton.FlatStyle = "Flat"
    $NoDataCloseButton.Text = "Close"
    $NoDataCloseButton.Add_Click({$NoDataWindow.Close()})
	
	$NoDataText = New-Object System.Windows.Forms.RichTextBox
    $NoDataText.Font = New-Object System.Drawing.Font("MS Sans Serif",10)
	$NoDataText.Location = New-Object System.Drawing.Size(10,10)
    $NoDataText.Size = New-Object System.Drawing.Size(($NoDataWindowWidth-40),($NoDataWindowHeight-150))
	$NoDataText.Borderstyle = "None"
	$NoDataText.Enabled = $False
    $NoDataText.ReadOnly = $True
	$NoDataText.AppendText($NoDataTextContent)
	
	$NoDataWindow.Controls.Add($NoDataText)
	$NoDataWindow.Controls.Add($NoDataCloseButton)
	$NoDataWindow.ShowDialog()
}

Function ADM_AboutWindow
{
    $AboutWindow = New-Object System.Windows.Forms.Form
    $AboutWindow.Size = New-Object System.Drawing.Size($AboutWindowWidth,$AboutWindowHeight)
	$AboutWindow.FormBorderStyle = "FixedDialog"
	$AboutWindow.ControlBox = $False
    $AboutWindow.Text = "About winDECK"
    $AboutWindow.WindowState ="Normal"
    $AboutWindow.StartPosition = "CenterScreen"

    $AboutCloseButton = New-Object System.Windows.Forms.Button
    $AboutCloseButton.Location = New-Object System.Drawing.Size(($AboutWindowWidth/2 - 44),($AboutWindowHeight - 78))
    $AboutCloseButton.Size = New-Object System.Drawing.Size(75,23)
	$AboutCloseButton.FlatStyle = "Flat"
    $AboutCloseButton.Text = "Close"
    $AboutCloseButton.Add_Click({$AboutWindow.Close()})

	$AboutText = New-Object System.Windows.Forms.RichTextBox
    $AboutText.Font = New-Object System.Drawing.Font("MS Sans Serif",10,[System.Drawing.FontStyle]::Bold)
	$AboutText.Location = New-Object System.Drawing.Size(10,10)
    $AboutText.Size = New-Object System.Drawing.Size(365,194)
	$AboutText.Borderstyle = "None"
	$AboutText.Enabled = $False
    $AboutText.ReadOnly = $True

	ForEach ($Line in $AboutTextContent)
    {
        $AboutText.AppendText($Line+$OFS)
    }
    $AboutText.Update()
	$AboutWindow.Controls.Add($AboutText)
	$AboutWindow.Controls.Add($AboutCloseButton)
	$AboutWindow.ShowDialog()
}

Function ADM_SummaryHostname
{
	$HostNameLabel = New-Object System.Windows.Forms.Label
	ADM_GenerateLabel $HostNameLabel 0 20 General
	
	$File = Get-Content -Encoding $Encoding $SelectedFolder\OS_BasicInfo.txt
	ForEach ($Line in $File)
	{
		If ($Line -match "CSName")
		{
			$Hostname = $Line.Split(":")
			$Hostname = $Hostname[1].TrimStart()
		}
	}
	
    $HostNameLabel.Text = "Hostname    : $Hostname"
}

Function ADM_SummaryOS
{
	$OSLabel = New-Object System.Windows.Forms.Label
    ADM_GenerateLabel $OSLabel 0 40 General

	$File = Get-Content -Encoding $Encoding $SelectedFolder\OS_BasicInfo.txt
	ForEach ($Line in $File)
	{
		If ($Line -match "Caption")
		{
			$OSName = $Line.Split(":")
			$OSName = $OSName[1].TrimStart()
		}
		If ($Line -match "OSArchitecture")
		{
			$OSBit = $Line.Split(":")
			$OSBit = $OSBit[1].TrimStart()
		}
		If ($Line -match "BuildNumber")
		{
			$OSBuild = $Line.Split(":")
			$OSBuild = $OSBuild[1].TrimStart()
		}
	}
    
	$OSLabel.Text = "OS          : $OSName, Build $OSBuild ($OSBit)"
}

Function ADM_SummaryScanDate
{
	Switch ($OSLanguage)
	{
		1031 
		{ 
			$TimeString = "Startzeit:" 
		}
		1033 
		{ 
			$TimeString = "Start time:" 
		}	
	}

   	$TimeDateLabel = New-Object System.Windows.Forms.Label
	ADM_GenerateLabel $TimeDateLabel 0 60 General
	
	$TimeTemplate = 'yyyyMMddHHmmss'
	$File = Get-Content -Encoding $Encoding $SelectedFolder\winDECK_Log.txt
	ForEach ($Line in $File)
	{
		If ($Line -match $TimeString)
		{
			$TimeDate = $Line.Split(":")
			$TimeDate = $TimeDate[1].TrimStart()
		}
	}
	
	$TimeDate = [DateTime]::ParseExact($TimeDate,$TimeTemplate,$Null)
    $TimeDateLabel.Text = "Scan run on : $TimeDate"
}

Function ADM_SummaryScanUser
{
	$ScanUserLabel = New-Object System.Windows.Forms.Label
	ADM_GenerateLabel $ScanUserLabel 0 80 General
		
	$File = Get-Content -Encoding $Encoding $SelectedFolder\winDECK_Log.txt
	ForEach ($Line in $File)
	{
		If (($Line -match "RunAs-Benutzer") -or ($Line -match "RunAs User") -or ($Line -match "Als Benutzer"))
		{
			$ScanUser = $Line.Split(":")
			$ScanUser = $ScanUser[1].TrimStart()
		}
	}

    $ScanUserLabel.Text = "Scan run by : $ScanUser"
}

Function ADM_SummaryLoggedUser
{
	Switch ($OSLanguage)
	{
		1031 
		{ 
			$UserString = "Benutzername:" 
		}
		1033 
		{ 
			$UserString = "Username:" 
		}	
	}
	
	$LoggedUserLabel = New-Object System.Windows.Forms.Label
	ADM_GenerateLabel $LoggedUserLabel 0 100 General
		
	$File = Get-Content -Encoding $Encoding $SelectedFolder\winDECK_Log.txt
	ForEach ($Line in $File)
	{
		If ($Line -match $UserString)
		{
			$LoggedUser = $Line.Split(":")
			$LoggedUser = $LoggedUser[1].TrimStart()
		}
	}
    
	$LoggedUserLabel.Text = "Login user  : $LoggedUser"
}

Function ADM_SummaryCredentialGuard
{
	$CredentialGuardStatus = "Credential Guard is not configured."

	$CredentialGuardIcon = New-Object Windows.Forms.PictureBox
	ADM_GenerateIcon $CredentialGuardIcon Info 0 20 Security

	$CredentialGuardLabel = New-Object System.Windows.Forms.Label
   	ADM_GenerateLabel $CredentialGuardLabel 20 23 Security

	If (Test-Path $SelectedFolder\Security_CredentialGuardStatus.txt -PathType Leaf)
	{
		$File = Get-Content -Encoding $Encoding $SelectedFolder\Security_CredentialGuardStatus.txt
		If ($File[0] -eq "Credential Guard is configured.")
		{
			$CredentialGuardIcon.Image = $FailedIcon
			$CredentialGuardStatus = "Credential Guard is configured but not running."
		}
		If ($File[1] -eq "Credential Guard is running.")
		{
			$CredentialGuardIcon.Image = $OkIcon
			$CredentialGuardStatus = "Credential Guard is configured and running."
		}
	} Else
	{
		$CredentialGuardStatus = "Credential Guard is not available on Windows 8/8.1."
	}

	$CredentialGuardLabel.Text = $CredentialGuardStatus
} 

Function ADM_SummaryUAC
{
	$UACStatusIcon = New-Object Windows.Forms.PictureBox
	ADM_GenerateIcon $UACStatusIcon Info 450 20 Security

	$UACStatusLabel = New-Object System.Windows.Forms.Label
   	ADM_GenerateLabel $UACStatusLabel 470 23 Security

	$File = Get-Content -Encoding $Encoding $SelectedFolder\Security_UACStatus.txt
	$ConsentPromptBehaviorAdmin = $File[0]
	$PromptOnSecureDesktop = $File[1]

	$UACStatus = "UAC status is ConsentPromptBehaviorAdmin $ConsentPromptBehaviorAdmin, PromptOnSecureDesktop $PromptOnSecureDesktop."
	
	If (($ConsentPromptBehaviorAdmin -eq 0) -and ($PromptOnSecureDesktop -eq 0))
    { 
        $UACStatusIcon.Image = $FailedIcon
		$UACStatus = "UAC status is 'Never notify'."
    } ElseIf (($ConsentPromptBehaviorAdmin -eq 5) -and ($PromptOnSecureDesktop -eq 0))
    { 
        $UACStatusIcon.Image = $OkIcon
		$UACStatus = "UAC status is 'Notify me only when apps try to make changes to my computer (do not dim my desktop)'."
    } 
	ElseIf (($ConsentPromptBehaviorAdmin -eq 5) -and ($PromptOnSecureDesktop -eq 1))
    { 
        $UACStatusIcon.Image = $OkIcon
		$UACStatus = "UAC status is 'Notify me only when apps try to make changes to my computer (default)'."
    } ElseIf (($ConsentPromptBehaviorAdmin -eq 2) -and ($PromptOnSecureDesktop -eq 1))
    { 
        $UACStatusIcon.Image = $OkIcon
		$UACStatus = "UAC status is 'Always notify'."
    }
   
	$UACStatusLabel.Text = $UACStatus
}

Function ADM_SummaryUEFISecureBoot
{
	$UEFIStatus = "UEFI Secure Boot is not supported/enabled."
	
	$UEFIStatusIcon = New-Object Windows.Forms.PictureBox
	ADM_GenerateIcon $UEFIStatusIcon Info 450 40 Security

	$UEFIStatusLabel = New-Object System.Windows.Forms.Label
   	ADM_GenerateLabel $UEFIStatusLabel 470 43 Security

	If (Test-Path $SelectedFolder\Security_UEFISecureBootStatus.txt -PathType Leaf)
	{
		$File = Get-Content -Encoding $Encoding $SelectedFolder\Security_UEFISecureBootStatus.txt
		$UEFIConfirm = $File[0]
		$UEFISetupMode = $File[1]
		$UEFISecureBoot = $File[2]

		If (($UEFIConfirm -eq $True) -and ($UEFISetupMode -eq 0) -and ($UEFISecureBoot -eq 1))
        {
            $UEFIStatus = "UEFI native Secure Boot is enabled."
			$UEFIStatusIcon.Image = $OkIcon
        }
        If (($UEFIConfirm -eq $False) -and ($UEFISetupMode -eq 1) -and ($UEFISecureBoot -eq 0))
        {
            $UEFIStatus = "UEFI with CSM is enabled."
        }
	}

	$UEFIStatusLabel.Text = $UEFIStatus
}

Function ADM_SummaryEMET
{
	$EMETStatus = "EMET is not installed."
	$EMETAgent = $False
	$EMETService = $False
	
	$EMETStatusIcon = New-Object Windows.Forms.PictureBox
	ADM_GenerateIcon $EMETStatusIcon Info 0 80 Security

	$EMETStatusLabel = New-Object System.Windows.Forms.Label
   	ADM_GenerateLabel $EMETStatusLabel 20 83 Security

	If ($OSFlag64bit)
	{
		$CSVFileInstalledApps = Import-Csv -Encoding $Encoding $SelectedFolder\Software_InstalledApplicationsWOW6432Node.csv
	} Else
	{
		$CSVFileInstalledApps = Import-Csv -Encoding $Encoding $SelectedFolder\Software_InstalledApplications.csv
	}

	If ($CSVFileInstalledApps -match "EMET")
	{
		$EMETStatus = "EMET is installed but not running."
		$EMETStatusIcon.Image = $FailedIcon
		$CSVFileProcesses = Import-Csv -Encoding $Encoding $SelectedFolder\Process_RunningProcesses.csv
		If ($CSVFileProcesses -match "EMET_Agent") 
		{ 
			$EMETAgent = $True 
			$EMETVersion = $CSVFileProcesses | Where-Object -Property Name -eq "EMET_Agent"
		}
		If ($CSVFileProcesses -match "EMET_Service") 
		{ 
			$EMETService = $True 
		}
		If (($EMETAgent) -and ($EMETService))
		{
			$EMETStatus = "EMET "+$EMETVersion.ProductVersion+" is installed and running."
			$EMETStatusIcon.Image = $OkIcon
		}
	}
	
	$EMETStatusLabel.Text = $EMETStatus
}

Function ADM_SummaryBitlocker
{
	$BitlockerStatus = ""

	$BitlockerStatusIcon = New-Object Windows.Forms.PictureBox
	ADM_GenerateIcon $BitlockerStatusIcon Info 450 80 Security

	$BitlockerStatusLabel = New-Object System.Windows.Forms.Label
   	ADM_GenerateLabel $BitlockerStatusLabel 470 83 Security

	$CSVBitlocker = Import-Csv -Encoding $Encoding $SelectedFolder\Security_BitlockerStatus.csv
	ForEach	($Line in $CSVBitlocker)
	{
		$BLMountPoint = $Line.MountPoint
		$BLProtection = $Line.ProtectionStatus.ToUpper()
		$BitlockerStatus += "'$BLMountPoint $BLProtection' "
	}
	
	$BitlockerStatus = $BitlockerStatus.TrimEnd()
	$BitlockerStatusLabel.Text = "Bitlocker Protection status is $BitlockerStatus."
}

Function ADM_SummaryAntivirusSolution
{
	$AntiVirSol = "not found"
	$ProductStateText = "unknown."
	
	$AntiVirSolIcon = New-Object Windows.Forms.PictureBox
	ADM_GenerateIcon $AntiVirSolIcon Failed 0 60 Security

	$AntiVirSolLabel = New-Object System.Windows.Forms.Label
   	ADM_GenerateLabel $AntiVirSolLabel 20 63 Security

	$AntiVirStateIcon = New-Object Windows.Forms.PictureBox
	ADM_GenerateIcon $AntiVirStateIcon Failed 450 60 Security

	$AntiVirStateLabel = New-Object System.Windows.Forms.Label
   	ADM_GenerateLabel $AntiVirStateLabel 470 63 Security

	$File = Get-Content -Encoding $Encoding $SelectedFolder\Security_AntiVirusSolution.txt
	ForEach ($Line in $File)
	{
		If ($Line -match "DisplayName")
		{
			$AntiVirSol = $Line.Split(":")
			$AntiVirSol = $AntiVirSol[1].TrimStart()
			$AntiVirSolIcon.Image = $OkIcon
		}
		If ($Line -match "ProductState")
		{
			$ProductState = $Line.Split(":")
			$ProductState = '{0:x6}' -f [int]$ProductState[1].TrimStart()
		}
	}

	If (($ProductState.Substring(2,2) -eq "10") -or ($ProductState.Substring(2,2) -eq "11"))
	{
		$ProductStateText = "enabled"
		$AntivirEnabled = $True
	} ElseIf (($ProductState.Substring(2,2) -eq "00") -or ($ProductState.Substring(2,2) -eq "01"))
	{
		$ProductStateText = "disabled"
		$AntivirEnabled = $False
	}

	If ($ProductState.Substring(4,2) -eq "00")
	{
		$ProductStateText = $ProductStateText + " and up to date"
		$AntivirUpdate = $True
	} ElseIf ($ProductState.Substring(4,2) -eq "10")
	{
		$ProductStateText = $ProductStateText + " and out of date"
		$AntivirUpdate = $False
	}
	
	If ($AntivirEnabled -and $AntivirUpdate)
	{
		$AntiVirStateIcon.Image = $OkIcon
	} ElseIf ($AntivirEnabled -and (-not($AntivirUpdate)))
	{
		$AntiVirStateIcon.Image = $InfoIcon
	}

	$AntiVirSolLabel.Text = "Antivirus solution is $AntiVirSol."
	$AntiVirStateLabel.Text = "Antivirus status is $ProductStateText."
}

Function ADM_SummaryFirewall
{
	$FWDomainPro = "'Domain OFF'"
	$FWPrivatePro = "'Private OFF'"
	$FWPublicPro = "'Public OFF'"
	
	$FirewallIcon = New-Object Windows.Forms.PictureBox
	ADM_GenerateIcon $FirewallIcon Info 0 40 Security
		
	$FirewallLabel = New-Object System.Windows.Forms.Label
   	ADM_GenerateLabel $FirewallLabel 20 43 Security

	$File = Get-Content -Encoding $Encoding $SelectedFolder\Security_FirewallStatus.txt
	If ($File[0] -eq "$True")
	{
		$FWDomainPro = "'Domain ON'"
	}
	If ($File[1] -eq "$True")
	{
		$FWPrivatePro = "'Private ON'"
	}
	If ($File[2] -eq "$True")
	{
		$FWPublicPro = "'Public ON'"
	}

	$FirewallLabel.Text = "Firewall status is $FWDomainPro $FWPrivatePro $FWPublicPro." 
}

Function ADM_SummaryLocalAdmins
{
	$Admin = ""
	
	$LocalAdminIcon = New-Object Windows.Forms.PictureBox
	ADM_GenerateIcon $LocalAdminIcon Info 0 100 Security

	$LocalAdminLabel = New-Object System.Windows.Forms.Label
   	ADM_GenerateLabel $LocalAdminLabel 20 103 Security

	$File = Get-Content -Encoding $Encoding $SelectedFolder\Security_LocalAdministrators.txt
	ForEach ($Line in $File)
	{
		$Admin += "'"+$Line+"'"+" "
	}
	
	$Admin = $Admin.TrimEnd()
	$LocalAdminLabel.Text = "Local Administrators are $Admin."
}

Function ADM_DigDeeperIntoResultFiles
{
	$Selection = $SelectAnalyticsListBox.SelectedItem
	$FilesLookup = Get-Content -Encoding $Encoding $localScriptRoot\Resources\LookupTables\PossibleResultFiles.txt
	
	ForEach ($Line in $FilesLookup)
	{
		If ($Line -match $Selection)
		{
			$LineContent = $Line.Split(":")
		}
	}

	$FileName = $SelectedFolder + "\" + $LineContent[0]
	$FileExtension = $LineContent[0].Split(".")
	If ($FileExtension[1] -eq "csv")
	{
		Import-Csv -Encoding $Encoding $FileName | Out-GridView -Title $FileName
	} ElseIf ($FileExtension[1] -eq "txt")
	{
		Get-Content -Encoding $Encoding $FileName | Out-GridView -Title $FileName
	} ElseIf ($FileExtension[1] -eq "html")
	{
		Start-Process -FilePath "$localScriptRoot\Resources\Bin\offline_html_viewer\OfflineHtmlViewer.exe" -ArgumentList "$FileName"
	} ElseIf ($FileExtension[1] -eq "evtx")
	{
		If (Test-Path $localScriptRoot\Resources\Bin\fulleventlogview-x64\FullEventLogView.cfg -PathType Leaf)
		{
			Remove-Item $localScriptRoot\Resources\Bin\fulleventlogview-x64\FullEventLogView.cfg
		}
		Start-Process -FilePath "$localScriptRoot\Resources\Bin\fulleventlogview-x64\FullEventLogView.exe" -ArgumentList "$FileName"
	} ElseIf ($FileExtension[1] -eq "sqlite")
	{
		Start-Process -FilePath "$localScriptRoot\Resources\Bin\SQLiteDatabaseBrowserPortable\SQLiteDatabaseBrowserPortable.exe" -ArgumentList "$FileName"
	}
}

Function ADM_FilterResultFiles
{
	$ProgressText.Clear()
	$ProgressText.AppendText("Please wait - parsing data...")
    $ProgressText.Update()
	$Progress.Text = ""
	$ProgressWindow.Visible = $True
	$ProgressWindow.Update()
	
	$Selection = $SelectFilterListBox.SelectedItem
	$EventLookup = Get-Content -Encoding $Encoding $localScriptRoot\Resources\LookupTables\FilterEvents.txt
	
	ForEach ($Line in $EventLookup)
	{
		If ($Line -match $Selection)
		{
			$LineContent = $Line.Split(":")
		}
	}

	$Event       = $LineContent[0].Split(";")
	$EventParams = $Event[1].Split("#")
	$EventType   = $EventParams[0]
	$EventFile   = $EventParams[1]
	$EventScope  = $EventParams[2]
	$EventVar    = $EventParams[3]
	
	If ($EventType -eq "EVTX")
	{
		Try
		{
			$FilteredEvents = Get-WinEvent -FilterHashTable @{Path="$SelectedFolder\Eventlog_$EventFile.evtx";ProviderName=$EventScope;ID=$EventVar} -ErrorAction Stop
			$ProgressWindow.Visible = $False
			$FilteredEvents | Select-Object ID,TimeCreated,@{n='Message';e={$_.Message -replace '\r', " "}} | Out-GridView -Title $LineContent[1].TrimStart()
		} Catch
		{
			$ProgressWindow.Visible = $False
			ADM_NoDataWindow
		}
		$ProgressWindow.Visible = $False
	}

	If ($EventType -eq "BLACKLIST")
	{
		$ResultFile = Import-Csv -Encoding $Encoding $SelectedFolder\$EventFile | Select-Object $EventVar
		$BlacklistFiles = Get-Content $localScriptRoot\Resources\LookupTables\Blacklists.txt

		$FoundDomains = @()

		ForEach ($List in $BlacklistFiles)
		{
			$ListName = $List.Split("*")
			$Name = $ListName[1]
			$Description = $ListName[2]
		
			$Blacklist = Get-Content $localScriptRoot\Resources\Blacklists\$Name

			$Counter = 0
			$Reader = New-Object IO.StreamReader $localScriptRoot\Resources\Blacklists\$Name
			While ($Reader.ReadLine() -ne $null) { $Counter++ }
			$Reader.Close() 
		
			$I=0
		
			ForEach ($BlacklistEntry in $Blacklist)
			{
				[System.Windows.Forms.Application]::DoEvents() 
				ForEach ($ResultFileEntry in $ResultFile)
				{
					If ($BlacklistEntry -eq $ResultFileEntry.$EventVar)
					{
						$FoundDomains += $BlacklistEntry
					}
				}
				$Progress.Text = "Checking $I of $Counter entries in $Description"
				$I++
			}
		}
		$ProgressWindow.Visible = $False
		$FoundDomains | Out-GridView -Title "Found blacklist entries"
	}
}

Function ADM_DigDeeperDropDown
{
	$SelectAnalyticsLabel = New-Object System.Windows.Forms.Label
    $SelectAnalyticsLabel.Font = New-Object System.Drawing.Font("Lucida Console",8)
    $SelectAnalyticsLabel.Location = New-Object System.Drawing.Size($AnalyticsX,($AnalyticsY+20))
    $SelectAnalyticsLabel.AutoSize = $True
    $SelectAnalyticsLabel.Anchor = 'Top,Left'
    $SelectAnalyticsLabel.Text = "Dig deeper into gathered data..."

	$SelectAnalyticsOkButton = New-Object System.Windows.Forms.Button
    $SelectAnalyticsOkButton.Location = New-Object System.Drawing.Size(($AnalyticsX+380),($AnalyticsY+39))
    $SelectAnalyticsOkButton.Size = New-Object System.Drawing.Size(75,20)
	$SelectAnalyticsOkButton.FlatStyle = "Flat"
    $SelectAnalyticsOkButton.Text = "Go!"
    $SelectAnalyticsOkButton.Add_Click({ADM_DigDeeperIntoResultFiles})
	
	$global:SelectAnalyticsListBox = New-Object System.Windows.Forms.Listbox 
    $SelectAnalyticsListBox.Location = New-Object System.Drawing.Size($AnalyticsX,($AnalyticsY+40)) 
	$SelectAnalyticsListBox.Font = New-Object System.Drawing.Font("Lucida Console",8)
    $SelectAnalyticsListBox.Size = New-Object System.Drawing.Size(370,320)
	$FilesLookup = Get-Content -Encoding $Encoding $localScriptRoot\Resources\LookupTables\PossibleResultFiles.txt
	$Flag = $False
	ForEach ($File in $FilesLookup)
	{
		$FileNameDescript = $File.Split(":")
		$FileName = $SelectedFolder + "\" + $FileNameDescript[0]
		If (Test-Path $FileName -PathType Leaf)
		{
			$FileDescript = $FileNameDescript[1]
			$FileDescript = $FileDescript.TrimStart()
			$SelectAnalyticsListBox.Items.Add($FileDescript) | Out-Null
		}
		If (-not($Flag))
		{
			$SelectAnalyticsListBox.SelectedItem = $FileDescript
			$Flag = $True
		}
	}

	$MainWindow.Controls.Add($SelectAnalyticsLabel)
	$MainWindow.Controls.Add($SelectAnalyticsListBox)
	$MainWindow.Controls.Add($SelectAnalyticsOkButton)
}

Function ADM_FilterDropDown
{
	$SelectFilterLabel = New-Object System.Windows.Forms.Label
    $SelectFilterLabel.Font = New-Object System.Drawing.Font("Lucida Console",8)
    $SelectFilterLabel.Location = New-Object System.Drawing.Size(($AnalyticsX+500),($AnalyticsY+20))
    $SelectFilterLabel.AutoSize = $True
    $SelectFilterLabel.Anchor = 'Top,Left'
    $SelectFilterLabel.Text = "Filter result files for..."

	$SelectFilterOkButton = New-Object System.Windows.Forms.Button
    $SelectFilterOkButton.Location = New-Object System.Drawing.Size(($AnalyticsX+880),($AnalyticsY+39))
    $SelectFilterOkButton.Size = New-Object System.Drawing.Size(75,20)
	$SelectFilterOkButton.FlatStyle = "Flat"
    $SelectFilterOkButton.Text = "Go!"
    $SelectFilterOkButton.Add_Click({ADM_FilterResultFiles})
	
	$global:SelectFilterListBox = New-Object System.Windows.Forms.Listbox 
    $SelectFilterListBox.Location = New-Object System.Drawing.Size(($AnalyticsX+500),($AnalyticsY+40)) 
	$SelectFilterListBox.Font = New-Object System.Drawing.Font("Lucida Console",8)
    $SelectFilterListBox.Size = New-Object System.Drawing.Size(370,320)
	$EventsLookup = Get-Content -Encoding $Encoding $localScriptRoot\Resources\LookupTables\FilterEvents.txt
	$Flag = $False
	ForEach ($Event in $EventsLookup)
	{
		$EventDescript = $Event.Split(":")
		$EventName = $EventDescript[1]
		$EventName = $EventName.TrimStart()
		$SelectFilterListBox.Items.Add($EventName) | Out-Null
		If (-not($Flag))
		{
			$SelectFilterListBox.SelectedItem = $EventName
			$Flag = $True
		}
	}

	$MainWindow.Controls.Add($SelectFilterLabel)
	$MainWindow.Controls.Add($SelectFilterListBox)
	$MainWindow.Controls.Add($SelectFilterOkButton)
}

Function ADM_ShowSummaryWindow
{
	$MainWindow.Controls.Remove($ChooseFolderLabel)
	$MainWindow.Controls.Remove($ChooseFolderListBox)
	$MainWindow.Controls.Remove($LogfileLabel)
	$MainWindow.Controls.Remove($LogfileSummaryBox)
	$MainWindow.Controls.Remove($ProceedWithAnalyseButton)

	$GeneralLabel = New-Object System.Windows.Forms.Label
    $GeneralLabel.Font = New-Object System.Drawing.Font("Lucida Console",8,[System.Drawing.FontStyle]::Underline)
    $GeneralLabel.Location = New-Object System.Drawing.Size($GeneralX,$GeneralY)
    $GeneralLabel.AutoSize = $True
    $GeneralLabel.Anchor = 'Top,Left'
    $GeneralLabel.Text = "General Information"

	$SecurityLabel = New-Object System.Windows.Forms.Label
    $SecurityLabel.Font = New-Object System.Drawing.Font("Lucida Console",8,[System.Drawing.FontStyle]::Underline)
    $SecurityLabel.Location = New-Object System.Drawing.Size($SecurityX,$SecurityY)
    $SecurityLabel.AutoSize = $True
    $SecurityLabel.Anchor = 'Top,Left'
    $SecurityLabel.Text = "Security Information"

	$AnalyticsLabel = New-Object System.Windows.Forms.Label
    $AnalyticsLabel.Font = New-Object System.Drawing.Font("Lucida Console",8,[System.Drawing.FontStyle]::Underline)
    $AnalyticsLabel.Location = New-Object System.Drawing.Size($AnalyticsX,$AnalyticsY)
    $AnalyticsLabel.AutoSize = $True
    $AnalyticsLabel.Anchor = 'Top,Left'
    $AnalyticsLabel.Text = "Analytics Section"

	$MainWindow.Controls.Add($GeneralLabel)
	$MainWindow.Controls.Add($SecurityLabel)
	$MainWindow.Controls.Add($AnalyticsLabel)

	ADM_SummaryHostname
	ADM_SummaryOS
	ADM_SummaryScanDate
	ADM_SummaryScanUser
	ADM_SummaryLoggedUser
	ADM_SummaryCredentialGuard
	ADM_SummaryUAC
	ADM_SummaryUEFISecureBoot
	ADM_SummaryEMET
	ADM_SummaryAntivirusSolution
	ADM_SummaryFirewall
	ADM_SummaryBitlocker
	ADM_SummaryLocalAdmins
	ADM_DigDeeperDropDown
	ADM_FilterDropDown

	$MainWindow.Refresh()
}

Function ADM_ResultFolderSelected
{
   	$global:SelectedFolder = $ChooseFolderListBox.SelectedItem
	$LogFile = Get-Content -Encoding $Encoding $SelectedFolder\winDECK_Log.txt
    $LogFileSummaryBox.Clear()
    ForEach ($Line in $Logfile)
    {
        $LogFileSummaryBox.AppendText($Line+$OFS)
    }
    $LogFileSummaryBox.Update()
}

Function ADM_Main
{
	$MainWindow = New-Object System.Windows.Forms.Form
	$MainWindow.Size = New-Object System.Drawing.Size($MainWindowWidth,$MainWindowHeight)
	$MainWindow.MinimumSize = "$MainWindowWidth,$MainWindowHeight"
	$MainWindow.Icon = $winDECKIcon
    $MainWindow.Text = "winDECK - Windows Digital Evidence Collection Kit / Analyse Data Module"
    $MainWindow.WindowState ="Normal"
    $MainWindow.StartPosition = "CenterScreen"
	
	$LogFileLabel = New-Object System.Windows.Forms.Label
    $LogFileLabel.Font = New-Object System.Drawing.Font("MS Sans Serif",8)
    $LogFileLabel.Location = New-Object System.Drawing.Size(10,140)
    $LogFileLabel.AutoSize = $True
    $LogFileLabel.Anchor = 'Top,Left'
    $LogFileLabel.Text = "Logfile :"
    
    $LogFileSummaryBox = New-Object System.Windows.Forms.RichTextBox
    $LogFileSummaryBox.Location = New-Object System.Drawing.Size(10,160)
    $LogFileSummaryBox.Size = New-Object System.Drawing.Size(($MainWindowWidth-40),($MainWindowHeight-220))
    $LogFileSummaryBox.Anchor = "Bottom,Top,Left,Right"
    $LogFileSummaryBox.BackColor = "Window"
    $LogFileSummaryBox.ReadOnly = $True

	$ProceedWithAnalyseButton = New-Object System.Windows.Forms.Button
	$ProceedWithAnalyseButtonX = 280
	$ProceedWithAnalyseButtonY = 69
    $ProceedWithAnalyseButton.Location = New-Object System.Drawing.Size($ProceedWithAnalyseButtonX,$ProceedWithAnalyseButtonY)
	$ProceedWithAnalyseButton.Size = New-Object System.Drawing.Size(170,23)
	$ProceedWithAnalyseButton.FlatStyle = "Flat"
	$ProceedWithAnalyseButton.BackColor = "Green"
	$ProceedWithAnalyseButton.ForeColor = "White"
	$ProceedWithAnalyseButton.Anchor = "Top,Left"
	$ProceedWithAnalyseButton.Text = "Proceed with this result set ?"
    $ProceedWithAnalyseButton.Add_Click({ADM_ShowSummaryWindow})

	$ChooseFolderLabel = New-Object System.Windows.Forms.Label
	$ChooseFolderLabel.Font = New-Object System.Drawing.Font("MS Sans Serif",8)
    $ChooseFolderLabel.Location = New-Object System.Drawing.Size(10,50)
    $ChooseFolderLabel.AutoSize = $True
    $ChooseFolderLabel.Anchor = 'Top,Left'
    $ChooseFolderLabel.Text = "Please choose result folder :"
    
    $ChooseFolderListBox = New-Object System.Windows.Forms.ListBox 
    $ChooseFolderListBox.Location = New-Object System.Drawing.Size(10,70) 
	$ChooseFolderListBox.Font = New-Object System.Drawing.Font("MS Sans Serif",8)
    $ChooseFolderListBox.Size = New-Object System.Drawing.Size(260,60) 
    $ResultFolders = Get-ChildItem -Directory winDECK_Results_* | Select-Object -ExpandProperty Name
    $Flag = $False
	ForEach ($FolderName in $ResultFolders)
    {
        $ChooseFolderListBox.Items.Add("$FolderName") | Out-Null
		If (-not($Flag))
		{
			$ChooseFolderListBox.SelectedItem = $FolderName
			$Flag = $True
			ADM_ResultFolderSelected		
		}
    }
	$ChooseFolderListBox.Add_SelectedIndexChanged({ADM_ResultFolderSelected})

	$ProgressWindow = New-Object System.Windows.Forms.Form
    $ProgressWindow.Size = New-Object System.Drawing.Size($ProgressWindowWidth,$ProgressWindowHeight)
	$ProgressWindow.FormBorderStyle = "FixedDialog"
	$ProgressWindow.ControlBox = $False
    $ProgressWindow.Text = "winDECK is working for you..."
    $ProgressWindow.WindowState ="Normal"
    $ProgressWindow.StartPosition = "CenterScreen"
	$ProgressWindow.Visible = $False

	$ProgressText = New-Object System.Windows.Forms.RichTextBox
    $ProgressText.Font = New-Object System.Drawing.Font("MS Sans Serif",10)
	$ProgressText.Location = New-Object System.Drawing.Size(10,10)
    $ProgressText.Size = New-Object System.Drawing.Size(($ProgressWindowWidth-40),($ProgressWindowHeight-150))
	$ProgressText.Borderstyle = "None"
	$ProgressText.Enabled = $False
    $ProgressText.ReadOnly = $True
	$ProgressWindow.Controls.Add($ProgressText)

	$Progress = New-Object System.Windows.Forms.Label
    $Progress.Font = New-Object System.Drawing.Font("MS Sans Serif",10)
	$Progress.Location = New-Object System.Drawing.Size(10,($ProgressWindowHeight-140))
    $Progress.AutoSize = $True
	$ProgressWindow.Controls.Add($Progress)

	$UpdateBLWindow = New-Object System.Windows.Forms.Form
    $UpdateBLWindow.Size = New-Object System.Drawing.Size($UpdateBLWindowWidth,$UpdateBLWindowHeight)
	$UpdateBLWindow.FormBorderStyle = "FixedDialog"
	$UpdateBLWindow.ControlBox = $False
    $UpdateBLWindow.Text = "winDECK is working for you..."
    $UpdateBLWindow.WindowState ="Normal"
    $UpdateBLWindow.StartPosition = "CenterScreen"

    $UpdateBLCloseButton = New-Object System.Windows.Forms.Button
    $UpdateBLCloseButton.Location = New-Object System.Drawing.Size((($UpdateBLWindowWidth/2) - 44),($UpdateBLWindowHeight - 78))
    $UpdateBLCloseButton.Size = New-Object System.Drawing.Size(75,23)
	$UpdateBLCloseButton.FlatStyle = "Flat"
    $UpdateBLCloseButton.Text = "Close"
    $UpdateBLCloseButton.Add_Click({$UpdateBLWindow.Visible = $False})
	
	$UpdateBLText = New-Object System.Windows.Forms.RichTextBox
    $UpdateBLText.Font = New-Object System.Drawing.Font("MS Sans Serif",10)
	$UpdateBLText.Location = New-Object System.Drawing.Size(10,10)
    $UpdateBLText.Size = New-Object System.Drawing.Size(($UpdateBLWindowWidth-40),($UpdateBLWindowHeight-100))
	$UpdateBLText.Borderstyle = "None"
	$UpdateBLText.Enabled = $False
    $UpdateBLText.ReadOnly = $True
	$UpdateBLWindow.Visible = $False
	$UpdateBLWindow.Controls.Add($UpdateBLText)

	$MenuStrip = New-Object System.Windows.Forms.MenuStrip
	$FileMenuStripItem = New-Object System.Windows.Forms.ToolStripMenuItem
	$ExitMenuStripItem = New-Object System.Windows.Forms.ToolStripMenuItem
	$ToolsMenuStripItem = New-Object System.Windows.Forms.ToolStripMenuItem
	$UpdateBLMenuStripItem = New-Object System.Windows.Forms.ToolStripMenuItem
	$HelpMenuStripItem = New-Object System.Windows.Forms.ToolStripMenuItem
	$AboutMenuStripItem = New-Object System.Windows.Forms.ToolStripMenuItem

	$MenuStrip.Items.AddRange(@($FileMenuStripItem, $ToolsMenuStripItem, $HelpMenuStripItem))
	$MenuStrip.Location = New-Object System.Drawing.Point(0,0)
	$MenuStrip.Size = New-Object System.Drawing.Size($MainWindowWidth,24)
    $MenuStrip.TabIndex = 0

	$FileMenuStripItem.DropDownItems.AddRange(@($ExitMenuStripItem))
	$FileMenuStripItem.Size = New-Object System.Drawing.Size(35,20)
	$FileMenuStripItem.Text = "&File"

	$ExitMenuStripItem.Size = New-Object System.Drawing.Size(152,22)
	$ExitMenuStripItem.Text = "&Exit"
	$ExitMenuStripItem.Add_Click({$MainWindow.Close()})

	$ToolsMenuStripItem.DropDownItems.AddRange(@($UpdateBLMenuStripItem))
	$ToolsMenuStripItem.Size = New-Object System.Drawing.Size(35,20)
	$ToolsMenuStripItem.Text = "&Tools"

	$UpdateBLMenuStripItem.Size = New-Object System.Drawing.Size(152,22)
	$UpdateBLMenuStripItem.Text = "&Update Blacklists"
	$UpdateBLMenuStripItem.Add_Click({ADM_UpdateBlacklists})
	
	$HelpMenuStripItem.DropDownItems.AddRange(@($AboutMenuStripItem))
	$HelpMenuStripItem.Size = New-Object System.Drawing.Size(35,20)
	$HelpMenuStripItem.Text = "&Help"

	$AboutMenuStripItem.Size = New-Object System.Drawing.Size(152,22)
	$AboutMenuStripItem.Text = "&About winDECK"
	$AboutMenuStripItem.Add_Click({ADM_AboutWindow})

	# Show window

	$MainWindow.Controls.Add($ChooseFolderLabel)
	$MainWindow.Controls.Add($MenuStrip)
    $MainWindow.Controls.Add($ChooseFolderListBox)
    $MainWindow.Controls.Add($LogFileLabel)
    $MainWindow.Controls.Add($LogFileSummaryBox)
	$MainWindow.Controls.Add($ProceedWithAnalyseButton)
	$global:DialogResult = $MainWindow.ShowDialog()
}

#endregion