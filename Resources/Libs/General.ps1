# winDECK - Windows Digital Evidence Collection Kit
#
# winDECK_Functions.ps1
#
# General Library
#
# v0.8 Beta
#
# 21.08.2017
#
# (C) Stefan Kubsch
#

Set-StrictMode -Version "Latest"
    
#region Declare and fill global constants and variables

$Hostname                       = (Get-WmiObject -Class Win32_ComputerSystem -Property Name).Name
$OSFlag64bit                    = [Environment]::Is64BitProcess
$OSVersion                      = [Environment]::OSVersion.Version
$OSName                         = Get-WmiObject -Class Win32_OperatingSystem | ForEach-Object -MemberName Caption
$OSLanguage                     = Get-WmiObject -Class Win32_OperatingSystem | ForEach-Object -Membername OSLanguage
$OFS                            = "`r`n"
$Encoding                       = "UTF8"

#endregion

#region Functions

#region Screen

Function WaitForKey
{
    If ($Host.Name -eq "ConsoleHost")
    { 
        Write-Host ""
        Write-Host "Press any key to continue..."
        $Host.UI.RawUI.FlushInputBuffer()
        $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $Null
    }
}

Function ShowSplashScreen
{	
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		$SplashScreen
	)

    Clear-Host
    ForEach ($Line in $SplashScreen) 
    {
        Write-Host -BackgroundColor DarkGreen -ForegroundColor Yellow $Line
    }
}

Function Header_InitializeEnvironment
{    
    Set-Location $localScriptRoot
    Write-Host ""
    Write-Host -BackgroundColor Red "Initializing environment..."
    Write-Host ""
    Write-Host "Operating System is " -NoNewline
    If ($OSFlag64bit)
    {
        Write-Host "64bit (just for information)."
    } Else
    {
        Write-Host "32bit (just for information)."
    }
}

Function Header_Security
{    
    Write-Host ""
    Write-Host -BackgroundColor Red "Running security tasks..."
    Write-Host ""
}

Function Header_PreparingExit
{    
    Write-Host ""
    Write-Host -BackgroundColor Red "Preparing exit..."
    Write-Host ""
    Set-Location $localScriptRoot
    Write-Host "Program finished successfully!"
    Write-Host ""
    WaitForKey
}

#endregion

#region Integrity Checks

Function SecureFile
{
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		$File
	)

    $HashFileName = $CDMResultsFolder + "\" + $Hostname + "_Hashes.txt"
	$GetHash = Get-FileHash -Path $CDMResultsFolder\$File -Algorithm SHA256
	$FileName = Split-Path $GetHash.Path -Leaf
	$Line = $GetHash.Hash + " *" + $FileName
	$Line | Out-File -Encoding $Encoding $HashFilename -Append
	Set-ItemProperty -Path $CDMResultsFolder\$FileName -Name IsReadOnly -Value $True
}

Function CheckSHA256Hashes
{
    $ArrayResultFolders = Get-ChildItem -Directory winDECK_Results_* | Select-Object -ExpandProperty Name
    ForEach ($ResultFolderName in $ArrayResultFolders)
    {
        Write-Host "Checking SHA256 hashes for files in folder " -NoNewline
        Write-Host -ForegroundColor Magenta $ResultFolderName
        Write-Host ""
        $Filename = Get-ChildItem -Path $ResultFolderName "*_Hashes.txt" | Select-Object -ExpandProperty Name
        If (-not($Filename))
        {
            Write-Host -BackgroundColor Red "No hashfile in folder $ResultFolderName found. Exiting."
            WaitForKey
            Exit
        } Else
        {
            $Hashfile = $localScriptRoot + "\" + $ResultFolderName + "\" + $Filename
            $Hash = Get-Content -Encoding $Encoding $Hashfile
            ForEach ($Line in $Hash)
            {
                $HashAndName = $Line.Split("*")
                $HashToCheck = $HashAndName[0].Substring(0,$HashAndName[0].Length-01)
                $FileToCheck = $localScriptRoot + "\" + $ResultFolderName + "\" + $HashAndName[1]
                Write-Host $HashAndName[1]"..." -NoNewline
                $GetHash = Get-FileHash -Path $FileToCheck -Algorithm SHA256
                If ($GetHash.Hash -eq $HashToCheck)
                {
                    Write-Host "Ok."
                   
                } Else
                {
                    Write-Host -BackgroundColor Red "wrong checksum, file was modified. Exiting."
                    WaitForKey
                    Exit
                } 
            }
        }
        Write-Host ""
    }
}

Function CheckReadOnly
{
	$ArrayResultFolders = Get-ChildItem -Directory winDECK_Results_* | Select-Object -ExpandProperty Name
    ForEach ($ResultFolderName in $ArrayResultFolders)
    {
        Write-Host "Checking if files are still write-protected in folder " -NoNewline
        Write-Host -ForegroundColor Magenta $ResultFolderName
        Write-Host ""
        $Files = Get-ChildItem -Path $ResultFolderName
		ForEach ($File in $Files)
		{
			$CheckFile = $ResultFolderName + "\" + $File.Name
			Write-Host $File.Name"..." -NoNewline
			$Result = Get-ItemProperty $CheckFile
			If (-Not($Result.IsReadOnly))
			{
				Write-Host -BackgroundColor Red "is not write-protected. Exiting."
				WaitForKey
				Exit
			} Else
			{
				Write-Host "Ok."
			}
		}
	}
}

#endregion

#region OS

Function CheckForOSVersion
{
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		$OSVer
	)

    Write-Host "Checking if Operating System is Windows 10..." -NoNewline
    If ($OSVersion -match $OSVer)
    {
		Write-Host -ForegroundColor Magenta $OSName -NoNewline
        Write-Host " found. Ok!"
    } Else
    {
        Write-Host -ForegroundColor Magenta $OSName -NoNewline
        Write-Host " is not supported. Exiting."
        WaitForKey
        Exit
    }
}

Function CheckForPSVersion
{
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		$MinPSVersion
	)

    Write-Host "Checking if at least PowerShell version " -NoNewline
    Write-Host -ForegroundColor Magenta $MinPSVersion -NoNewline
    Write-Host " is available..." -NoNewline
    $PSVersion = $PSVersionTable.PSVersion
    If ($PSVersion.Major -ge $MinPSVersion)
    {
        Write-Host -ForegroundColor Magenta "PowerShell"$PSVersion -NoNewline
        Write-Host " is available. Ok!"
    } Else
    {
        Write-Host -ForegroundColor Magenta "PowerShell"$PSVersion -NoNewline
        Write-Host " is not supported. Exiting."
        WaitForKey
        Exit
    }
}

#endregion

#region Rights

Function CheckForAdminRights
{
    Write-Host "Checking for administrator privileges..." -NoNewline
    If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    {
        Write-Host "Ok!"
    } Else
    {
        Write-Host -BackgroundColor Red "Program must be run as Administrator. Exiting."
        WaitForKey
        Exit
    }
}

#endregion

#region Logging

Function StartLogging ($Path)
{
    Write-Host "Start logging..." -NoNewline
    Start-Transcript -Path $Path\winDECK_Log.txt | Out-Null
    Write-Host "Done."
}

Function StopLogging
{
    Write-Host "Stop logging..." -NoNewline
    Stop-Transcript | Out-Null
	SecureFile winDECK_Log.txt
	Write-Host "Done."
}

#endregion

#region Filesystem

Function CreateResultsFolder
{
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		$Folder
	)

    Write-Host "Creating result folder " -NoNewline
    Write-Host -ForegroundColor Magenta $Folder -NoNewline
    Write-Host "..." -NoNewline
    If (Test-Path $Folder) 
    {
        Write-Host -BackgroundColor Red "Folder already exists, cannot be run twice on same computer with same stick. Exiting."
        WaitForKey
        Exit
    }
    New-Item -Path $Folder -ItemType "Directory" | Out-Null
    Set-Location $Folder
    Write-Host "Done."
}

Function CheckWriteAccess
{
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		$Path
	)

    Write-Host "Checking if destination folder is writeable..." -NoNewline
    Set-Content -Path $Path\Test.txt -Value $NULL -ErrorAction SilentlyContinue -ErrorVariable Result
    If ($Result.Count)
    {
        Write-Host -BackgroundColor Red "Folder is not writeable...Exiting."
        WaitForKey
        Exit
    } Else
    {
        Write-Host "Ok!"
        Remove-Item -Force $Path\Test.txt
    }
}

Function CheckFreeSpace
{
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$True,Position=1)]
		$Drive
	)

    $OutputDriveFree = Get-PSDrive $Drive | Select-Object -ExpandProperty Free
    $OutputDriveFree = [Math]::Floor($OutputDriveFree/1GB)
    Write-Host "Checking available disk space for result folder...$OutputDriveFree GB free on drive $Drive..." -NoNewline
    If ($OutputDriveFree -gt 1) 
    {
        Write-Host "Ok!"
    } Else
    { 
        Write-Host -BackgroundColor Red "At least 1GB of free disk space is needed."
        Write-Host -BackgroundColor Red "Not enough disk space to save result files. Exiting."
        WaitForKey
        Exit
    }
}

Function CheckForExistingResultsFolders
{
    Write-Host "Checking for existing result folders..." -NoNewline
    $PFMFoldersToParse = @()
    $PFMFoldersToParse = Get-ChildItem -Directory winDECK_Results_* | Select-Object -ExpandProperty Name
    If ($PFMFoldersToParse)
    {
        Write-Host ""
        Write-Host ""
        ForEach ($FolderName in $PFMFoldersToParse)
        {
            Write-Host "Found : " -NoNewline 
            Write-Host -ForegroundColor Magenta $FolderName
        }
    } Else
    {
        Write-Host -BackgroundColor Red "No existing result folders found. Exiting."
        WaitForKey
        Exit
    } 
}

#endregion

#endregion