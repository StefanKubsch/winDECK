Import-Module DefenderImport-Module DefenderImport-Module SecureBoot# winDECK - Windows Digital Evidence Collection Kit
#
# winDECK_Module_CreateUSBStick.ps1
#
# Create USB Stick
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
. "$PSScriptRoot\Resources\Libs\General.ps1"
. "$PSScriptRoot\Resources\Libs\CUS.ps1"
#endregion

#region Initialize environment
ShowSplashScreen ($CUSSplashScreen)
Header_InitializeEnvironment
CheckForPSVersion ($CUSMinPSVersion)
CheckForAdminRights
CheckForOSVersion(10)
#endregion

#region USB handling

# Check for useable USB sticks
Write-Host ""
Write-Host -BackgroundColor Red "Searching for useable USB sticks..."

$Sticks = Get-Disk |  Where-Object BusType -eq "USB"
ForEach ($Stick in $Sticks)
{
	$Size = [Math]::Floor($Stick.AllocatedSize/1GB)
	If (($Size -gt $NeededStickSize) -and ($Size -lt 128)) 
	{
		$AvailableSticks += $Stick
	} 
}

$AvailableSticks | Sort-Object Number | Format-Table -AutoSize

If (-Not($AvailableSticks))
{
	Write-Host -ForegroundColor Red "No useable sticks were found. Exiting."
	WaitForKey
    Exit
}

# Select USB stick
Write-Host -BackgroundColor Red "Please select USB stick for preparation..."
Write-Host ""

$Flag = $False
While (-Not($Flag))
{
	$ChosenNumber = Read-Host "Which stick do you want to use (choose Drivenumber)"
	ForEach ($Stick in $AvailableSticks)
	{
		If ($ChosenNumber -eq $Stick.Number)
		{
			$Flag = $True
			$ChosenStick = $Stick
		} 
	}
	If (-Not($Flag))
	{
		Write-Host -ForegroundColor Red "Invalid input. Please choose again!"
	}
}

$Flag = $False
While (-Not($Flag))
{
	Write-Host "Do you really want to use stick " -NoNewline
	Write-Host -ForegroundColor Magenta $ChosenStick.FriendlyName -NoNewline
	$Input = Read-Host " (y/n)"
	If ($Input.ToUpper() -eq "Y")
	{
		$Flag = $True
	} ElseIf ($Input.ToUpper() -eq "N") 
	{
		Write-Host -ForegroundColor Red "Operation aborted. Exiting."
		WaitForKey
		Exit
	} Else
	{
		Write-Host -ForegroundColor Red "Invalid input. Please choose again!"
	}
}

# Find a free driveletter
$DriveLetter = [int][char]'C'
While ((Get-PSDrive -PSProvider FileSystem).Name -Contains [char]$DriveLetter)
{
	$DriveLetter++
}
$DriveLetter = [char]$DriveLetter

# Format USB stick
Write-Host ""
Write-Host -BackgroundColor Red "Prepare chosen USB stick..."
Write-Host ""

Write-Host "Formatting USB stick " -NoNewline
Write-Host -ForegroundColor Magenta $ChosenStick.FriendlyName -NoNewline
Write-Host "..." -NoNewline
Stop-Service -Name ShellHWDetection
Get-Disk $ChosenStick.Number | Clear-Disk -RemoveData -Confirm:$False -PassThru | New-Partition -UseMaximumSize -DriveLetter $Driveletter -IsActive | Format-Volume -FileSystem NTFS -NewFileSystemLabel winDECK -Confirm:$False | Out-Null
Start-Service -Name ShellHWDetection
Write-Host "Done."

# Copy files to stick
Write-Host ""
$CopyToPath = $DriveLetter+":"
Write-Host "Copy needed files to USB stick and write-protect them..." -NoNewline
New-Item -Path $CopyToPath\Resources\Libs -ItemType "Directory" | Out-Null

Copy-Item $localScriptRoot\Resources\Libs\General.ps1 $CopyToPath\Resources\Libs | Out-Null
Set-ItemProperty -Path $CopyToPath\Resources\Libs\General.ps1 -Name IsReadOnly -Value $True

Copy-Item $localScriptRoot\Resources\Libs\CDM.ps1 $CopyToPath\Resources\Libs | Out-Null
Set-ItemProperty -Path $CopyToPath\Resources\Libs\CDM.ps1 -Name IsReadOnly -Value $True

Copy-Item $localScriptRoot\RUN_winDECK_Step2_CollectData.cmd $CopyToPath\ | Out-Null
Set-ItemProperty -Path $CopyToPath\RUN_winDECK_Step2_CollectData.cmd -Name IsReadOnly -Value $True

Copy-Item $localScriptRoot\winDECK_Module_CollectData.ps1 $CopyToPath\ | Out-Null
Set-ItemProperty -Path $CopyToPath\winDECK_Module_CollectData.ps1 -Name IsReadOnly -Value $True

Write-Host "Done."

#endregion

#region Exit winDECK
Header_PreparingExit
#endregion

