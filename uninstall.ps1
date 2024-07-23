Write-Host "Uninstalling"

$standardKey = "TerminalHorsey"
$extendedKey = "TerminalHorseyAdvanced"

# Remove standard context menu

Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$standardKey" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$($standardKey)Admin" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$standardKey" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$($standardKey)Admin" -Recurse -ErrorAction Ignore | Out-Null

Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$standardKey" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$($standardKey)Admin" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$standardKey" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$($standardKey)Admin" -Recurse -ErrorAction Ignore | Out-Null

Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\ContextMenus\$standardKey\shell" -Recurse -ErrorAction Ignore | Out-Null

# Remove extended context menu

Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$extendedKey" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$($extendedKey)Admin" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$extendedKey" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$($extendedKey)Admin" -Recurse -ErrorAction Ignore | Out-Null

Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$extendedKey" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\$($extendedKey)Admin" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$extendedKey" -Recurse -ErrorAction Ignore | Out-Null
Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\$($extendedKey)Admin" -Recurse -ErrorAction Ignore | Out-Null

Remove-Item -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\ContextMenus\$extendedKey\shell" -Recurse -ErrorAction Ignore | Out-Null

