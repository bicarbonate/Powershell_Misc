# Copies the UB folder \\difc\netlogon\ub to the users desktop

new-item -itemtype Directory -path %userprofile%\Desktop\UB-Shortcuts -Force
copy-item -path \\difc\netlogon\ub\*.* -destination %userprofile%\Desktop\UB-Shortcuts