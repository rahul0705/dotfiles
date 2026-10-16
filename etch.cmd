@echo off
powershell.exe -NoProfile -File "%~dp0etch.ps1" %*
exit /b %errorlevel%
