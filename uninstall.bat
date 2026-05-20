@echo off

reg delete "HKCU\Software\Classes\Directory\shell\Tag-Folder" /f >nul 2>&1
rmdir /s /q "%APPDATA%\Tag-Folder" >nul 2>&1