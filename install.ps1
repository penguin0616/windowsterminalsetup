#Requires -RunAsAdministrator
#Requires -Version 6

./uninstall.ps1

$standardKey = "TerminalHorsey"
$extendedKey = "TerminalHorseyAdvanced"

############################################################
# Create the normal version.
############################################################

$shellPath = "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$standardKey"
New-Item -Path $shellPath -Force | Out-Null
New-ItemProperty -Path $shellPath -Name 'MUIVerb' -PropertyType String -Value "horsey around (dir)" -Force | Out-Null
New-ItemProperty -Path $shellPath -Name 'Icon' -PropertyType String -Value '' | Out-Null
New-Item -Path "$shellPath\command" -Force | Out-Null
New-ItemProperty -Path "$shellPath\command" -Name '(Default)' -PropertyType String -Value 'notepad.exe' | Out-Null

$backgroundPath = "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$standardKey"
New-Item -Path $backgroundPath -Force | Out-Null
New-ItemProperty -Path $backgroundPath -Name 'MUIVerb' -PropertyType String -Value "horsey around (background)" -Force | Out-Null
New-ItemProperty -Path $backgroundPath -Name 'Icon' -PropertyType String -Value '' | Out-Null
New-Item -Path "$backgroundPath\command" -Force | Out-Null
New-ItemProperty -Path "$backgroundPath\command" -Name '(Default)' -PropertyType String -Value 'notepad.exe' | Out-Null

############################################################
# Create the extended version.
############################################################

# How to add to shift right click:
# https://superuser.com/questions/453658/add-menu-items-to-shift-right-click-menu-on-windows
# I saved it to a .reg and observed the differences in registry, then inferred what I needed to add to make this work.

$shellPathExtended = "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$extendedKey"
New-Item -Path $shellPathExtended -Force | Out-Null
New-ItemProperty -Path $shellPathExtended -Name 'MUIVerb' -PropertyType String -Value "horsey around (dir) (extended)" -Force | Out-Null
New-ItemProperty -Path $shellPathExtended -Name 'Icon' -PropertyType String -Value '' | Out-Null
New-ItemProperty -Path $shellPathExtended -Name 'Extended' -PropertyType String -Value '' | Out-Null
New-ItemProperty -Path $shellPathExtended -Name 'ExtendedSubCommandsKey' -PropertyType String -Value "Directory\\ContextMenus\\$extendedKey" | Out-Null



$backgroundPathExtended = "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$extendedKey"
New-Item -Path $backgroundPathExtended -Force | Out-Null
New-ItemProperty -Path $backgroundPathExtended -Name 'MUIVerb' -PropertyType String -Value "horsey around (background) (extended)" -Force | Out-Null
New-ItemProperty -Path $backgroundPathExtended -Name 'Icon' -PropertyType String -Value '' | Out-Null
New-ItemProperty -Path $backgroundPathExtended -Name 'Extended' -PropertyType String -Value '' | Out-Null
New-ItemProperty -Path $backgroundPathExtended -Name 'ExtendedSubCommandsKey' -PropertyType String -Value "Directory\\ContextMenus\\$extendedKey" | Out-Null

# This allows us to add the actual extended context menu items.
New-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\ContextMenus\$extendedKey\shell" -Force | Out-Null


$horseKey = "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\ContextMenus\$extendedKey\shell\0-abc"

New-Item -Path $horseKey -Force | Out-Null
New-ItemProperty -Path $horseKey -Name 'MUIVerb' -PropertyType String -Value "launch notepad" -Force | Out-Null
New-ItemProperty -Path $horseKey -Name 'Icon' -PropertyType String -Value '' | Out-Null
New-Item -Path "$horseKey\command" -Force | Out-Null
New-ItemProperty -Path "$horseKey\command" -Name '(Default)' -PropertyType String -Value 'notepad.exe' | Out-Null


