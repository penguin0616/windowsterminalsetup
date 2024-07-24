Write-Host "Running uninstaller"

$standardKey = "WindowsTerminalStuff"
$extendedKey = "WindowsTerminalStuffAdvanced"

# TODO: Delete Cache folder

# Remove standard context menu

Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$standardKey" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$($standardKey)Admin" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$standardKey" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$($standardKey)Admin" -Recurse -ErrorAction Ignore | Out-Null

Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$standardKey" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$($standardKey)Admin" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$standardKey" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$($standardKey)Admin" -Recurse -ErrorAction Ignore | Out-Null

Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\ContextMenus\$standardKey" -Recurse -ErrorAction Ignore | Out-Null

# Remove extended context menu

Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$extendedKey" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$($extendedKey)Admin" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$extendedKey" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$($extendedKey)Admin" -Recurse -ErrorAction Ignore | Out-Null

Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$extendedKey" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$($extendedKey)Admin" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$extendedKey" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$($extendedKey)Admin" -Recurse -ErrorAction Ignore | Out-Null

Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\ContextMenus\$extendedKey" -Recurse -ErrorAction Ignore | Out-Null

