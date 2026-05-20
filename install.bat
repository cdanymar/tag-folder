@echo off
setlocal

set "INSTALL_DIR=%APPDATA%\Tag-Folder"
set "SCRIPT=%INSTALL_DIR%\Tag-Folder.ps1"

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
copy /y "%~dp0Tag-Folder.ps1" "%SCRIPT%" >nul

reg add "HKCU\Software\Classes\Directory\shell\Tag-Folder" /ve /d "Tag Folder" /f >nul
reg add "HKCU\Software\Classes\Directory\shell\Tag-Folder\command"  /ve /d "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%SCRIPT%\" \"%%1\"" /f >nul