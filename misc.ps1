function GetProgramFilesFolder(
	[Parameter(Mandatory = $true)]
	[bool]$includePreview) {
	$root = "$Env:ProgramFiles\WindowsApps"
	$versionFolders = (Get-ChildItem $root | Where-Object {
			if ($includePreview) {
				$_.Name -like "Microsoft.WindowsTerminal_*__*" -or
				$_.Name -like "Microsoft.WindowsTerminalPreview_*__*"
			}
			else {
				$_.Name -like "Microsoft.WindowsTerminal_*__*"
			}
		})
	$foundVersion = $null
	$result = $null
	foreach ($versionFolder in $versionFolders) {
		if ($versionFolder.Name -match "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+") {
			$version = [version]$Matches.0
			Write-Host "[GetProgramFilesFolder] Found Windows Terminal version $version."
			if ($null -eq $foundVersion -or $version -gt $foundVersion) {
				$foundVersion = $version
				$result = $versionFolder.FullName
			}
		}
		else {
			Write-Warning "[GetProgramFilesFolder] Found Windows Terminal unsupported version in $versionFolder."
		}
	}

	if ($null -eq $result) {
		Write-Error "[GetProgramFilesFolder] Failed to find Windows Terminal actual folder under $root. To install menu items for Windows Terminal Preview, run with ""-Prerelease"" switch Exit."
		exit 1
	}

	if ($foundVersion -lt [version]"0.11") {
		Write-Warning "[GetProgramFilesFolder] The latest version found is less than 0.11, which is not tested. The install script might fail in certain way."
	}

	return $result
}

function GetActiveProfiles(
	[Parameter(Mandatory = $true)]
	[bool]$isPreview
) {
	if ($isPreview) {
		$file = "$env:LocalAppData\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
	}
 	else {
		$file = "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
	}

	if (-not (Test-Path $file)) {
		Write-Error "Couldn't find profiles. Please run Windows Terminal at least once after installing it. Exit."
		exit 1
	}

	$settings = Get-Content $file | Out-String | ConvertFrom-Json
	if ($settings.profiles.PSObject.Properties.name -match "list") {
		$list = $settings.profiles.list
	}
 	else {
		$list = $settings.profiles 
	}

	return $list | Where-Object { -not $_.hidden } | Where-Object { ($null -eq $_.source) -or -not ($settings.disabledProfileSources -contains $_.source) }
}


# https://github.com/Duffney/PowerShell/blob/master/FileSystems/Get-Icon.ps1
Function Get-Icon {
	[CmdletBinding()]
	
	Param ( 
		[Parameter(Mandatory = $True, Position = 1, HelpMessage = "Enter the location of the .EXE file")]
		[string]$File,

		# If provided, will output the icon to a location
		[Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
		[string]$OutputFile
	)
	
	[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') | Out-Null
	
	[System.Drawing.Icon]::ExtractAssociatedIcon($File).ToBitmap().Save($OutputFile)
}



function GetWindowsTerminalIcon(
	[Parameter(Mandatory = $true)]
	[string]$folder,
	[Parameter(Mandatory = $true)]
	[string]$localCache) {
	$icon = "$localCache\wt.ico"
	$actual = $folder + "\WindowsTerminal.exe"
	if (Test-Path $actual) {
		# use app icon directly.
		Write-Host "Found actual executable $actual."
		$temp = "$localCache\wt.png"
		Get-Icon -File $actual -OutputFile $temp
		ConvertTo-Icon -File $temp -OutputFile $icon
	}
 	else {
		# download from GitHub
		Write-Warning "Didn't find actual executable $actual so download icon from GitHub."
		Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/microsoft/terminal/master/res/terminal.ico" -OutFile $icon
	}

	return $icon
}

function ResolveProfileIconToFilepath (
	[Parameter(Mandatory = $true)]
	[string]$profileIcon,

	[Parameter(Mandatory = $false)]
	[bool]$isPreview
) {
	$profilePng = $null

	if (Test-Path $icon) {
		# use user setting
		$profilePng = $icon  
	}
	elseif ($profileIcon -like "ms-appdata:///Roaming/*") {
		#resolve roaming cache
		if ($isPreview) {
			$profilePng = $icon -replace "ms-appdata:///Roaming", "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\RoamingState" -replace "/", "\"
		}
		else {
			$profilePng = $icon -replace "ms-appdata:///Roaming", "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\RoamingState" -replace "/", "\"
		}
	}
	elseif ($profileIcon -like "ms-appdata:///Local/*") {
		#resolve local cache
		if ($isPreview) {
			$profilePng = $icon -replace "ms-appdata:///Local", "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState" -replace "/", "\"
		}
		else {
			$profilePng = $icon -replace "ms-appdata:///Local", "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState" -replace "/", "\"
		}
	}
	elseif ($profileIcon -like "ms-appx:///*") {
		# resolve app cache
		$profilePng = $icon -replace "ms-appx://", $folder -replace "/", "\"
	}
	elseif ($profileIcon -like "*%*") {
		$profilePng = [System.Environment]::ExpandEnvironmentVariables($icon)
	}

	return $profilePng
}

function GetProfileIcon (
	[Parameter(Mandatory = $true)]
	$profile,

	[Parameter(Mandatory = $true)]
	[string]$terminalInstallFolder,

	[Parameter(Mandatory = $true)]
	[string]$localCache,

	[Parameter(Mandatory = $false)]
	[string]$defaultIcon,

	[Parameter(Mandatory = $false)]
	[bool]$isPreview
) {

	$guid = $profile.guid
	$icon = $profile.icon

	Write-Host "     Icon: $icon"
	Write-Host "     Folder: $terminalInstallFolder"

	$iconPath = $null
	if (-not ([string]::IsNullOrEmpty($icon))) {
		$iconPath = ResolveProfileIconToFilepath $icon $isPreview
	}


	# If a profile has an icon value, that means it's a custom icon.
	# If it doesn't that means it probably has a png with the profile's GUID in C:\Program Files\WindowsApps\Microsoft.WindowsTerminal_<...>\ProfileIcons

	# For Developer Cmd/Powershell for VS 2022, WT knows the icons are in there but it isn't marked in the settings file, nor anywhere else that I can find.
	# https://github.com/microsoft/terminal/blob/main/src/cascadia/TerminalSettingsModel/VisualStudioGenerator.cpp
	# The generator has the return path hardcoded to Powershell for the Developer Powershell. Probably for cmd too.
	# https://github.com/microsoft/terminal/blob/main/src/cascadia/TerminalSettingsModel/VsDevShellGenerator.h#L39
	
	# If there's no icon included in the profile, we can try looking for it by GUID in the WT installation.
	if (($null -eq $iconPath) -or -not (Test-Path $iconPath)) {
		# Try the ProfileIcons for the GUID
		$iconPath = "$terminalInstallFolder\ProfileIcons\$guid.scale-200.png"

		# Check if it actually exists
		if (-not (Test-Path($iconPath))) {
			# Manual override time.
			if ($profile.source -eq "Windows.Terminal.Wsl") {
				Write-Warning "Doing manual override for profile [$($profile.name)] with source [$($profile.source)]"
				$iconPath = "$terminalInstallFolder\ProfileIcons\{9acb9455-ca41-5af7-950f-6bca1bc9722f}.scale-200.png"
			} elseif ($profile.source -eq "Windows.Terminal.VisualStudio") {
				if ($profile.name -like "*Powershell*") {
					Write-Warning "Doing manual override for profile [$($profile.name)] with source [$($profile.source)]"
					$iconPath = "$terminalInstallFolder\ProfileIcons\{61c54bbd-c2c6-5271-96e7-009a87ff44bf}.scale-200.png"
				} elseif ($profile.name -like "*Command Prompt*") {
					Write-Warning "Doing manual override for profile [$($profile.name)] with source [$($profile.source)]"
					$iconPath = "$terminalInstallFolder\ProfileIcons\{0caa0dad-35be-5f56-a8ff-afceeeaa6101}.scale-200.png"
				}
			}
		}

		# Wrap up loose ends for above logic
		if (-not (Test-Path($iconPath))) {
			$iconPath = $null
		}
	}

	# If the icon path is still null, we couldn't find anything.
	if ($null -eq $iconPath) {
		# If we have a default icon, we'll fall back to that. If not, skip this profile.
		if (-not ([string]::IsNullOrEmpty($defaultIcon))) {
			Write-Warning "Didn't find icon for profile $($profile.name), falling back."
			$iconPath = $defaultIcon
		} else {
			Write-Warning "Didn't find icon for profile $($profile.name), skipping."
			return $null
		}
	} else {
		Write-Host "     IconPath: $iconPath"
	}

	# Probably need to do some conversion.
	if ($iconPath -like "*.png") {
		# Icon path is a PNG, so it needs to be converted.
		$outputPath = "$localCache\$guid.ico"
		ConvertTo-Icon -File $iconPath -OutputFile $outputPath
		$iconPath = $outputPath
	}
	elseif ($iconPath -like "*.ico") {
		# Good to go.
	}
	else {
		Write-Warning "Icon $iconPath has to be a .png or .ico file."
	}
	

	return $iconPath
}


# Sourced from https://gist.github.com/darkfall/1656050
function ConvertTo-Icon {
	<#
	.Synopsis
		Converts image to icons
	.Description
		Converts an image to an icon
	.Example
		ConvertTo-Icon -File .\Logo.png -OutputFile .\Favicon.ico
	#>
	[CmdletBinding()]
	param(
		# The file
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
		[Alias('Fullname')]
		[string]$File,
   
		# If provided, will output the icon to a location
		[Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
		[string]$OutputFile
	)
	
	begin {
		Add-Type -AssemblyName System.Drawing   
	}
	
	process {
		#region Load Icon
		$resolvedFile = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($file)
		if (-not $resolvedFile) { return }
		$inputBitmap = [Drawing.Image]::FromFile($resolvedFile)
		$width = $inputBitmap.Width
		$height = $inputBitmap.Height
		$size = New-Object Drawing.Size $width, $height
		$newBitmap = New-Object Drawing.Bitmap $inputBitmap, $size
		#endregion Load Icon

		#region Icon Size bound check
		if ($width -gt 255 -or $height -gt 255) {
			$ratio = ($height, $width | Measure-Object -Maximum).Maximum / 255
			$width /= $ratio
			$height /= $ratio
		}
		#endregion Icon Size bound check

		#region Save Icon                     
		$memoryStream = New-Object System.IO.MemoryStream
		$newBitmap.Save($memoryStream, [System.Drawing.Imaging.ImageFormat]::Png)

		$resolvedOutputFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($outputFile)
		$output = [IO.File]::Create("$resolvedOutputFile")
		
		$iconWriter = New-Object System.IO.BinaryWriter($output)
		# 0-1 reserved, 0
		$iconWriter.Write([byte]0)
		$iconWriter.Write([byte]0)

		# 2-3 image type, 1 = icon, 2 = cursor
		$iconWriter.Write([short]1);

		# 4-5 number of images
		$iconWriter.Write([short]1);

		# image entry 1
		# 0 image width
		$iconWriter.Write([byte]$width);
		# 1 image height
		$iconWriter.Write([byte]$height);

		# 2 number of colors
		$iconWriter.Write([byte]0);

		# 3 reserved
		$iconWriter.Write([byte]0);

		# 4-5 color planes
		$iconWriter.Write([short]0);

		# 6-7 bits per pixel
		$iconWriter.Write([short]32);

		# 8-11 size of image data
		$iconWriter.Write([int]$memoryStream.Length);

		# 12-15 offset of image data
		$iconWriter.Write([int](6 + 16));

		# write image data
		# png data must contain the whole png data file
		$iconWriter.Write($memoryStream.ToArray());

		$iconWriter.Flush();
		$output.Close()               
		#endregion Save Icon

		#region Cleanup
		$memoryStream.Dispose()
		$newBitmap.Dispose()
		$inputBitmap.Dispose()
		#endregion Cleanup
	}
}