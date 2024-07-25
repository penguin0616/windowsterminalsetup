#Requires -RunAsAdministrator
#Requires -Version 6

# https://stackoverflow.com/questions/9948517/how-to-stop-a-powershell-script-on-the-first-error
$ErrorActionPreference = "Stop"

# Inspired by https://github.com/lextm/windowsterminal-shell
# Date of writing, that repo is on commit c070ee5579232420bc0f6a85845274693911bb04 on July 22, 2024

function CreateContextMenuItem(
	[Parameter(Mandatory = $true)]
	[string]$path,

	[Parameter(Mandatory = $true)]
	[string]$verb,

	[Parameter(Mandatory = $false)]
	[string]$icon,

	[Parameter(Mandatory = $true)]
	[string]$command,

	[Parameter(Mandatory = $true)]
	[bool]$extended,

	[Parameter(Mandatory = $true)]
	[bool]$elevated
) {
	# Create the menu entry
	New-Item -Path $path -Force | Out-Null
	New-ItemProperty -Path $path -Name 'MUIVerb' -PropertyType String -Value $verb | Out-Null
	New-ItemProperty -Path $path -Name 'Icon' -PropertyType String -Value $icon | Out-Null

	if ($extended) {
		New-ItemProperty -Path $path -Name 'Extended' -PropertyType String -Value '' | Out-Null
	}

	# Create the command for the menu entry
	New-Item -Path "$path\command" | Out-Null
	if ($elevated) {
		#$horse = "Start-Process $executable -Verb RunAs"
		#Write-Host $horse
		#$b64 = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($horse))
		#Write-Host $b64

		#New-ItemProperty -Path "$path\command" -Name '(Default)' -PropertyType String -Value "powershell -WindowStyle Hidden -NonInteractive -EncodedCommand $b64" | Out-Null

		# The %V. is the path passed in by the context
		$horse = "wscript.exe ""$localCache/wthelper.vbs"" ""$command"" ""%V."""
		New-ItemProperty -Path "$path\command" -Name '(Default)' -PropertyType String -Value $horse | Out-Null

		# $command = """$executable"" -d ""%V."""

		#$adjusted = "Start-Process $executable -ArgumentList `"-d ""%V.""`" -Verb RunAs"
		#$adjusted = "Write-Host `"-startingDirectory ""%V.""`""
		#$b64 = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($adjusted))

		#$horse = "wscript.exe ""$localCache/wthelper.vbs"" ""asd"" ""%V"" "
		#New-ItemProperty -Path "$path\command" -Name '(Default)' -PropertyType String -Value $horse | Out-Null
	} else {
		New-ItemProperty -Path "$path\command" -Name '(Default)' -PropertyType String -Value $command | Out-Null
	}
}

function CreateContextMenuGroup(
	[Parameter(Mandatory = $true)]
	[string]$path,

	[Parameter(Mandatory = $true)]
	[string]$verb,

	[Parameter(Mandatory = $false)]
	[string]$icon,

	[Parameter(Mandatory = $true)]
	[string]$group_name,

	[Parameter(Mandatory = $true)]
	[bool]$extended,

	[Parameter(Mandatory = $true)]
	[bool]$elevated
) {
	# Boilerplate
	New-Item -Path $path -Force | Out-Null
	New-ItemProperty -Path $path -Name 'MUIVerb' -PropertyType String -Value $verb | Out-Null
	New-ItemProperty -Path $path -Name 'Icon' -PropertyType String -Value $icon | Out-Null
	
	if ($extended) {
		New-ItemProperty -Path $path -Name 'Extended' -PropertyType String -Value '' | Out-Null
	}

	# Turn it into a group
	New-ItemProperty -Path $path -Name 'ExtendedSubCommandsKey' -PropertyType String -Value "Directory\\ContextMenus\\$group_name" | Out-Null
}

function PopulateContextMenuGroup(
	[Parameter(Mandatory = $true)]
	[string]$group_name,

	[Parameter(Mandatory = $true)]
	[psobject[]]$profiles
) {
	# This allows us to add the actual extended context menu items somewhere.
	New-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\ContextMenus\$group_name\shell" -Force | Out-Null

	$idx = 0
	foreach ($profile in $profiles) {
		$profileGUID = $profile.guid
		$profileName = $profile.name

		$profileKey = "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\ContextMenus\$group_name\shell\$idx-$profileGUID"
		Write-Host "Creating profile item: $profileName"
		#Write-Host "     $profileKey"

		$cmd = """$executable"" -p ""$profileName"" -d ""%V."""
		#$profileIcon = GetProfileIcon $profile $terminalInstallationFolder $localCache $windowsTerminalIcon $isPreview
		$profileIcon = GetProfileIcon $profile $terminalInstallationFolder $localCache $null $isPreview

		New-Item -Path $profileKey -Force | Out-Null
		New-ItemProperty -Path $profileKey -Name 'MUIVerb' -PropertyType String -Value $profile.name -Force | Out-Null
		New-ItemProperty -Path $profileKey -Name 'Icon' -PropertyType String -Value $profileIcon | Out-Null
		New-Item -Path "$profileKey\command" -Force | Out-Null
		New-ItemProperty -Path "$profileKey\command" -Name '(Default)' -PropertyType String -Value $cmd | Out-Null
		$idx += 1
	}
}

########################################################################################################################
# Get going

$isPreview = $false
$includePreview = $false

$standardKey = "WindowsTerminalStuff"
$extendedKey = "WindowsTerminalStuffAdvanced"

. ./misc.ps1

$executable = "$Env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe"
if (-not (Test-Path $executable)) {
	Write-Error "Windows Terminal not detected at $executable. Learn how to install it from https://github.com/microsoft/terminal."
	exit 1
}

$terminalInstallationFolder = GetProgramFilesFolder $includePreview
Write-Host "Terminal folder: $terminalInstallationFolder"

$localCache = "$Env:LOCALAPPDATA\Microsoft\WindowsApps\Cache"

if (-not (Test-Path $localCache)) {
	New-Item $localCache -ItemType Directory | Out-Null
}

#if (-not (Test-Path "$localCache/wthelper.vbs")) {
Copy-Item "./wthelper.vbs" -Destination "$localCache/wthelper.vbs"
#}

./uninstall.ps1
Write-Host "Beginning installation"

$windowsTerminalIcon = GetWindowsTerminalIcon $terminalInstallationFolder $localCache

############################################################
# Create the normal version.
############################################################

$command = """$executable"" -d ""%V."""

##############################
# Right click directory
Write-Host "Creating context menu item for shell (folder)"
$shellPath = "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$standardKey"
CreateContextMenuItem `
	-path $shellPath `
	-verb "Terminal here" `
	-icon $windowsTerminalIcon `
	-command $command `
	-extended $false `
	-elevated $false

$adminShellPath = "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$($standardKey)Admin"
CreateContextMenuItem `
	-path $adminShellPath `
	-verb "Terminal here as Administrator" `
	-icon $windowsTerminalIcon `
	-command $executable `
	-extended $false `
	-elevated $true

##############################
# Right click directory background
Write-Host "Creating context menu item for directory"
$backgroundPath = "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$standardKey"
CreateContextMenuItem `
	-path $backgroundPath `
	-verb "Terminal here" `
	-icon $windowsTerminalIcon `
	-command $command `
	-extended $false `
	-elevated $false 

$backgroundPathAdmin = "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$($standardKey)Admin"
CreateContextMenuItem `
	-path $backgroundPathAdmin `
	-verb "Terminal here as Administrator" `
	-icon $windowsTerminalIcon `
	-command $executable `
	-extended $false `
	-elevated $true

############################################################
# Create the extended version.
############################################################

# How to add to shift right click:
# https://superuser.com/questions/453658/add-menu-items-to-shift-right-click-menu-on-windows
# I saved it to a .reg and observed the differences in registry, then inferred what I needed to add to make this work.

# Right click directory
$shellPathExtended = "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$extendedKey"
CreateContextMenuGroup $shellPathExtended 'Terminal Here (extended)' $windowsTerminalIcon $extendedKey $true $false

# Right click directory background
$backgroundPathExtended = "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$extendedKey"
CreateContextMenuGroup $backgroundPathExtended 'Terminal Here (extended)' $windowsTerminalIcon $extendedKey $true $false


#$profileKey = "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\ContextMenus\$extendedKey\shell\0-abc"

#New-Item -Path $profileKey -Force | Out-Null
#New-ItemProperty -Path $profileKey -Name 'MUIVerb' -PropertyType String -Value "launch notepad" -Force | Out-Null
#New-ItemProperty -Path $profileKey -Name 'Icon' -PropertyType String -Value '' | Out-Null
#New-Item -Path "$profileKey\command" -Force | Out-Null
#New-ItemProperty -Path "$profileKey\command" -Name '(Default)' -PropertyType String -Value 'notepad.exe' | Out-Null

$profiles = GetActiveProfiles $isPreview

PopulateContextMenuGroup $extendedKey $profiles
