##[Ps1 To Exe]
##
##Kd3HDZOFADWE8uO1
##Nc3NCtDXTlGDjpXU7jFk2WbhRiYEfMKat7+9wZPxrda/6XCIG9QdSlsX
##Kd3HFJGZHWLWoLaVvnQnhQ==
##LM/RF4eFHHGZ7/K1
##K8rLFtDXTiW5
##OsHQCZGeTiiZ4NI=
##OcrLFtDXTiS5
##LM/BD5WYTiiZ4tI=
##McvWDJ+OTiiZ4tI=
##OMvOC56PFnzN8u+VslQ=
##M9jHFoeYB2Hc8u+VslQ=
##PdrWFpmIG2HcofKIo2QX
##OMfRFJyLFzWE8uK1
##KsfMAp/KUzWI0g==
##OsfOAYaPHGbQvbyVvnQmqxugEiZ6Dg==
##LNzNAIWJGmPcoKHc7Do3uAu/DDhlPovK2Q==
##LNzNAIWJGnvYv7eVvnRW60TjQ2QyLumOt7WvwZPc
##M9zLA5mED3nfu77Q7TV64AuzAgg=
##NcDWAYKED3nfu77Q7TV64AuzAgg=
##OMvRB4KDHmHQvbyVvnRW60TjQ2QyLuSdv7+pzZWlv8b5tSbRTIh0
##P8HPFJGEFzWE8tI=
##KNzDAJWHD2fS8u+Vgw==
##P8HSHYKDCX3N8u+VxiZ+6keuCjp7PJbS2Q==
##LNzLEpGeC3fMu77Ro2k3hQ==
##L97HB5mLAnfMu77Ro2k3hQ==
##P8HPCZWEGmaZ7/K1
##L8/UAdDXTlGDjofB6jhk2WrgTWUqYtyrq7mtwYKow8vitCjYRYM4SEF5lSH5FgW4Qfdy
##Kc/BRM3KXxU=
##
##
##fd6a9f26a06ea3bc99616d4851b372ba
[CmdletBinding()]
Param (
	[Parameter(Mandatory=$false)]
	[string]
	$MO2_Exe,

	[Parameter(Mandatory=$false)]
	[string]
	$MO2_Profile,
	
	[Parameter(Mandatory=$false)]
	[int]
	$Anomaly_Delay,
	
	[Parameter(Mandatory=$false)]
	[switch]
	$AskProfile,
	
	[Parameter(Mandatory=$false)]
	[switch]
	$IgnoreConfig,
	
	[Parameter(Mandatory=$false)]
	[switch]
	$FixedShortcut,
	
	[Parameter(Mandatory=$false)]
	[switch]
	$NoShortcut,
	
	[Parameter(Mandatory=$false)]
	[switch]
	$h,
	
	[Parameter(Mandatory=$false)]
	[switch]
	$Help
)

#$ErrorActionPreference = "Stop"


# Functions
Function Set-ConsoleSize {
	[CmdletBinding()]
	Param(
		 [Parameter(Mandatory=$False,Position=0)]
		 [int]$Height = 40,
		 [Parameter(Mandatory=$False,Position=1)]
		 [int]$Width = 120
		 )
		 
	$console = $host.ui.rawui
	$ConBuffer  = $console.BufferSize
	$ConSize = $console.WindowSize

	$currWidth = $ConSize.Width
	$currHeight = $ConSize.Height

	# if height is too large, set to max allowed size
	If ($Height -gt $host.UI.RawUI.MaxPhysicalWindowSize.Height) {
		$Height = $host.UI.RawUI.MaxPhysicalWindowSize.Height
	}

	# if width is too large, set to max allowed size
	If ($Width -gt $host.UI.RawUI.MaxPhysicalWindowSize.Width) {
		$Width = $host.UI.RawUI.MaxPhysicalWindowSize.Width
	}

	# If the Buffer is wider than the new console setting, first reduce the width
	If ($ConBuffer.Width -gt $Width ) {
	   $currWidth = $Width
	}
	# If the Buffer is higher than the new console setting, first reduce the height
	If ($ConBuffer.Height -gt $Height ) {
		$currHeight = $Height
	}
	# initial resizing if needed
	$host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.size($currWidth,$currHeight)

	# Set the Buffer
	$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.size($Width,2000)

	# Now set the WindowSize
	$host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.size($Width,$Height)
}

Function Set-Shortcut {
	Param (
		[string]$SourcePath,
		[string]$ArgumentsToSource,
		[string]$WorkingDirectory,
		[string]$DestinationPath,
		[string]$IconLocation,
		[string]$Description
	)
	
	If (Test-Path -Path $SourcePath) {
		Try {
			$WshShell = New-Object -comObject WScript.Shell
			$Shortcut = $WshShell.CreateShortcut($DestinationPath)
			$Shortcut.TargetPath = $SourcePath
			$Shortcut.Arguments = $ArgumentsToSource
			$Shortcut.WorkingDirectory = $WorkingDirectory
			$Shortcut.IconLocation = $IconLocation
			$Shortcut.Description = $Description
			$Shortcut.Save()
		}
		Catch {
			$ErrorMessage = $_.Exception.Message.Trim()
			Write-Host "Failed to create shortcut for $SourcePath" -ForegroundColor Red
			Write-Host "$ErrorMessage" -ForegroundColor Red
		}
	}
	else {
		Write-Host "Cannot find $SourcePath" -ForegroundColor Red
	}
}

Function GenerateListBox {
	Param(
		[Parameter(Mandatory=$true,Position=0)]
		[string]$title,
		[Parameter(Mandatory=$true,Position=1)]
		[string]$msg,
		[Parameter(Mandatory=$true,Position=2)]
		[array]$listOfElements
	)
	
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing
	
	[int]$elementHight = 15
	
	$form = New-Object System.Windows.Forms.Form
	$form.Text = $title
	$form.Size = New-Object System.Drawing.Size(300,(120 + $listOfElements.Count * $elementHight))
	$form.StartPosition = 'CenterScreen'

	$okButton = New-Object System.Windows.Forms.Button
	$okButton.Location = New-Object System.Drawing.Point(75,(45 + $listOfElements.Count * $elementHight))
	$okButton.Size = New-Object System.Drawing.Size(75,23)
	$okButton.Text = 'OK'
	$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.AcceptButton = $okButton
	$form.Controls.Add($okButton)

	$cancelButton = New-Object System.Windows.Forms.Button
	$cancelButton.Location = New-Object System.Drawing.Point(150,(45 + $listOfElements.Count * $elementHight))
	$cancelButton.Size = New-Object System.Drawing.Size(75,23)
	$cancelButton.Text = 'Cancel'
	$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $cancelButton
	$form.Controls.Add($cancelButton)

	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,20)
	$label.Size = New-Object System.Drawing.Size(280,20)
	$label.Text = $msg
	$form.Controls.Add($label)

	$listBox = New-Object System.Windows.Forms.ListBox
	$listBox.Location = New-Object System.Drawing.Point(10,40)
	$listBox.Size = New-Object System.Drawing.Size(260,20)
	$listBox.Height = $listOfElements.Count * $elementHight
	
	ForEach ($element in $listOfElements) { 
		[void] $listBox.Items.Add($element)
	}

	$form.Controls.Add($listBox)

	$form.Topmost = $true

	$result = $form.ShowDialog()

	If ($result -eq [System.Windows.Forms.DialogResult]::OK) {
		$x = $listBox.SelectedItem
		$x
	}
}

Function Skill-Issue ($error_msg) {
	Clear
	Write-Host
	Write-Host
	Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($error_msg.Length / 2)))), $error_msg) -ForegroundColor DarkRed
	Write-Host
	Write-Host
	Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor('Skill Issue...'.Length / 2)))), 'Skill Issue...') -ForegroundColor DarkRed
	Write-Host
	$host.UI.RawUI.FlushInputBuffer()
	[void][System.Console]::ReadKey($true)
	[Console]::CursorVisible = $true
}

Function LaunchedFromExe {
	$CurrentPS_ID = [System.Diagnostics.Process]::GetCurrentProcess().Id
	$CurrentPS_Process = Get-WmiObject Win32_Process -Filter "ProcessId = '$CurrentPS_ID'"
	$Launcher_ID = $CurrentPS_Process.ParentProcessId
	$Launcher_Process = Get-WmiObject Win32_Process -Filter "ProcessId = '$Launcher_ID'"
	If ($Launcher_Process) {
		$Launcher_Exe = $Launcher_Process.ExecutablePath
	}
	Else {
		# Parent already terminated
		$Launcher_Exe = $CurrentPS_Process.ExecutablePath
	}
	$Launcher_Path = $(Split-Path -Path $Launcher_Exe)
	$prop = [Ordered]@{
		'LaunchedFromExe' = $true
		'Launcher_Exe' = $Launcher_Exe
		'Launcher_Path' = $Launcher_Path
	}
	If ($Launcher_Exe -match 'explorer\.exe' -or $Launcher_Exe -match 'powershell\.exe' -or $Launcher_Exe -match 'cmd\.exe') {
		$prop.LaunchedFromExe = $false
	}
	$obj = New-Object -TypeName PSObject -Property $prop
	Return $obj
}


# Set window title and size
$host.ui.RawUI.WindowTitle = "Anomaly Affinity Launcher"
$host.ui.RawUI.BackgroundColor = 'Black'
$host.ui.RawUI.ForegroundColor = 'Green'
[Console]::CursorVisible = $false
# Display Help
If ($h -or $Help) {
	Clear
	Write-Host "Anomaly Affinity Launcher by Eriol (2023)"
	Write-Host
	Write-Host "Purpose of this launcher is to start Anomaly with a CPU affinity where CPU 0 is excluded."
	Write-Host "This can ensure that the X-Ray Monolith engine does not use the most occupied core while the game is running."
	Write-Host
	Write-Host "Available options:"
	Write-Host
	Write-Host "   -MO2_Exe `"PathToMO2Executable`"        Configures ModOrganizer.exe location"
	Write-Host "   -MO2_Profile MO2Profile               Configures ModOrganizer profile to use (eg: DX11-AVX)"
	Write-Host "   -Anomaly_Delay 5                      Configures delay in seconds before affinity applied"
	Write-Host "   -AskProfile                           Asks for profile regardless of configuration file"
	Write-Host "   -IgnoreConfig                         Ignore usage of launcher configuration file completely"
	Write-Host "   -Help                                 This help summary"
	
	Write-Host
	$host.UI.RawUI.FlushInputBuffer()
	[void][System.Console]::ReadKey($true)
	[Console]::CursorVisible = $true
	Exit
}
Set-ConsoleSize -Height 9 -Width 70
Clear

# Detect if Launched from executable
$LaunchedQuery = LaunchedFromExe
$LaunchedFromExe = $LaunchedQuery.LaunchedFromExe
If ($LaunchedFromExe) {
	[string]$ScriptFile = $LaunchedQuery.Launcher_Exe
	[string]$ScriptPath = $LaunchedQuery.Launcher_Path
}
Else {
	[string]$ScriptFile = $MyInvocation.MyCommand.Path
	[string]$ScriptPath = Split-Path $ScriptFile -Parent
}

# Relaunch the script with administrator privileges
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
		[string]$Restart_Script = '''' + $ScriptFile + ''''
		If ($MyInvocation.Line) {
			[string]$Restart_Parms = $($MyInvocation.Line) -Replace ".*\\$(Split-Path $ScriptFile -Leaf)[', ]*" -Replace '"',''''
		}
		Else {
			$ScriptFileDBS = $ScriptFile -Replace '\\','\\'
			[string]$Restart_Parms = $(Get-WmiObject Win32_Process -Filter "ExecutablePath = '$ScriptFileDBS'").CommandLine -Replace ".*\\$(Split-Path $ScriptFile -Leaf)[`", ]*" -Replace '"',''''
		}
		[string]$Restart_Line = '& ' + $Restart_Script + ' ' + $Restart_Parms
		Skill-Issue "Press a key to restart with Monolith privileges"
		Try {
			Start-Process powershell.exe "-ExecutionPolicy Bypass -NoProfile $Restart_Line" -Verb RunAs
		}
		Catch {
			Skill-Issue "Soon the Monolith will cancel your privileges too"
		}
		Exit
}

# Other Variables
$Anomaly_Exe = 'AnomalyDX*'
$Anomaly_Priority = "High"
$Default_Delay = 5
$AppCompatFlagsPath = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' 
# Calculate affinity
$Logical_Cores = $(Get-WmiObject -class Win32_processor).NumberOfLogicalProcessors
If ($Logical_Cores -le 2) {
	Skill-Issue "Potato computer detected"
	Exit
}
[Int]$Anomaly_Affinity = $([Math]::Pow(2, $Logical_Cores) - 2)


# Load missing data from config file if available
$Config_File = $ScriptFile -Replace '(\.ps1)|(\.exe)','.ini'
If ((Test-Path -Path $Config_File -PathType Leaf) -and (-not($IgnoreConfig))) {
	If (!$MO2_Exe) {
		Try {
			$MO2_Exe = $(Get-Content -Path "$Config_File" | Where-Object { $_ -match 'MO2_Exe=' }).Split('=')[1]
		}
		Catch {}
	}
	If (!$MO2_Profile -and !$AskProfile) {
		Try {
			$MO2_Profile = $(Get-Content -Path "$Config_File" | Where-Object { $_ -match 'MO2_Profile=' }).Split('=')[1]
		}
		Catch {}
	}
	If (!$Anomaly_Delay) {
		Try {
			$Anomaly_Delay = $(Get-Content -Path "$Config_File" | Where-Object { $_ -match 'Anomaly_Delay=' }).Split('=')[1]
		}
		Catch {}
	}
}

# Look for MO2
If (!$MO2_Exe) {
	$MO2_Exe = "$ScriptPath\ModOrganizer.exe"
}
While (-not(Test-Path -Path $MO2_Exe -PathType Leaf)) {
	Write-Host "Browse for ModOrganizer.exe..."
	Add-Type -AssemblyName System.Windows.Forms
	$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
		Title = "Browse for ModOrganizer.exe"
		InitialDirectory = $ScriptPath
		Filter = 'ModOrganizer |ModOrganizer.exe'
	}
	[void]$FileBrowser.ShowDialog()
	$MO2_Exe = $FileBrowser.FileName
	If ([string]::IsNullOrEmpty($MO2_Exe)) {
		Exit
	}
	Clear
}

# Check for profile
[array]$MO2_PossibleProfiles = @()
Try {
	ForEach ($line in Get-Content -Path "$($MO2_Exe -Replace '.exe', '.ini')") {
		If (($line -match '\\title=') -and ($line -notmatch 'Explore Virtual Folder')) {
			$MO2_PossibleProfiles += $line.Split('=')[1]
		}
	}
}
Catch {
	Skill-Issue "Cannot find ModOrganizer.ini"
	Exit
}
If ($MO2_Profile) {
	$MO2_Profile = $MO2_Profile -Replace '\(', '\(' -Replace '\)', '\)'
	$regexString = $MO2_Profile + '\)*$'
	$MO2_Profile = $MO2_PossibleProfiles -match $regexString
	If (!$MO2_Profile) {
		Skill-Issue "Invalid profile supplied"
		Exit
	}
}
else {
	While (!$MO2_Profile) {
		Write-Host "Select a MO2 Anomaly Profile..."
		$MO2_Profile = GenerateListBox "Select MO2 Profile" "Select a MO2 Anomaly Profile:" $MO2_PossibleProfiles
		If ([string]::IsNullOrEmpty($MO2_Profile)) {
			[Console]::CursorVisible = $true
			Exit
		}
		Clear
	}
}

# Disable Fullscreen Optimizations and DPI Scaling on Anomaly bin files
ForEach ($line in Get-Content -Path "$($MO2_Exe -Replace '.exe', '.ini')") {
	If ($line -match $Anomaly_Exe) {
		$currentExe = $($line -Split '=')[1] -Replace '/','\'
		If (Test-Path -Path $currentExe -PathType Leaf) {
			New-ItemProperty -Path $AppCompatFlagsPath -Name $currentExe -Value '~ DISABLEDXMAXIMIZEDWINDOWEDMODE HIGHDPIAWARE' -PropertyType String -Force | Out-Null
		}
	}
}

# Set default delay
If (!$Anomaly_Delay) {
	$Anomaly_Delay = $Default_Delay
}

# Save to config file
If (!$IgnoreConfig) {
	Set-Content -Encoding UTF8 -Path $Config_File -Value "MO2_Exe=$MO2_Exe" -Force
	Add-Content -Encoding UTF8 -Path $Config_File -Value "MO2_Profile=$MO2_Profile" -Force
	Add-Content -Encoding UTF8 -Path $Config_File -Value "Anomaly_Delay=$Anomaly_Delay" -Force
}

If (-not($LaunchedFromExe)) {
	# Generate shortcuts
	# Simple Shortcut:   powershell.exe -NoProfile -File "PATHTOPS1"
	# Complex Shortcut:  powershell.exe -NoProfile -Command "& 'PATHTOPS1' -MO2_Exe 'PATHTOMO2EXE' -MO2_Profile DX11-AVX -IgnoreConfig -NoShortcut"
	$Launcher_Shortcut = $ScriptFile -Replace '(\.ps1)|(\.exe)','.ini'
	If (Test-Path -Path "$(Split-Path -Path $MO2_Exe)\*.ico" -PathType Leaf) {
		[array]$iconsFound = Get-Item "$(Split-Path -Path $MO2_Exe)\*.ico"
		[string]$Launcher_Icon = $iconsFound[0].FullName
	}
	else {
		Try {
			$Launcher_Icon = $(Get-Content -Path "$($MO2_Exe -Replace '.exe', '.ini')" | Where-Object { $_ -match 'AnomalyLauncher.exe'}).Split('=')[1]
		}
		Catch {
			Skill-Issue "Cannot find AnomalyLauncher.exe location in ModOrganizer.ini"
			Exit
		}
	}
	If ((-not($NoShortcut)) -or (-not($FixedShortcut))) {
		If  (-not(Test-Path -Path "$Launcher_Shortcut" -PathType Leaf)) {
			Set-Shortcut `
				-SourcePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
				-ArgumentsToSource "-NoProfile -File `"$ScriptFile`"" `
				-WorkingDirectory "$ScriptPath" `
				-DestinationPath "$Launcher_Shortcut" `
				-IconLocation "$Launcher_Icon" `
				-Description "Anomaly Affinity Launcher by Eriol"
		}
	}
	If ($FixedShortcut) {
		Set-Shortcut `
			-SourcePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
			-ArgumentsToSource "-NoProfile -Command `"& '$ScriptFile' -MO2_Exe '$MO2_Exe' -MO2_Profile $MO2_Profile -Anomaly_Delay $Anomaly_Delay -IgnoreConfig -NoShortcut`"" `
			-WorkingDirectory "$ScriptPath" `
			-DestinationPath "$Launcher_Shortcut" `
			-IconLocation "$Launcher_Icon" `
			-Description "Anomaly Affinity Launcher by Eriol"
	}
}

# Start MO2
$MO2_Arg =  "`"moshortcut://:$MO2_Profile`""
Write-Host "Starting ModOrganizer 2 with Anomaly profile: $MO2_Profile"
Start-Process -FilePath $MO2_Exe -ArgumentList $MO2_Arg -WorkingDirectory $(Split-Path -Path $MO2_Exe)

# Wait for Anomaly
Write-Host
Write-Host "Waiting Anomaly to start..."
While (!$Done) {
	$Anomaly_Process = Get-Process $Anomaly_Exe -ErrorAction Ignore
	If ($Anomaly_Process) {
		Write-Host "Setting affinity for Anomaly..."
		# Heavily modded Anomaly hangs if tampered too quickly
		Start-Sleep -Seconds $Anomaly_Delay
		$Anomaly_Process.ProcessorAffinity = $Anomaly_Affinity
		$Anomaly_Process.PriorityClass = $Anomaly_Priority
		$Done = $true
	}
	$MO2_Process = Get-Process $($(Split-Path $MO2_Exe -Leaf) -Replace ".exe") -ErrorAction Ignore
	If (!$MO2_Process) {
		Write-Host
		Write-Host "ModOrganizer 2 was terminated..." -ForegroundColor Yellow
		Write-Host
		Start-Sleep -Seconds 3
		[Console]::CursorVisible = $true
		Exit
	}
}

# Print result
$Anomaly_Process = Get-Process $Anomaly_Exe -ErrorAction Ignore
Write-Host
Write-Host "Anomaly started with affinity: $($Anomaly_Process.ProcessorAffinity)"
Start-Sleep -Seconds 3
Clear
Write-Host
Write-Host
Write-Host
Write-Host
Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor('Good hunting Stalker!'.Length / 2)))), 'Good hunting Stalker!')
Write-Host
Start-Sleep -Seconds 4
[Console]::CursorVisible = $true
